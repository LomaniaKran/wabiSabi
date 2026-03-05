const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
const { registerValidator, loginValidator } = require('../utils/validators');

// Регистрация
router.post('/register', registerValidator, authController.register);

// Вход
router.post('/login', loginValidator, authController.login);

// Получение данных текущего пользователя (защищённый маршрут)
router.get('/me', protect, authController.getMe);

module.exports = router;