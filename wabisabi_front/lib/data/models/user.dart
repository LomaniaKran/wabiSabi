class User {
  final String id;
  final String username;
  final String email; // Добавлено
  final String? avatarUrl;
  final String? bio;
  final String status;
  final List<String> strongSides;
  final List<String> needHelpIn;
  final bool isAcceptingAdvice;
  final bool isLookingForHelp;
  final Map<String, int> adviceStats;
  final bool isCurrentUser;
  
  // Новые поля для БД
  final bool isSeekingAdvice;
  final bool isOfferingAdvice;
  final int helpfulCommentsCount;
  final int thanksReceivedCount;

  const User({
    required this.id,
    required this.username,
    this.email = '', // Значение по умолчанию
    this.avatarUrl,
    this.bio,
    required this.status,
    required this.strongSides,
    required this.needHelpIn,
    required this.isAcceptingAdvice,
    required this.isLookingForHelp,
    required this.adviceStats,
    required this.isCurrentUser,
    // Новые поля с дефолтными значениями
    this.isSeekingAdvice = true,
    this.isOfferingAdvice = false,
    this.helpfulCommentsCount = 0,
    this.thanksReceivedCount = 0,
  });

  // Этот метод нужен для связи с бэкендом
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'] as String,
      email: json['email'] ?? '',
      bio: json['bio'] as String?,
      status: 'Художник',
      
      // Списки навыков
      strongSides: List<String>.from(json['strongSides'] ?? []),
      needHelpIn: List<String>.from(json['needHelpIn'] ?? []),
      
      // --- ТЕ САМЫЕ ОБЯЗАТЕЛЬНЫЕ ПОЛЯ, КОТОРЫХ НЕ ХВАТАЛО ---
      // Мы берем данные из JSON, который прислал сервер
      isAcceptingAdvice: json['isOfferingAdvice'] ?? true, 
      isLookingForHelp: json['isSeekingAdvice'] ?? true,
      
      // Доп поля
      adviceStats: {}, // Пока оставляем пустым, так как с сервера не приходит
      isCurrentUser: false,
    );
  }
}