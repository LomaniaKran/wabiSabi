import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/providers/auth_provider.dart';
import 'package:wabisabi_front/presentation/screens/login_screen.dart';
import 'package:wabisabi_front/presentation/screens/feed_screen.dart'; // Или твой главный экран

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Наблюдаем за провайдером, который запускает checkAuthStatus
    final startup = ref.watch(appStartupProvider);
    // Наблюдаем за основным состоянием авторизации
    final authState = ref.watch(authProvider);

    return startup.when(
      // Пока идет первая проверка
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())), 
      // Если при проверке произошла ошибка (например, сетевая)
      error: (err, stack) {
        print("Startup provider error: $err");
        return const LoginScreen(); // Идем на логин
      },
      // Когда проверка завершена (success или fail)
      data: (_) {
        // Теперь смотрим, авторизован ли пользователь
        return authState.isAuthenticated ? const FeedScreen() : const LoginScreen();
      },
    );
  }
}