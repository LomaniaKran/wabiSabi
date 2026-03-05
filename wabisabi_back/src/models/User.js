const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Имя пользователя обязательно'],
    unique: true,
    trim: true,
    minlength: [3, 'Имя пользователя должно быть не менее 3 символов'],
    maxlength: [30, 'Имя пользователя должно быть не более 30 символов'],
    match: [/^[a-zA-Z0-9_]+$/, 'Имя пользователя может содержать только буквы, цифры и подчёркивания']
  },
  
  email: {
    type: String,
    required: [true, 'Email обязателен'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Пожалуйста, введите корректный email']
  },
  
  password: {
    type: String,
    required: [true, 'Пароль обязателен'],
    minlength: [6, 'Пароль должен быть не менее 6 символов'],
    select: false // Не возвращать пароль при запросах
  },
  
  avatarUrl: {
    type: String,
    default: null
  },
  
  bio: {
    type: String,
    maxlength: [500, 'Описание не должно превышать 500 символов'],
    default: ''
  },
  
  status: {
    type: String,
    enum: ['новичок', 'любитель', 'профи', 'эксперт'],
    default: 'новичок'
  },
  
  strongSides: [{
    type: String,
    maxlength: 50
  }],
  
  needHelpIn: [{
    type: String,
    maxlength: 50
  }],
  
  isAcceptingAdvice: {
    type: Boolean,
    default: true
  },
  
  isLookingForHelp: {
    type: Boolean,
    default: true
  },
  
  adviceStats: {
    type: Map,
    of: Number,
    default: {}
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Хеширование пароля перед сохранением
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Метод для проверки пароля
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Метод для обновления времени изменения
userSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: Date.now() });
  next();
});

const User = mongoose.model('User', userSchema);

module.exports = User;