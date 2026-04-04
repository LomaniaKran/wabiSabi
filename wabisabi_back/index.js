// index.js (Главный файл сервера)
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth'); // <--- Добавили импорт auth
const profileRoutes = require('./routes/profile'); // <--- Добавим позже
const { PrismaClient } = require('@prisma/client');

const app = express();

app.use((req, res, next) => {
    console.log(`[SERVER DEBUG] Получен запрос: ${req.method} ${req.url}`);
    next();
});

const prisma = new PrismaClient(); 

app.use(cors({
  origin: '*', // Или укажи адрес твоего фронтенда (например, http://localhost:...)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'] // <-- ЭТОТ ЗАГОЛОВОК ОБЯЗАТЕЛЕН
}));
app.use(express.json());

// ----------------------------------------------------
// 1. Подключение маршрутов
// ----------------------------------------------------
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes); 

app.get('/', (req, res) => res.send('Wabi-Sabi Server is running!'));

// Проверка связи с БД (Осталось с прошлого раза)
app.get('/test-db', async (req, res) => {
    try {
        const users = await prisma.user.findMany();
        res.json({ message: "DB OK", count: users.length });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// ----------------------------------------------------

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));