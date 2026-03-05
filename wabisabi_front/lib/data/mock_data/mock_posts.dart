import '../models/post.dart';
import 'mock_comments.dart';

class MockPosts {
  static List<Post> posts = [
    Post(
      id: '1',
      authorId: 'sakura_art',
      description: 'Работаю над новой концепцией персонажа, вдохновляюсь классикой 90-х. Пытаюсь найти баланс между стилизацией и анатомической правильностью.',
      imageUrls: [
        'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1542435503-956c469947f6?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      categories: ['Анатомия', 'Стилизация', 'Линия', 'Пропорции'],
      isAskingForHelp: true,
      question: 'Мне кажется, что-то не так с пропорциями лица, но не могу понять что именно. Подбородок слишком большой?',
      commentCount: 3, // Устанавливаем правильное количество
    ),
    Post(
      id: '2',
      authorId: 'watercolor_dreams',
      description: 'Попытка цифровой живописи в акварельном стиле. Экспериментирую с текстурой бумаги и растеканием цвета.',
      imageUrls: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      categories: ['Перспектива', 'Цвет', 'Атмосфера', 'Акварель'],
      isAskingForHelp: true,
      question: 'Какие цвета лучше использовать для отражения в воде на закате? Слишком тёплые получились?',
      commentCount: 1,
    ),
    Post(
      id: '3',
      authorId: 'digital_wizard',
      description: 'Переосмысление дизайна персонажа в своём стиле. Добавляю больше технологических элементов и неонового освещения.',
      imageUrls: [
        'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      categories: ['Дизайн', 'Колористика', 'Неон', 'Свет'],
      isAskingForHelp: false,
      question: null,
      commentCount: 0,
    ),
    Post(
      id: '4',
      authorId: 'ink_master',
      description: 'Подготовка персонажей для короткого веб-комикса. Работаю над выразительными позами и динамикой.',
      imageUrls: [
        'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      categories: ['Скетчинг', 'Позы', 'Комикс', 'Динамика'],
      isAskingForHelp: true,
      question: 'Достаточно ли выразительны позы для комикса? Может, добавить больше экшена?',
      commentCount: 0,
    ),
  ];

  static List<Post> getPostsByAuthor(String authorId) {
    return posts.where((post) => post.authorId == authorId).toList();
  }

  static Post? getPostById(String id) {
    try {
      return posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  // Метод для обновления количества комментариев
  static void updateCommentCount(String postId, int count) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index] = posts[index].copyWith(commentCount: count);
    }
  }
}