class Post {
  final String id; // ID поста (получаем как Int из БД, конвертируем в String)
  final String authorId; // ID автора (получаем как Int из БД, конвертируем в String)
  final String authorUsername; // Добавляем
  final String? authorAvatarUrl; // Добавляем
  final String description; // Основное содержимое поста (соответствует 'content' в БД)
  final List<String> imageUrls; // Список URL картинок (получаем из attachments)
  final DateTime? createdAt; // Дата создания поста
  final List<String> categories; // Список названий категорий
  final bool isAskingForHelp; // Пользователь просит о помощи
  final String? question; // Сам вопрос, если isAskingForHelp = true

  // Поля, которые есть в БД схеме
  final String feedbackLevel;
  final bool allowDownload;
  final String commentPrivacy;
  final int commentCount; // Добавим, хотя в схеме его нет напрямую, предполагаем, что будем получать из _count

  Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.description,
    required this.imageUrls,
    this.createdAt,
    required this.categories,
    required this.isAskingForHelp,
    this.question,
    // Поля из БД
    this.feedbackLevel = "constructive",
    this.allowDownload = true,
    this.commentPrivacy = "ALL",
    this.commentCount = 0, // По умолчанию 0
  });

  // --- FABRIC FROM JSON (АДАПТАЦИЯ ПОД НОВУЮ СХЕМУ БД) ---
  factory Post.fromJson(Map<String, dynamic> json) {
    // Вспомогательная функция для безопасного получения числа
    int parseToInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Парсим категории
    List<String> categories = [];
    if (json['categories'] != null && json['categories'] is List) {
      categories = List<String>.from(json['categories'].map((catJson) => 
        (catJson is Map) ? (catJson['name'] ?? '') : catJson.toString()
      ));
    }

    // Парсим attachments
    List<String> imageUrls = [];
    if (json['attachments'] != null && json['attachments'] is List) {
      imageUrls = List<String>.from(json['attachments'].map((attachJson) => 
        (attachJson is Map) ? (attachJson['url'] ?? '') : attachJson.toString()
      ));
    }

    return Post(
      id: parseToInt(json['id']).toString(),
      authorId: parseToInt(json['authorId']).toString(),
      authorUsername: json['author']?['username'] ?? 'User', 
      authorAvatarUrl: json['author']?['avatarUrl'],
      description: json['content'] as String? ?? '', 
      imageUrls: imageUrls,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      categories: categories,
      isAskingForHelp: json['isAskingForHelp'] as bool? ?? false,
      question: json['question'] as String?,
      
      feedbackLevel: json['feedbackLevel'] as String? ?? "constructive",
      allowDownload: json['allowDownload'] as bool? ?? true,
      commentPrivacy: json['commentPrivacy'] as String? ?? "ALL",
      commentCount: json['_count'] != null ? (json['_count']['comments'] ?? 0) : 0,
    );
  }

  // --- МЕТОД ДЛЯ ПРЕВРАЩЕНИЯ POST В JSON (ДЛЯ ОТПРАВКИ НА СЕРВЕР) ---
  Map<String, dynamic> toJson() {
    return {
      // ID и createdAt генерируются на сервере, не отправляем
      // 'id': int.tryParse(id), // Не нужно при создании
      'authorId': int.tryParse(authorId), // Отправляем как Int
      // 'title': title, // <<< НЕ ОТПРАВЛЯЕМ, ТАК КАК ЕГО НЕТ В БД >>>
      'content': description, // Отправляем description как content
      'isAskingForHelp': isAskingForHelp,
      'question': question,
      
      // Отправляем другие поля, если они редактируемые
      'feedbackLevel': feedbackLevel,
      'allowDownload': allowDownload,
      'commentPrivacy': commentPrivacy,
      
      // imageUrls конвертируем обратно в формат attachments для сервера
      // Предполагаем, что на сервере ожидается [{url: '...', fileType: 'image'}]
      'attachments': imageUrls.map((url) => {'url': url, 'fileType': 'image'}).toList(), 
      
      // Категории отправляем как список имен, сервер сам найдет или создаст PostCategory
      'categories': categories, 
    };
  }

  String get timeAgo {
    if (createdAt == null) return 'Недавно';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 30) return '${difference.inDays} дн назад';
    
    final months = (difference.inDays / 30).floor();
    if (months < 12) return '$months мес назад';
    
    final years = (difference.inDays / 365).floor();
    return '$years г назад';
  }

  // Метод copyWith (убедись, что он обновлен под новую модель)
  Post copyWith({int? commentCount}) {
    return Post(
      id: id,
      authorId: authorId,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      description: description,
      imageUrls: imageUrls,
      createdAt: createdAt,
      categories: categories,
      isAskingForHelp: isAskingForHelp,
      question: question,
      feedbackLevel: feedbackLevel,
      allowDownload: allowDownload,
      commentPrivacy: commentPrivacy,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}