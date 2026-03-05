const { body } = require('express-validator');

const registerValidator = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 30 })
    .withMessage('Имя пользователя должно быть от 3 до 30 символов')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Имя пользователя может содержать только буквы, цифры и подчёркивания'),
  
  body('email')
    .trim()
    .isEmail()
    .withMessage('Пожалуйста, введите корректный email')
    .normalizeEmail(),
  
  body('password')
    .isLength({ min: 6 })
    .withMessage('Пароль должен быть не менее 6 символов'),
  
  body('confirmPassword')
    .custom((value, { req }) => {
      if (value !== req.body.password) {
        throw new Error('Пароли не совпадают');
      }
      return true;
    })
];

const loginValidator = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Пожалуйста, введите корректный email')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('Пароль обязателен')
];

const updateProfileValidator = [
  body('bio')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Описание не должно превышать 500 символов'),
  
  body('status')
    .optional()
    .isIn(['новичок', 'любитель', 'профи', 'эксперт'])
    .withMessage('Неверный статус'),
  
  body('strongSides')
    .optional()
    .isArray()
    .withMessage('Сильные стороны должны быть массивом'),
  
  body('needHelpIn')
    .optional()
    .isArray()
    .withMessage('Слабые стороны должны быть массивом')
];

module.exports = {
  registerValidator,
  loginValidator,
  updateProfileValidator
};