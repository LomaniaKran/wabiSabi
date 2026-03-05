class Post {
  final String id;
  final String authorId;
  final String? title; // Делаем необязательным
  final String description; // Делаем обязательным
  final List<String> imageUrls;
  final DateTime? createdAt;
  final List<String> categories;
  final bool isAskingForHelp;
  final String? question;
  int commentCount;

  Post({
    required this.id,
    required this.authorId,
    this.title, // Может быть null
    required this.description, // Обязательное поле
    required this.imageUrls,
    this.createdAt,
    required this.categories,
    required this.isAskingForHelp,
    this.question,
    this.commentCount = 0,
  });

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

  Post copyWith({int? commentCount}) {
    return Post(
      id: id,
      authorId: authorId,
      title: title,
      description: description,
      imageUrls: imageUrls,
      createdAt: createdAt,
      categories: categories,
      isAskingForHelp: isAskingForHelp,
      question: question,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}