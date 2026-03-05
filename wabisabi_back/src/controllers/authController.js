const User = require('../models/User');
const { generateToken } = require('../config/jwtConfig');
const { validationResult } = require('express-validator');

// Регистрация
exports.register = async (req, res) => {
  try {
    // Проверка валидации
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const { username, email, password } = req.body;
    
    // Проверка существования пользователя
    const existingUser = await User.findOne({
      $or: [{ email }, { username }]
    });
    
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: existingUser.email === email 
          ? 'Пользователь с таким email уже существует'
          : 'Пользователь с таким именем уже существует'
      });
    }
    
    // Создание пользователя
    const user = await User.create({
      username,
      email,
      password,
      strongSides: [],
      needHelpIn: [],
      adviceStats: {},
      status: 'новичок',
      isAcceptingAdvice: true,
      isLookingForHelp: true
    });
    
    // Генерация токена
    const token = generateToken(user._id);
    
    // Формирование ответа без пароля
    const userResponse = {
      _id: user._id,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      status: user.status,
      strongSides: user.strongSides,
      needHelpIn: user.needHelpIn,
      isAcceptingAdvice: user.isAcceptingAdvice,
      isLookingForHelp: user.isLookingForHelp,
      createdAt: user.createdAt
    };
    
    res.status(201).json({
      success: true,
      message: 'Регистрация успешна',
      token,
      user: userResponse
    });
    
  } catch (error) {
    console.error('Ошибка регистрации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при регистрации'
    });
  }
};

// Вход
exports.login = async (req, res) => {
  try {
    // Проверка валидации
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const { email, password } = req.body;
    
    // Поиск пользователя с паролем
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Неверный email или пароль'
      });
    }
    
    // Проверка пароля
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Неверный email или пароль'
      });
    }
    
    // Генерация токена
    const token = generateToken(user._id);
    
    // Формирование ответа без пароля
    const userResponse = {
      _id: user._id,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      status: user.status,
      strongSides: user.strongSides,
      needHelpIn: user.needHelpIn,
      isAcceptingAdvice: user.isAcceptingAdvice,
      isLookingForHelp: user.isLookingForHelp,
      adviceStats: user.adviceStats,
      createdAt: user.createdAt
    };
    
    res.status(200).json({
      success: true,
      message: 'Вход выполнен успешно',
      token,
      user: userResponse
    });
    
  } catch (error) {
    console.error('Ошибка входа:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при входе'
    });
  }
};

// Получение текущего пользователя
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    
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
        email: user.email,
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
    console.error('Ошибка получения пользователя:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
};