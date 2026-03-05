const User = require('../models/User');
const { validationResult } = require('express-validator');

// Получение профиля пользователя
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Пользователь не найден'
      });
    }
    
    res.status(200).json({
      success: true,
      user: {
        _id: user._id,
        username: user.username,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        status: user.status,
        strongSides: user.strongSides,
        needHelpIn: user.needHelpIn,
        isAcceptingAdvice: user.isAcceptingAdvice,
        isLookingForHelp: user.isLookingForHelp,
        adviceStats: user.adviceStats,
        createdAt: user.createdAt
      }
    });
    
  } catch (error) {
    console.error('Ошибка получения профиля:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
};

// Обновление профиля
exports.updateProfile = async (req, res) => {
  try {
    // Проверка валидации
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const {
      bio,
      status,
      strongSides,
      needHelpIn,
      isAcceptingAdvice,
      isLookingForHelp
    } = req.body;
    
    // Обновление только разрешённых полей
    const updateData = {};
    if (bio !== undefined) updateData.bio = bio;
    if (status !== undefined) updateData.status = status;
    if (strongSides !== undefined) updateData.strongSides = strongSides;
    if (needHelpIn !== undefined) updateData.needHelpIn = needHelpIn;
    if (isAcceptingAdvice !== undefined) updateData.isAcceptingAdvice = isAcceptingAdvice;
    if (isLookingForHelp !== undefined) updateData.isLookingForHelp = isLookingForHelp;
    
    const user = await User.findByIdAndUpdate(
      req.userId,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Пользователь не найден'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Профиль обновлён',
      user: {
        _id: user._id,
        username: user.username,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        status: user.status,
        strongSides: user.strongSides,
        needHelpIn: user.needHelpIn,
        isAcceptingAdvice: user.isAcceptingAdvice,
        isLookingForHelp: user.isLookingForHelp,
        adviceStats: user.adviceStats,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });
    
  } catch (error) {
    console.error('Ошибка обновления профиля:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
};