import '../models/user.dart';

class MockUsers {
  static final User currentUser = User(
    id: 'sakura_art',
    username: 'Сакура Арт',
    avatarUrl: null,
    bio: 'Люблю аниме и мангу. Изучаю цифровую живопись 2 года. '
        'Всегда рада помочь и получить конструктивную критику!',
    status: 'Любитель',
    strongSides: ['Анатомия', 'Скетчинг', 'Ч/Б иллюстрация', 'Линия'],
    needHelpIn: ['Цвет', 'Фоны', 'Текстуры', 'Перспектива'],
    isAcceptingAdvice: true,
    isLookingForHelp: true,
    adviceStats: {'Анатомия': 12, 'Скетчинг': 8, 'Линия': 5},
    isCurrentUser: true,
  );

  static final User otherUser = User(
    id: 'watercolor_dreams',
    username: 'Акварельные Грёзы',
    avatarUrl: null,
    bio: 'Традиционная и цифровая акварель. '
        'Люблю природу и спокойные сюжеты. Работаю 4 года.',
    status: 'Профи',
    strongSides: ['Акварель', 'Цвет', 'Атмосфера', 'Композиция'],
    needHelpIn: ['Анатомия', 'Скетчинг'],
    isAcceptingAdvice: true,
    isLookingForHelp: false,
    adviceStats: {'Цвет': 15, 'Акварель': 10, 'Композиция': 7},
    isCurrentUser: false,
  );

  static User getUserById(String id) {
    if (id == 'sakura_art') return currentUser;
    if (id == 'watercolor_dreams') return otherUser;
    return currentUser; // fallback
  }
}