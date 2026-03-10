#!/bin/bash
echo "=== CONFIGURACIÓN COMPLETA MILLORNET ==="

# 1. Configurar backend
cd ~/millornet/backend
echo "1. Configurando backend para servir frontend..."
cat > src/app.js << 'APP_EOF'
const express = require("express");
const cors = require("cors");
const path = require("path");
const authRoutes = require("./routes/auth.routes");
const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Servir archivos estáticos
app.use(express.static(path.join(__dirname, "../../frontend")));
// Ruta principal - Frontend
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../../frontend/public/index.html"));
});
// API
app.get("/api/health", (req, res) => {
  res.json({ status: "OK", timestamp: new Date().toISOString() });
});
app.use("/api/auth", authRoutes);
module.exports = app;
APP_EOF

# 2. Crear frontend si no existe
cd ~/millornet/frontend
echo "2. Configurando frontend..."
mkdir -p public pages js
cat > public/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
  <title>MillorNet</title>
  <script>
    window.location.href = "/login";
  </script>
</head>
<body>
  Redirigiendo a login...
</body>
</html>
HTML_EOF

# 3. Crear página de login bonita
cat > pages/login.html << 'LOGIN_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - MillorNet</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body { background: #0a0a0f; color: white; }
    .cyber-border { border: 2px solid #00ffff; box-shadow: 0 0 15px #00ffff; }
  </style>
</head>
<body class="flex items-center justify-center min-h-screen">
  <div class="cyber-border p-8 rounded-lg max-w-md w-full">
    <h1 class="text-3xl font-bold text-center mb-6">MILLORNET</h1>
    <form id="loginForm" class="space-y-4">
      <input type="email" id="email" placeholder="Email" class="w-full p-3 bg-gray-900 rounded" required>
      <input type="password" id="password" placeholder="Contraseña" class="w-full p-3 bg-gray-900 rounded" required>
      <button type="submit" class="w-full bg-cyan-600 p-3 rounded font-bold">INICIAR SESIÓN</button>
    </form>
    <p class="mt-4 text-center">
      ¿No tienes cuenta? <a href="/register" class="text-cyan-400">Regístrate</a>
    </p>
  </div>
  <script>
    document.getElementById('loginForm').onsubmit = async (e) => {
      e.preventDefault();
      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;
      
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      
      const data = await response.json();
      if (data.error) {
        alert(data.error);
      } else {
        // Redirigir al dashboard después del login
        window.location.href = '/';
      }
    };
  </script>
</body>
</html>
LOGIN_EOF

# 4. Reiniciar backend
echo "3. Reiniciando backend..."
cd ~/millornet/backend
pm2 restart MillorNet

sleep 3

echo ""
echo "✅ CONFIGURACIÓN COMPLETADA"
echo ""
echo "URLs:"
echo "- Frontend: http://176.84.214.29:3000"
echo "- Login: http://176.84.214.29:3000/login"
echo "- API Health: http://176.84.214.29:3000/api/health"
echo ""
echo "Para ver logs: pm2 logs MillorNet"
