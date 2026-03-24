// lib/authMiddleware.js
const jwt = require('jsonwebtoken');
const prisma = require('./prisma'); // Наш доступ к БД

const authMiddleware = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Доступ запрещен: Токен отсутствует или не в формате Bearer.' });
    }

    // Выделяем токен (убираем "Bearer ")
    const token = authHeader.split(' ')[1];

    try {
        // 1. Проверяем токен
        const secret = process.env.JWT_SECRET || 'default_fallback_secret'; // Используем секрет из .env
        const decoded = jwt.verify(token, secret);
        
        // 2. Прикрепляем ID пользователя к запросу, чтобы другие маршруты его видели
        req.userId = decoded.userId;

        // 3. Проверяем, существует ли пользователь в БД (на случай, если токен украдут или отзовут)
        const user = await prisma.user.findUnique({
            where: { id: decoded.userId }
        });

        if (!user) {
             return res.status(401).json({ error: 'Неверный токен: Пользователь не найден.' });
        }

        // Передаем управление следующему обработчику (например, на маршрут получения профиля)
        next();

    } catch (err) {
        // Ошибка верификации (токен просрочен, подделан и т.д.)
        return res.status(401).json({ error: 'Неверный токен или он истек.' });
    }
};

module.exports = authMiddleware;