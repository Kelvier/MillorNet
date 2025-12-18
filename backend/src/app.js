const express = require('express');
const cors = require('cors');
const path = require('path');
const authRoutes = require('./routes/auth.routes');

const app = express();

// CORS para desarrollo
app.use(cors());

// Middleware para parsear JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// SERVIR ARCHIVOS ESTÁTICOS DEL FRONTEND
app.use(express.static(path.join(__dirname, '../../frontend')));

// RUTA PRINCIPAL - Servir el frontend principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/public/index.html'));
});

// RUTAS PARA PÁGINAS ESPECÍFICAS
app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/pages/login.html'));
});

app.get('/register', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/pages/register.html'));
});

// ¡IMPORTANTE! RUTA PARA EL DASHBOARD
app.get('/dashboard.html', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/pages/dashboard.html'));
});

// API endpoints
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'MillorNet API'
  });
});

// Rutas de autenticación de la API
app.use('/api/auth', authRoutes);

// Para SPA (Single Page Application) - redirigir todas las rutas no encontradas al index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/public/index.html'));
});

module.exports = app;