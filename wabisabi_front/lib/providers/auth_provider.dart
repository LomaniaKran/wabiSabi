import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/providers/providers.dart';
import '../data/models/user.dart'; // Убедись, что путь верный!
import '../data/repositories/user_repository.dart'; // Импортируем репозиторий
import '../data/auth_storage.dart'; // <-- Новый импорт

class AuthState {
  final bool isAuthenticated;
  final User? currentUser;
  final String? token;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.currentUser,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? currentUser,
    String? token,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

final allSkillsProvider = FutureProvider<List<String>>((ref) async {
  // Получаем экземпляр UserRepository
  final userRepository = ref.read(userRepositoryProvider);
  
  // Провайдер сам позаботится о запросе токена и обработке ошибок
  // Если репозиторий вернет ошибку, провайдер будет в состоянии 'error'
  return await userRepository.fetchAvailableSkills();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;
  
  AuthNotifier(this._userRepository) : super(AuthState());

  // --- ЛОГИН ---
  Future<void> login(String email, String password) async {
    try {
      final result = await _userRepository.login(email, password);
      final token = result['token'] as String;
      
      // Вызываем правильный метод, который существует в твоем коде
      await loadUserAndSetState(token); 
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- РЕГИСТРАЦИЯ ---
  Future<void> register(String username, String email, String password, String? bio) async {
    try {
      await _userRepository.register(username, email, password, bio ?? "");
      
      // После регистрации логинимся
      final result = await _userRepository.login(email, password);
      final token = result['token'] as String;
      
      await loadUserAndSetState(token); 
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- ВНУТРЕННИЙ МЕТОД ЗАГРУЗКИ ПРОФИЛЯ (тот самый, что у тебя есть) ---
  Future<void> loadUserAndSetState(String token) async {
    try {
      // 1. Запрашиваем полные данные пользователя с бэкенда
      final userDetails = await _userRepository.fetchCurrentUser();
      
      // 2. Создаем объект User из JSON
      final user = User.fromJson(userDetails);
      
      // 3. Обновляем состояние
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        currentUser: user,
        error: null,
      );
    } catch (e) {
      print("Ошибка загрузки профиля: $e");
      await AuthStorage.deleteToken(); // Очищаем токен
      state = AuthState(error: "Сессия истекла. Пожалуйста, войдите снова.");
    }
  }

  // --- ВЫХОД ---
  void logout() {
    AuthStorage.deleteToken();
    state = AuthState();
  }
}

// Обновляем провайдер, чтобы он получал репозиторий
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider));
});