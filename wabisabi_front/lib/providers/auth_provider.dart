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
  final userRepository = ref.read(userRepositoryProvider);
  
  return await userRepository.fetchAvailableSkills();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;
  
  AuthNotifier(this._userRepository) : super(AuthState());

  // --- ЛОГИН ---
  // В методе login:
Future<void> login(String identifier, String password) async {
  try {
    final result = await _userRepository.login(identifier, password);
    final token = result['token'] as String;
    await AuthStorage.saveToken(token); // Сохраняем в SecureStorage
    await loadUserAndSetState(token); // Загружаем пользователя с новым токеном
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
    print("Attempting to load user with token: $token");
    try {
      final userDetails = await _userRepository.fetchCurrentUser();
      print("User details received from server: $userDetails");
      
      final user = User.fromJson(userDetails);
      print("User object created successfully: ${user.username}");

      state = state.copyWith(
        isAuthenticated: true,
        token: token, // Сохраняем токен в состоянии
        currentUser: user,
        error: null,
      );
      print("State updated to authenticated. isAuthenticated: ${state.isAuthenticated}");
    } catch (e) {
      // --- ЭТО САМАЯ ВАЖНАЯ ОТЛАДКА ---
      print("!!!! ERROR loading user: $e !!!!"); // Если здесь ошибка, значит токен не работает
      await AuthStorage.deleteToken(); // Удаляем невалидный токен
      state = AuthState(
        isAuthenticated: false, 
        error: "Сессия истекла. Пожалуйста, войдите снова.",
        token: null, // Сбрасываем токен в состоянии
        currentUser: null // Сбрасываем пользователя
      );
      print("Error occurred. Deleted token. State reset to logged out.");
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await AuthStorage.getToken();
    // --- ДОБАВЬ ЭТИ СТРОКИ ---
    print("--- Auth Check ---");
    print("Token retrieved from storage: $token"); 

    if (token != null) {
      // Если токен есть, пытаемся загрузить пользователя
      await loadUserAndSetState(token);
    } else {
      // Если токена нет, явно сбрасываем состояние
      state = state.copyWith(
        isAuthenticated: false, 
        currentUser: null, 
        token: null, // Важно сбросить и токен в состоянии
        error: null // Убираем предыдущие ошибки
      );
      print("No token found. Resetting state to logged out.");
    }
    print("--- Auth Check Complete ---");
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

final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).checkAuthStatus();
});