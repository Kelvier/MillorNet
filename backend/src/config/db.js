const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER || 'ikervp',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'millornet',
  password: process.env.DB_PASSWORD || 'alumnes',
  port: process.env.DB_PORT || 5432,
});

module.exports = pool;
