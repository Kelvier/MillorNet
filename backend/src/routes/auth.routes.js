const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
//const { authenticateToken } = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
//router.get('/verify', authenticateToken, (req, res) => {
  //res.json({
    //valid: true,
    //user: req.user
  //});
//});

module.exports = router;