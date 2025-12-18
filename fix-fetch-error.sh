#!/bin/bash
echo "=== Corrigiendo error 'Failed to fetch' ==="

# 1. Backend - Configuración completa
cd ~/millornet/backend
cat > src/app.js << 'APP_EOF'
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');

const app = express();

// CORS completo
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With']
}));

// Handle preflight
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.sendStatus(200);
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(\`\${new Date().toISOString()} - \${req.method} \${req.url}\`);
  console.log('Origin:', req.headers.origin);
  console.log('User-Agent:', req.headers['user-agent']);
  next();
});

// Rutas
app.get('/', (req, res) => {
  res.json({
    api: 'MillorNet',
    version: '1.0.0',
    endpoints: [
      'POST /api/auth/register',
      'POST /api/auth/login'
    ],
    cors: 'enabled'
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    serverTime: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.use('/api/auth', authRoutes);

module.exports = app;
APP_EOF

# 2. Frontend - Actualizar URLs
cd ~/millornet/frontend
echo "Actualizando frontend con IP pública..."

# Para index.html
cat > public/index.html << 'INDEX_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MillorNet - Mini Twitter Cyber</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="flex min-h-screen">

  <!-- Sidebar izquierda -->
  <div class="w-1/5 bg-white p-4 flex flex-col space-y-4 shadow-md">
    <h2 class="font-bold text-xl">MillorNet</h2>
    <button class="hover:bg-gray-200 p-2 rounded">Inicio</button>
    <button class="hover:bg-gray-200 p-2 rounded">Perfil</button>
    <button class="hover:bg-gray-200 p-2 rounded">Configuración</button>
    <button id="logoutBtn" class="hover:bg-gray-200 p-2 rounded hidden" onclick="logout()">Cerrar sesión</button>
  </div>

  <!-- Feed central -->
  <div class="flex-1 p-4 space-y-4">
    <div id="authArea" class="bg-white p-4 rounded shadow">
      <div class="flex justify-around mb-4">
        <button id="loginTab" class="font-bold border-b-2 border-blue-600 px-2 py-1">Login</button>
        <button id="registerTab" class="font-bold text-gray-500 px-2 py-1">Registro</button>
      </div>

      <!-- Login Form -->
      <form id="loginForm" class="space-y-4">
        <div>
          <label>Email</label>
          <input type="email" id="loginEmail" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>
        <div>
          <label>Contraseña</label>
          <input type="password" id="loginPassword" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>
        <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded">Iniciar sesión</button>
      </form>

      <!-- Register Form -->
      <form id="registerForm" class="space-y-4 hidden">
        <div>
          <label>Usuario</label>
          <input type="text" id="regUsername" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>
        <div>
          <label>Email</label>
          <input type="email" id="regEmail" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>
        <div>
          <label>Contraseña</label>
          <input type="password" id="regPassword" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>
        <button type="submit" class="w-full bg-green-600 text-white py-2 rounded">Registrarse</button>
      </form>
    </div>

    <div id="postArea" class="bg-white p-4 rounded shadow hidden">
      <h3 id="welcomeUser"></h3>
      <textarea id="newPost" placeholder="¿Qué estás pensando?" class="w-full p-2 border rounded"></textarea>
      <button onclick="addPost()" class="mt-2 bg-blue-600 text-white px-4 py-2 rounded">Publicar</button>
    </div>

    <div id="posts" class="space-y-2"></div>
  </div>

  <!-- Sidebar derecha -->
  <div class="w-1/4 bg-white p-4 shadow-md">
    <h3>Tendencias Cyber</h3>
    <ul class="text-blue-600">
      <li>#Ransomware</li>
      <li>#Ciberseguridad</li>
      <li>#Pentesting</li>
      <li>#Vulnerabilidades</li>
      <li>#HackingEtico</li>
    </ul>
  </div>

</div>

<script>
const API_BASE_URL = 'http://176.84.214.29:3000/api';
let currentUser = null;

// Tabs
document.getElementById('loginTab').onclick = () => {
  document.getElementById('loginForm').classList.remove('hidden');
  document.getElementById('registerForm').classList.add('hidden');
  document.getElementById('loginTab').classList.add('border-b-2', 'border-blue-600');
  document.getElementById('loginTab').classList.remove('text-gray-500');
  document.getElementById('registerTab').classList.remove('border-b-2', 'border-blue-600');
  document.getElementById('registerTab').classList.add('text-gray-500');
};

document.getElementById('registerTab').onclick = () => {
  document.getElementById('registerForm').classList.remove('hidden');
  document.getElementById('loginForm').classList.add('hidden');
  document.getElementById('registerTab').classList.add('border-b-2', 'border-blue-600');
  document.getElementById('registerTab').classList.remove('text-gray-500');
  document.getElementById('loginTab').classList.remove('border-b-2', 'border-blue-600');
  document.getElementById('loginTab').classList.add('text-gray-500');
};

// Login
async function login(event){
  event.preventDefault();
  const email = document.getElementById('loginEmail').value;
  const password = document.getElementById('loginPassword').value;

  try {
    console.log('Intentando login a:', \`\${API_BASE_URL}/auth/login\`);
    const res = await fetch(\`\${API_BASE_URL}/auth/login\`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({email, password})
    });
    
    console.log('Status:', res.status);
    const data = await res.json();
    console.log('Response:', data);
    
    if(data.error) {
      alert('Error: ' + data.error);
      return;
    }

    currentUser = data.user;
    afterLogin();
  } catch(err) {
    console.error('Login error:', err);
    alert('Error de conexión: ' + err.message);
  }
}

// Register
async function register(event){
  event.preventDefault();
  const username = document.getElementById('regUsername').value;
  const email = document.getElementById('regEmail').value;
  const password = document.getElementById('regPassword').value;

  try {
    console.log('Intentando registro a:', \`\${API_BASE_URL}/auth/register\`);
    const res = await fetch(\`\${API_BASE_URL}/auth/register\`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({username, email, password})
    });
    
    console.log('Status:', res.status);
    const data = await res.json();
    console.log('Response:', data);
    
    if(data.error) {
      alert('Error: ' + data.error);
      return;
    }

    alert('✓ Registro exitoso. Ahora puedes iniciar sesión.');
    document.getElementById('loginTab').click();
    // Limpiar formulario
    document.getElementById('regUsername').value = '';
    document.getElementById('regEmail').value = '';
    document.getElementById('regPassword').value = '';
  } catch(err) {
    console.error('Register error:', err);
    alert('Error de conexión: ' + err.message);
  }
}

// Post-login
function afterLogin(){
  document.getElementById('authArea').classList.add('hidden');
  document.getElementById('postArea').classList.remove('hidden');
  document.getElementById('welcomeUser').textContent = \`¡Bienvenido, \${currentUser.username}!\`;
  document.getElementById('logoutBtn').classList.remove('hidden');
  // Limpiar formulario
  document.getElementById('loginEmail').value = '';
  document.getElementById('loginPassword').value = '';
}

// Logout
function logout(){
  currentUser = null;
  document.getElementById('postArea').classList.add('hidden');
  document.getElementById('authArea').classList.remove('hidden');
  document.getElementById('logoutBtn').classList.add('hidden');
  document.getElementById('loginTab').click();
}

// Añadir post
function addPost(){
  const text = document.getElementById('newPost').value;
  if(!text) return alert('Escribe algo antes de publicar');
  const postEl = document.createElement('div');
  postEl.className = "bg-white p-4 rounded shadow";
  postEl.innerHTML = \`<strong>\${currentUser.username}</strong><p>\${text}</p><small class="text-gray-500">\${new Date().toLocaleTimeString()}</small>\`;
  document.getElementById('posts').prepend(postEl);
  document.getElementById('newPost').value = '';
}

// Event listeners
document.getElementById('loginForm').addEventListener('submit', login);
document.getElementById('registerForm').addEventListener('submit', register);

// Test connection on load
window.addEventListener('load', async () => {
  try {
    const res = await fetch(\`\${API_BASE_URL}/health\`);
    if (res.ok) {
      console.log('✅ Backend conectado');
    }
  } catch (err) {
    console.warn('⚠️ Backend no accesible');
  }
});
</script>

</body>
</html>
INDEX_EOF

# 3. Reiniciar backend
echo "Reiniciando backend..."
cd ~/millornet/backend
pm2 restart MillorNet

echo ""
echo "=== CORRECCIONES APLICADAS ==="
echo "1. CORS configurado para permitir cualquier origen"
echo "2. Frontend actualizado para usar IP pública: 176.84.214.29"
echo "3. Backend reiniciado"
echo ""
echo "URLs:"
echo "- Frontend: Debes servir este archivo index.html con un servidor web"
echo "- Backend API: http://176.84.214.29:3000"
echo "- Health check: http://176.84.214.29:3000/api/health"
echo ""
echo "Para servir el frontend:"
echo "cd ~/millornet/frontend && python3 -m http.server 5500"
echo "Luego accede a: http://176.84.214.29:5500/public/index.html"
