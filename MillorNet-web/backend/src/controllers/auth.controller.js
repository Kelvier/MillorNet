const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

const register = async (req, res) => {
  console.log('=== REGISTRO SOLICITADO ===');
  
  // DEBUG: Ver qué llega
  console.log('Tipo de body:', typeof req.body);
  console.log('Body completo:', req.body);
  console.log('Headers:', req.headers['content-type']);
  
  const { username, email, password } = req.body;
  
  console.log('Datos extraídos:', { 
    username: username || 'NO PROPORCIONADO',
    email: email || 'NO PROPORCIONADO', 
    password: password ? 'PROPORCIONADO' : 'NO PROPORCIONADO'
  });
  
  if (!username || !email || !password) {
    console.log('ERROR: Datos incompletos');
    return res.status(400).json({ 
      error: 'Faltan datos',
      received: {
        username: !!username,
        email: !!email,
        password: !!password
      }
    });
  }

  try {
    // Verificar si ya existe
    const existing = await pool.query(
      'SELECT * FROM users WHERE email=$1 OR username=$2',
      [email, username]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Usuario o email ya existe' });
    }

    // Crear hash de contraseña
    const hash = await bcrypt.hash(password, 10);
    
    // Insertar en base de datos
    const result = await pool.query(
      'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING id, username, email',
      [username, email, hash]
    );

    console.log('✅ Usuario registrado:', result.rows[0].username);
    
    // CORRECCIÓN: Usar result.rows[0] en lugar de user
    const newUser = result.rows[0];
    
    // Generar token JWT
    const token = jwt.sign(
      { 
        id: newUser.id,
        username: newUser.username,
        email: newUser.email 
      },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );
    
    console.log('✅ Token generado para:', newUser.username);
    
    res.json({
      message: 'Usuario registrado correctamente',
      token: token,
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email
      }
    });
    
  } catch (err) {
    console.error('❌ Error en registro:', err);
    console.error('Stack trace:', err.stack);
    res.status(500).json({ 
      error: 'Error en el servidor',
      details: err.message
    });
  }
};

const login = async (req, res) => {
  console.log('=== LOGIN SOLICITADO ===');
  console.log('Body:', req.body);
  
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Faltan datos' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email=$1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Usuario no encontrado' });
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    
    if (!valid) {
      return res.status(400).json({ error: 'Contraseña incorrecta' });
    }

    // Generar token JWT
    const token = jwt.sign(
      { 
        id: user.id,
        username: user.username,
        email: user.email 
      },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    console.log('✅ Login exitoso para:', user.email);
    
    res.json({
      message: 'Login correcto',
      token: token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (err) {
    console.error('❌ Error en login:', err);
    console.error('Stack trace:', err.stack);
    res.status(500).json({ 
      error: 'Error en el servidor',
      details: err.message
    });
  }
};

module.exports = {
  register,
  login
};