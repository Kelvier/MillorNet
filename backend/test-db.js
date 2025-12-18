const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER || 'ikervp',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'millornet',
  password: process.env.DB_PASSWORD || 'alumnes',
  port: process.env.DB_PORT || 5432,
});

(async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Conectado a la base de datos');
    const res = await client.query('SELECT NOW()');
    console.log('✅ Hora actual de la base de datos:', res.rows[0]);
    client.release();
    await pool.end();
  } catch (err) {
    console.error('❌ Error conectando a la base de datos:', err.message);
    console.error('Detalles:', err);
  }
})();
