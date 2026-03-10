const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Test server OK' });
});

app.post('/api/test', (req, res) => {
  console.log('Body received:', req.body);
  res.json({ received: req.body, status: 'OK' });
});

app.listen(3001, '0.0.0.0', () => {
  console.log('Test server on port 3001');
});
