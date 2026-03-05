const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const { updateProfileValidator } = require('../utils/validators');

// Получение профиля пользователя (публичный)
router.get('/:userId', userController.getUserProfile);

// Обновление профиля (защищённый)
router.put('/profile', protect, updateProfileValidator, userController.updateProfile);

module.exports = router;