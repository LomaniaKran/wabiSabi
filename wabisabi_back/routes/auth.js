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
    // 1. Принимаем identifier
    const { identifier, password } = req.body; 

    try {
        // 2. Используем findFirst и OR, чтобы искать или по email, или по username
        const user = await prisma.user.findFirst({
            where: {
                OR: [
                    { email: identifier },
                    { username: identifier }
                ]
            }
        });

        // 3. Если пользователя нет
        if (!user) {
            return res.status(400).json({ error: "Пользователь не найден" });
        }

        // 4. Проверка пароля (убедись, что используешь bcrypt.compare)
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: "Неверный пароль" });
        }

        // 5. Генерация токена
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '24h' });
        
        res.json({ token });

    } catch (e) {
        console.error("Ошибка логина:", e);
        res.status(500).json({ error: "Ошибка сервера" });
    }
});

module.exports = router;