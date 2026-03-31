
class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String status; // Например, "Художник", "Эксперт"
  final List<String> strongSides; // Сильные стороны
  final List<String> needHelpIn; // Слабые стороны / В чем нужна помощь
  
  // --- ПОЛЯ, СИНХРОНИЗИРОВАННЫЕ С БЭКЕНДОМ ---
  final bool isSeekingAdvice; // Пользователь ищет советы
  final bool isOfferingAdvice; // Пользователь дает советы

  // --- ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ ИЗ БД ---
  final int helpfulCommentsCount;
  final int thanksReceivedCount;

  // --- ПОЛЯ, КОТОРЫЕ ПОКА НЕ ИСПОЛЬЗУЮТСЯ ИЛИ ЯВЛЯЮТСЯ ЗАГЛУШКАМИ ---
  final Map<String, int> adviceStats; // Статистика советов (пока заглушка)
  final bool isCurrentUser; // Нужно ли показать кнопку "Редактировать" (определяется на экране)

  const User({
    required this.id,
    required this.username,
    this.email = '', // Значение по умолчанию
    this.avatarUrl,
    this.bio,
    required this.status,
    required this.strongSides,
    required this.needHelpIn,
    required this.isSeekingAdvice,    // Теперь это required
    required this.isOfferingAdvice,  // Теперь это required
    required this.helpfulCommentsCount,
    required this.thanksReceivedCount,
    // Остальные поля с дефолтными значениями
    this.adviceStats = const {}, // Используем const {} для неизменяемого пустого Map
    this.isCurrentUser = false,
  });

  // --- ФАБРИКА ДЛЯ ПАРСИНГА JSON ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'] as String,
      email: json['email'] ?? '', // Используем ?? '' для безопасного доступа
      bio: json['bio'] as String?,
      status: json['status'] ?? 'Художник', // Получаем статус с сервера, если есть, иначе "Художник"
      
      // --- КОРРЕКТНЫЙ ПАРСИНГ СПИСКОВ НАВЫКОВ ---
      // Используем List<String>.from() для безопасного преобразования
      strongSides: List<String>.from(json['strongSides'] ?? []), 
      needHelpIn: List<String>.from(json['needHelpIn'] ?? []),
      
      // --- КОРРЕКТНЫЙ ПАРСИНГ ПОЛЕЙ СОВЕТОВ ---
      // Используем имена полей, которые приходят с сервера
      isOfferingAdvice: json['isOfferingAdvice'] ?? false, // Парсим 'isOfferingAdvice'
      isSeekingAdvice: json['isSeekingAdvice'] ?? false,   // Парсим 'isSeekingAdvice'
      
      // --- ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ ---
      helpfulCommentsCount: json['helpfulCommentsCount'] ?? 0,
      thanksReceivedCount: json['thanksReceivedCount'] ?? 0,
      
      // --- ЗАГЛУШКИ ---
      adviceStats: {}, // Заглушка
      isCurrentUser: false, // Определяется на экране профиля, а не в модели
    );
  }
}