const express = require('express');
const router = express.Router();
const prisma = require('../lib/prisma');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Регистрация
router.post('/register', async (req, res) => {
    console.log("1. Запрос получен:", req.body);
    
    try {
        const { username, email, password } = req.body;
        
        console.log("2. Начинаю хэширование пароля");
        const hashedPassword = await bcrypt.hash(password, 10);
        
        console.log("3. Пытаюсь записать в БД...");
        const user = await prisma.user.create({
            data: { username, email, password: hashedPassword }
        });
        
        console.log("4. Успешно записано в БД, отправляю ответ клиенту");
        res.status(201).json({ message: 'OK' });
        
    } catch (e) {
        console.error("ОШИБКА НА СЕРВЕРЕ:", e);
        res.status(500).json({ error: 'Ошибка: ' + e.message });
    }
});

// Логин
router.post('/login', async (req, res) => {
    console.log("Логин: пришел запрос с данными", req.body);
    try {
        const { email, password } = req.body;
        const user = await prisma.user.findUnique({ where: { email } });
        
        if (!user) {
            console.log("Логин: пользователь не найден");
            return res.status(401).json({ error: 'Неверные данные' });
        }

        const valid = await bcrypt.compare(password, user.password);
        if (!valid) {
            console.log("Логин: неверный пароль");
            return res.status(401).json({ error: 'Неверные данные' });
        }
        
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret');
        console.log("Логин: успех, токен создан");
        res.json({ token, userId: user.id });
    } catch (e) {
        console.error("Логин: ОШИБКА", e);
        res.status(500).json({ error: e.message });
    }
});

module.exports = router;