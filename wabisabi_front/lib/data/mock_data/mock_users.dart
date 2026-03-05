import '../models/user.dart';

class MockUsers {
  // Определяем всех пользователей
  static final User sakuraArt = User(
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
    isCurrentUser: true, // Только Сакура Арт - текущий пользователь
  );

  static final User watercolorDreams = User(
    id: 'watercolor_dreams',
    username: 'Акварельные Грёзы',
    avatarUrl: null,
    bio: 'Традиционная и цифровая акварель. '
        'Люблю природу и спокойные сюжеты. Работаю 4 года.',
    status: 'Профи',
    strongSides: ['Акварель', 'Цвет', 'Атмосфера', 'Композиция'],
    needHelpIn: ['Анатомия', 'Скетчинг', 'Динамика'],
    isAcceptingAdvice: true,
    isLookingForHelp: false,
    adviceStats: {'Цвет': 15, 'Акварель': 10, 'Композиция': 7},
    isCurrentUser: false,
  );

  static final User digitalWizard = User(
    id: 'digital_wizard',
    username: 'Цифровой Волшебник',
    avatarUrl: null,
    bio: 'Специализируюсь на sci-fi и cyberpunk арте. '
        'Работаю в индустрии 5 лет. Люблю сложные технические детали.',
    status: 'Профи',
    strongSides: ['Дизайн', 'Неон', 'Свет', 'Техника', 'Перспектива'],
    needHelpIn: ['Традиционные техники', 'Быстрый скетчинг'],
    isAcceptingAdvice: true,
    isLookingForHelp: true,
    adviceStats: {'Дизайн': 25, 'Свет': 18, 'Техника': 12},
    isCurrentUser: false,
  );

  static final User inkMaster = User(
    id: 'ink_master',
    username: 'Мастер Чернил',
    avatarUrl: null,
    bio: 'Концепт-художник. Работаю в игровой индустрии. '
        'Предпочитаю традиционные материалы.',
    status: 'Эксперт',
    strongSides: ['Концепт-арт', 'Тушь', 'Графика', 'Композиция'],
    needHelpIn: ['Цифровая живопись', 'Анимация'],
    isAcceptingAdvice: false,
    isLookingForHelp: true,
    adviceStats: {'Концепт-арт': 30, 'Композиция': 20},
    isCurrentUser: false,
  );

  static final User colorExplorer = User(
    id: 'color_explorer',
    username: 'Искатель Цветов',
    avatarUrl: null,
    bio: 'Экспериментирую с цветом и светом. '
        'Считаю, что ограничения рождают креативность.',
    status: 'Любитель',
    strongSides: ['Колористика', 'Эксперименты', 'Светотень'],
    needHelpIn: ['Анатомия', 'Пропорции', 'Фоны'],
    isAcceptingAdvice: true,
    isLookingForHelp: true,
    adviceStats: {'Колористика': 8, 'Светотень': 5},
    isCurrentUser: false,
  );

  // Список всех пользователей
  static final List<User> allUsers = [
    sakuraArt,
    watercolorDreams,
    digitalWizard,
    inkMaster,
    colorExplorer,
  ];

  // Мап для быстрого доступа по ID
  static final Map<String, User> _usersMap = {
    for (var user in allUsers) user.id: user,
  };

  static User getUserById(String id) {
    // Возвращаем пользователя по ID, если не найден - возвращаем sakuraArt как fallback
    return _usersMap[id] ?? sakuraArt;
  }

  static List<User> getOtherUsers() {
    return allUsers.where((user) => !user.isCurrentUser).toList();
  }

  // Для отладки - выводим всех пользователей
  static void printAllUsers() {
    print('Все пользователи:');
    for (var user in allUsers) {
      print('${user.id}: ${user.username} (текущий: ${user.isCurrentUser})');
    }
  }
}