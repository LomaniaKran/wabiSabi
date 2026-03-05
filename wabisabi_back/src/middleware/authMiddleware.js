const { verifyToken } = require('../config/jwtConfig');

const protect = async (req, res, next) => {
  try {
    let token;
    
    // Проверяем заголовок Authorization
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Доступ запрещён. Токен не предоставлен.'
      });
    }
    
    // Верифицируем токен
    const decoded = verifyToken(token);
    
    if (!decoded) {
      return res.status(401).json({
        success: false,
        message: 'Доступ запрещён. Недействительный токен.'
      });
    }
    
    // Добавляем ID пользователя в запрос
    req.userId = decoded.userId;
    next();
  } catch (error) {
    console.error('Ошибка аутентификации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка аутентификации'
    });
  }
};

module.exports = { protect };