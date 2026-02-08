import '../models/post.dart';

class MockPosts {
  static final List<Post> posts = [
    Post(
      id: '1',
      authorId: 'sakura_art',
      title: 'Портрет в стиле аниме',
      description: 'Работаю над новой концепцией персонажа, вдохновляюсь классикой 90-х. Пытаюсь найти баланс между стилизацией и анатомической правильностью.',
      imageUrls: [
        'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1542435503-956c469947f6?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      categories: ['Анатомия', 'Стилизация', 'Линия', 'Пропорции'],
      isAskingForHelp: true,
      question: 'Мне кажется, что-то не так с пропорциями лица, но не могу понять что именно. Подбородок слишком большой?',
    ),
    Post(
      id: '2',
      authorId: 'watercolor_dreams',
      title: 'Пейзаж с горным озером',
      description: 'Попытка цифровой живописи в акварельном стиле. Экспериментирую с текстурой бумаги и растеканием цвета.',
      imageUrls: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      categories: ['Перспектива', 'Цвет', 'Атмосфера', 'Акварель'],
      isAskingForHelp: true,
      question: 'Какие цвета лучше использовать для отражения в воде на закате? Слишком тёплые получились?',
    ),
    Post(
      id: '3',
      authorId: 'digital_wizard',
      title: 'Фан-арт Cyberpunk 2077',
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
    ),
    Post(
      id: '4',
      authorId: 'ink_master',
      title: 'Скетчи персонажей для комикса',
      description: 'Подготовка персонажей для короткого веб-комикса. Работаю над выразительными позами и динамикой.',
      imageUrls: [
        'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      categories: ['Скетчинг', 'Позы', 'Комикс', 'Динамика'],
      isAskingForHelp: true,
      question: 'Достаточно ли выразительны позы для комикса? Может, добавить больше экшена?',
    ),
    Post(
      id: '5',
      authorId: 'color_explorer',
      title: 'Эксперимент с палитрой',
      description: 'Пробую ограниченную палитру из 4 цветов. Интересно, насколько выразительно можно работать с такими ограничениями.',
      imageUrls: [
        'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      categories: ['Цвет', 'Палитра', 'Эксперимент', 'Ограничения'],
      isAskingForHelp: true,
      question: 'Достаточно ли контрастна эта палитра? Может, добавить один акцентный цвет?',
    ),
    Post(
      id: '6',
      authorId: 'sakura_art',
      title: 'Рисую кота',
      description: 'Очень кривой, но миленький котик для вас. Всем милашного дня <З',
      imageUrls: [
        'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1542435503-956c469947f6?w=800&auto=format&fit=crop',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      categories: ['Животные', 'Стилизация'],
      isAskingForHelp: false,
      question: null,
    ),
  ];

  // Метод для получения поста по ID
  static Post? getPostById(String id) {
    try {
      return posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  // Метод для получения постов с фильтром
  static List<Post> getPostsByCategory(String category) {
    return posts.where((post) => post.categories.contains(category)).toList();
  }

  // Метод для получения постов конкретного автора
  static List<Post> getPostsByAuthor(String authorId) {
    return posts.where((post) => post.authorId == authorId).toList();
  }

  // Метод для получения постов, где нужна помощь
  static List<Post> getPostsNeedingHelp() {
    return posts.where((post) => post.isAskingForHelp).toList();
  }
}