// wabisabi_back/routes/posts.js
const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const jwt = require('jsonwebtoken'); // Для проверки токена

// Middleware для аутентификации (скопируй из auth.js или используй общий файл)
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) return res.sendStatus(401); // Если нет токена

    jwt.verify(token, process.env.JWT_SECRET || 'secret', (err, user) => {
        if (err) return res.sendStatus(403); // Если токен недействителен
        req.user = user; // Добавляем user ID в запрос
        next();
    });
};

// --- CRUD ОПЕРАЦИИ ДЛЯ ПОСТОВ ---

// GET /posts - Получить все посты (или с пагинацией/фильтрами)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const posts = await prisma.post.findMany({
            include: {
                author: { select: { id: true, username: true, avatarUrl: true, status: true } }, // Присоединяем автора
                attachments: true, // Присоединяем картинки
                categories: { select: { name: true } }, // Присоединяем названия категорий
                _count: { select: { comments: true } } // Получаем количество комментариев
            },
            orderBy: { createdAt: 'desc' } // Сортируем по дате создания
        });

        // Преобразуем данные для соответствия Flutter модели
        const formattedPosts = posts.map(post => ({
            id: post.id.toString(),
            authorId: post.authorId.toString(),
            author: post.author, // Передаем объект автора
            title: post.title,
            description: post.content,
            imageUrls: post.attachments.map(att => att.fileUrl),
            createdAt: post.createdAt.toISOString(),
            categories: post.categories.map(cat => cat.name),
            isAskingForHelp: post.isAskingForHelp,
            question: post.question,
            commentCount: post._count.comments,
            // Добавь здесь другие поля, если они нужны на Flutter
        }));

        res.json(formattedPosts);
    } catch (e) {
        console.error("Ошибка получения постов:", e);
        res.status(500).json({ error: "Ошибка сервера при получении постов" });
    }
});

// GET /posts/:id - Получить один пост по ID
router.get('/:id', authenticateToken, async (req, res) => {
    const postId = parseInt(req.params.id);
    try {
        const post = await prisma.post.findUnique({
            where: { id: postId },
            include: {
                author: { select: { id: true, username: true, avatarUrl: true, status: true } },
                attachments: true,
                categories: { select: { name: true } },
                _count: { select: { comments: true } }
            }
        });

        if (!post) {
            return res.status(404).json({ error: "Пост не найден" });
        }
        
        // Форматируем пост для Flutter
        const formattedPost = {
            id: post.id.toString(),
            authorId: post.authorId.toString(),
            author: post.author,
            title: post.title,
            description: post.content,
            imageUrls: post.attachments.map(att => att.fileUrl),
            createdAt: post.createdAt.toISOString(),
            categories: post.categories.map(cat => cat.name),
            isAskingForHelp: post.isAskingForHelp,
            question: post.question,
            commentCount: post._count.comments,
            feedbackLevel: post.feedbackLevel,
            allowDownload: post.allowDownload,
            commentPrivacy: post.commentPrivacy,
        };

        res.json(formattedPost);
    } catch (e) {
        console.error(`Ошибка получения поста ${postId}:`, e);
        res.status(500).json({ error: "Ошибка сервера при получении поста" });
    }
});


// POST /posts - Создать новый пост
router.post('/', authenticateToken, async (req, res) => {
    // console.log("Received POST /posts data:", req.body); // Логирование данных
    const { 
        title, 
        content, // Теперь мы ожидаем 'content', так как Flutter шлет именно его
        imageUrls, 
        categories, 
        isAskingForHelp, 
        question, 
        feedbackLevel, 
        allowDownload, 
        commentPrivacy 
    } = req.body;
    
    const authorId = parseInt(req.user.userId); // ID автора из токена

    // Валидация: description обязателен
    if (!content) {
        return res.status(400).json({ error: "Описание поста (content) обязательно" });
    }

    try {
        // --- Обработка категорий ---
        const categoryRecords = [];
        if (categories && Array.isArray(categories)) { // Проверяем, что это массив
            for (const catName of categories) {
                const category = await prisma.postCategory.upsert({
                    where: { name: catName },
                    create: { name: catName },
                    update: { name: catName },
                });
                categoryRecords.push(category);
            }
        }
        
        // --- Создание поста ---
        const newPost = await prisma.post.create({
            data: {
                authorId: authorId,
                title: title,
                content: content, 
                isAskingForHelp: isAskingForHelp ?? false,
                question: question,
                feedbackLevel: feedbackLevel ?? "constructive",
                allowDownload: allowDownload ?? true,
                commentPrivacy: commentPrivacy ?? "ALL",
                
                // --- БЕЗОПАСНОЕ СОЗДАНИЕ ВЛОЖЕНИЙ ---
                attachments: {
                    create: (imageUrls || []).map(url => ({ url: url, fileType: 'image' })) 
                },
                
                // --- БЕЗОПАСНАЯ СВЯЗЬ КАТЕГОРИЙ ---
                categories: {
                    connect: categoryRecords.map(cat => ({ id: cat.id })) 
                }
            },
            include: { 
                author: { select: { id: true, username: true, avatarUrl: true, status: true } },
                attachments: true,
                categories: { select: { name: true } },
                _count: { select: { comments: true } }
            }
        });

        // --- Форматируем ответ для Flutter ---
        const formattedPost = {
            id: newPost.id.toString(),
            authorId: newPost.authorId.toString(),
            author: newPost.author, // Возвращаем объект автора
            title: newPost.title,
            description: newPost.content,
            imageUrls: newPost.attachments.map(att => att.url),
            createdAt: newPost.createdAt.toISOString(),
            categories: newPost.categories.map(cat => cat.name),
            isAskingForHelp: newPost.isAskingForHelp,
            question: newPost.question,
            commentCount: newPost._count.comments,
            feedbackLevel: newPost.feedbackLevel,
            allowDownload: newPost.allowDownload,
            commentPrivacy: newPost.commentPrivacy,
        };

        res.status(201).json(formattedPost); // 201 Created

    } catch (e) {
        console.error("Ошибка создания поста:", e);
        // Более детальное логирование ошибки
        if (e.code === 'P2002') { // Prisma error for unique constraint violation
             res.status(409).json({ error: "Конфликт: возможно, такой пост уже существует или нарушены уникальные поля." });
        } else if (e.message.includes("is missing a required field")) {
             res.status(400).json({ error: "Отсутствует обязательное поле для создания поста." });
        } else {
             res.status(500).json({ error: "Ошибка сервера при создании поста" });
        }
    }
});

// --- ВАЖНО: ВАШИ СУЩЕСТВУЮЩИЕ МАРШРУТЫ ---
// Убедись, чтоauthenticateToken, router.get('/me', ...), router.patch('/profile', ...)
// также присутствуют и работают.

// --- КОНЕЦ CRUD ОПЕРАЦИЙ ---

module.exports = router;