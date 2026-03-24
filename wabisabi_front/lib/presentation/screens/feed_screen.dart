import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user.dart'; 
import 'login_screen.dart';
import 'profile_screen.dart';
import '../../providers/auth_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showAppBar) setState(() => _showAppBar = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showAppBar) setState(() => _showAppBar = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // --- ВСЕ МЕТОДЫ, СВЯЗАННЫЕ С МОКАМИ (УДАЛЕНЫ ИЛИ ЗАГЛУШЕНЫ) ---
  // _deletePost, _showAboutAppDialog, _buildFeatureItem и т.д. - удалены для чистоты.
  // Если они были нужны, их нужно будет переписать позже, когда добавим PostRepository.

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;

    // 1. Проверка, авторизован ли пользователь
    if (!authState.isAuthenticated || currentUser == null) {
      // Если не авторизован, отправляем на вход
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      // Возвращаем пустой виджет, пока навигация не отработает
      return const SizedBox.shrink();
    }

    // 2. Если авторизован И currentUser существует, показываем Ленту
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: _buildDrawer(context, currentUser),
      body: _buildBody(currentUser), // Передаем реального пользователя
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        height: 4,
        width: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Поиск в разработке'))),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, User currentUser) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surface,
                  child: currentUser.avatarUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(currentUser.avatarUrl!, fit: BoxFit.cover))
                      : const Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(currentUser.username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(currentUser.status, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          
          _buildDrawerItem(icon: Icons.person_outline, title: 'Мой профиль', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: currentUser.id)));
          }),
          
          _buildDrawerItem(icon: Icons.settings_outlined, title: 'Настройки', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Настройки в разработке')))),
          _buildDrawerItem(icon: Icons.help_outline, title: 'Техподдержка', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Поддержка в разработке')))),
          
          const Divider(height: 32),
          
          _buildDrawerItem(icon: Icons.info_outline, title: 'О приложении', onTap: () { /* Оставим заглушку для About */ }),
          
          const Divider(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.exit_to_app, color: AppColors.error),
              title: Text('Выйти', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.error.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  // --- Основное тело (Body) ---
  Widget _buildBody(User currentUser) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          "✅ АВТОРИЗАЦИЯ УСПЕШНА!\n\nТеперь мы загружаем данные из вашей базы PostgreSQL.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}