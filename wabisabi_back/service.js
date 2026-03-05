const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes');

const app = express();

// Middleware
app.use(helmet()); // Безопасность заголовков
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(morgan('dev')); // Логирование
app.use(express.json()); // Парсинг JSON
app.use(express.urlencoded({ extended: true })); // Парсинг форм

// Подключение к MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/wabisabi', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB подключена'))
.catch((err) => console.error('❌ Ошибка подключения к MongoDB:', err));

// Маршруты
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Тестовый маршрут
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok', 
    message: 'Сервер Wabi-Sabi работает',
    timestamp: new Date().toISOString()
  });
});

// Обработка 404
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: 'Маршрут не найден' 
  });
});

// Обработка ошибок
app.use((err, req, res, next) => {
  console.error('🔥 Ошибка сервера:', err);
  res.status(500).json({ 
    success: false, 
    message: 'Внутренняя ошибка сервера',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Сервер запущен на порту ${PORT}`);
  console.log(`📡 Режим: ${process.env.NODE_ENV || 'development'}`);
});