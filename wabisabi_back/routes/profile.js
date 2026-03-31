const express = require('express');
const router = express.Router();
const prisma = require('../lib/prisma');
const jwt = require('jsonwebtoken');

// Middleware для проверки токена
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, process.env.JWT_SECRET || 'secret', (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
};

router.get('/skills', authenticateToken, async (req, res) => {
    try {
        const skills = await prisma.skill.findMany({
            orderBy: { name: 'asc' } // Сортируем по имени для удобства
        });
        
        // Возвращаем только названия навыков
        const skillNames = skills.map(skill => skill.name);
        res.json(skillNames);
        
    } catch (e) {
        console.error("Ошибка при получении списка навыков:", e);
        res.status(500).json({ error: e.message });
    }
});

router.get('/me', authenticateToken, async (req, res) => {
    try {
        const userId = parseInt(req.user.userId);
        
        // Достаем пользователя СВЯЗИ (UserSkill -> Skill)
        const user = await prisma.user.findUnique({
            where: { id: userId },
            include: {
                userSkills: {
                    include: { skill: true }
                }
            }
        });

        if (!user) return res.status(404).json({ error: 'Пользователь не найден' });

        // Раскладываем навыки по массивам строк
        const strongSides = user.userSkills
            .filter(us => us.isStrength)
            .map(us => us.skill.name);
            
        const needHelpIn = user.userSkills
            .filter(us => !us.isStrength)
            .map(us => us.skill.name);

        // Отправляем полный объект
        res.json({
            id: user.id,
            username: user.username,
            email: user.email,
            bio: user.bio,
            strongSides: strongSides, // ТЕПЕРЬ ОНИ УХОДЯТ НА ФРОНТ
            needHelpIn: needHelpIn,   // ТЕПЕРЬ ОНИ УХОДЯТ НА ФРОНТ
            isSeekingAdvice: user.isSeekingAdvice,
            isOfferingAdvice: user.isOfferingAdvice,
            helpfulCommentsCount: user.helpfulCommentsCount,
            thanksReceivedCount: user.thanksReceivedCount,
        });
    } catch (e) {
        console.error("Ошибка GET /me:", e);
        res.status(500).json({ error: e.message });
    }
});

router.patch('/profile', authenticateToken, async (req, res) => {
    try {
        const { bio, strongSides, needHelpIn, isOfferingAdvice, isSeekingAdvice } = req.body; // <<< ПРИНИМАЕМ ИХ
        const userId = parseInt(req.user.userId); 

        await prisma.$transaction(async (tx) => {
            await tx.user.update({
                where: { id: userId },
                data: { 
                    bio,
                    isOfferingAdvice, // <<< СОХРАНЯЕМ ИХ
                    isSeekingAdvice   // <<< СОХРАНЯЕМ ИХ
                }
            });

            // 1. Обновляем био
            await tx.user.update({
                where: { id: userId },
                data: { bio }
            });

            // 2. УДАЛЯЕМ ВСЕ СТАРЫЕ СВЯЗИ ДЛЯ ЭТОГО ПОЛЬЗОВАТЕЛЯ
            await tx.userSkill.deleteMany({
                where: { userId: userId }
            });

            // 3. Функция-помощник для добавления новых связей
            async function addSkills(skillNames, isStrength) {
                if (!skillNames || skillNames.length === 0) return;
                
                for (const name of skillNames) {
                    // Находим или создаем скилл в таблице Skill
                    const skill = await tx.skill.upsert({
                        where: { name: name },
                        create: { name: name },
                        update: {}
                    });
                    
                    // Создаем новую связь (если пользователь сохраняет 10 навыков,
                    // будет создано 10 новых строк UserSkill).
                    await tx.userSkill.create({
                        data: {
                            userId: userId,
                            skillId: skill.id,
                            isStrength: isStrength
                        }
                    });
                }
            }

            // Запускаем добавление
            await addSkills(strongSides || [], true);
            await addSkills(needHelpIn || [], false);
        });

        res.json({ message: "Профиль успешно обновлен" });
    } catch (e) {
        console.error("ПОЛНАЯ ОШИБКА PRISMA ПРИ ОБНОВЛЕНИИ НАВЫКОВ:", e); 
        res.status(500).json({ error: e.message });
    }
});

module.exports = router;