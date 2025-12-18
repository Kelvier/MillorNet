#!/bin/bash
echo "=== Configurando acceso público para MillorNet ==="

# 1. Configurar backend para escuchar en todas las interfaces
cd ~/millornet/backend
echo "Configurando backend..."
cat > src/server.js << 'SERVER_EOF'
const app = require('./app');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(\`Servidor corriendo en http://\${HOST}:\${PORT}\`);
  console.log(\`Accesible desde: http://TU_IP_PUBLICA:\${PORT}\`);
});
SERVER_EOF

# 2. Actualizar CORS para permitir cualquier origen (TEMPORAL para pruebas)
cat > src/app.js << 'APP_EOF'
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');

const app = express();

// CORS permisivo para pruebas
app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ruta raíz
app.get('/', (req, res) => {
  const clientIP = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  res.json({
    message: 'API de MillorNet',
    clientIP: clientIP,
    endpoints: {
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login'
      }
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString()
  });
});

app.use('/api/auth', authRoutes);

module.exports = app;
APP_EOF

# 3. Reiniciar PM2
echo "Reiniciando PM2..."
pm2 delete MillorNet 2>/dev/null || true
cd ~/millornet/backend
pm2 start src/server.js --name MillorNet
pm2 save

# 4. Configurar firewall
echo "Configurando firewall..."
sudo ufw allow 3000/tcp 2>/dev/null || echo "UFW no disponible, usando iptables..."
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT 2>/dev/null || true

# 5. Mostrar información
echo ""
echo "=== CONFIGURACIÓN COMPLETADA ==="
echo ""
echo "Tu IP local: $(hostname -I | awk '{print $1}')"
echo "Puerto: 3000"
echo ""
echo "Acceso interno:"
echo "  http://localhost:3000"
echo "  http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "Para acceso público:"
echo "1. Configura port forwarding en tu router:"
echo "   Puerto 3000 TCP -> $(hostname -I | awk '{print $1}')"
echo "2. Tu IP pública: $(curl -s ifconfig.me)"
echo "3. URL pública: http://$(curl -s ifconfig.me):3000"
echo ""
echo "Verifica con: curl http://localhost:3000"
