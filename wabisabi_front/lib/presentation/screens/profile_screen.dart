import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/providers/auth_provider.dart'; // Убедись, что путь правильный
import 'package:wabisabi_front/providers/providers.dart'; // Убедись, что путь правильный
import 'login_screen.dart';

// --- ВАЖНО: Убедись, что allSkillsProvider определен в auth_provider.dart ---
// или в другом файле, который импортируется здесь (например, providers.dart).
// Если он определен отдельно, то нужен импорт этого файла.
// Пример: import 'package:wabisabi_front/providers/skills_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  bool _showAppBar = true;
  int _selectedSection = 0;
  bool _isEditing = false;
  // Временные списки для редактирования навыков
  List<String> _editingStrongSides = [];
  List<String> _editingNeedHelpIn = [];
  // Временные состояния переключателей
  bool _editingIsOfferingAdvice = false;
  bool _editingIsSeekingAdvice = false;
  // Контроллер для биографии
  final TextEditingController _bioController = TextEditingController();
  
  // Список секций для карусели
  final List<String> _sections = [
    'Общая информация',
    'Посты',
    'Советы',
    'Комментарии',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showAppBar) setState(() => _showAppBar = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showAppBar) setState(() => _showAppBar = true);
    }
  }

  // --- Метод для показа диалога выбора навыков ---
  void _showSkillPicker(
    String title,
    bool isStrongSides,
    List<String> skillsToExclude,
    List<String> allSkills, // <<< ПРИНИМАЕМ СПИСОК ВСЕХ НАВЫКОВ
  ) {
    // Временные списки для выбора (копируем из текущих редактируемых)
    List<String> tempSelected = isStrongSides ? List.from(_editingStrongSides) : List.from(_editingNeedHelpIn);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            // Используем ListView.builder для прокрутки списка навыков
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allSkills.length, // <<< ИСПОЛЬЗУЕМ ПЕРЕДАННЫЙ СПИСОК
              itemBuilder: (context, index) {
                final skill = allSkills[index]; // <<< ИСПОЛЬЗУЕМ ПЕРЕДАННЫЙ СПИСОК
                final isSelected = tempSelected.contains(skill);
                final bool isDisabled = skillsToExclude.contains(skill); // Навык уже выбран в другом разделе?
                
                return CheckboxListTile(
                  title: Text(skill),
                  value: isSelected,
                  onChanged: isDisabled 
                    ? null // Если isDisabled, делаем null, что отключает Checkbox
                    : (bool? checked) {
                      setDialogState(() { // Обновляем состояние внутри диалога
                        if (checked == true) tempSelected.add(skill);
                        else tempSelected.remove(skill);
                      });
                    },
                  subtitle: isDisabled ? const Text('Уже выбран в другом разделе', style: TextStyle(color: Colors.grey, fontSize: 10)) : null,
                  activeColor: isDisabled ? Colors.grey : AppColors.primary,
                  checkColor: isDisabled ? Colors.grey.shade400 : Colors.white,
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                setState(() { // Обновляем состояния экрана
                  if (isStrongSides) _editingStrongSides = tempSelected;
                  else _editingNeedHelpIn = tempSelected;
                });
                Navigator.pop(context); // Закрываем диалог
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'эксперт': return const Color(0xFF9C27B0).withOpacity(0.8);
      case 'профи': return const Color(0xFF2196F3).withOpacity(0.8);
      case 'любитель': return const Color(0xFF4CAF50).withOpacity(0.8);
      case 'новичок': return const Color(0xFFFF9800).withOpacity(0.8);
      default: return AppColors.primary.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    // Проверяем авторизацию и наличие данных пользователя
    if (!authState.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Определяем, является ли профиль текущего пользователя
    final isOwnProfile = user.id == widget.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280.0,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: AppColors.textPrimary,
              ),
              centerTitle: true,
              // Показываем индикатор прогресса только если AppBar свернут
              title: _showAppBar ? Center(child: Container(height: 4, width: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(2)))) : null,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildProfileHeader(user), // Отображаем шапку профиля
              ),
              // Карусель секций под шапкой
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildSectionCarousel(),
              ),
            ),
          ];
        },
        // Основное содержимое (выбранная секция)
        body: _buildSelectedSection(isOwnProfile, user),
      ),
    );
  }

  // --- Отображение шапки профиля (аватар, имя, статус, теги) ---
  Widget _buildProfileHeader(User user) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 70), // Место для статус-бара
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: user.avatarUrl != null
                      ? ClipOval(child: Image.network(user.avatarUrl!, fit: BoxFit.cover))
                      : Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(width: 20),
                // Имя, статус и теги
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 6),
                      // Статус (Эксперт/Профи и т.д.)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(user.status, style: TextStyle(color: _getStatusColor(user.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      // Теги "Даю советы" / "Ищу советы"
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // --- "Даю советы" ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: user.isOfferingAdvice ? AppColors.primary.withOpacity(0.15) : AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: user.isOfferingAdvice ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isOfferingAdvice ? Icons.thumb_up : Icons.thumb_down,
                                  size: 14,
                                  color: user.isOfferingAdvice ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(user.isOfferingAdvice ? 'Даю советы' : 'Не даю советов', style: TextStyle(color: user.isOfferingAdvice ? AppColors.primary : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          // --- "Ищу советы" ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: user.isSeekingAdvice 
                                  ? AppColors.primary.withOpacity(0.15) 
                                  : AppColors.textSecondary.withOpacity(0.1), // Серый фон
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: user.isSeekingAdvice 
                                    ? AppColors.primary 
                                    : AppColors.textSecondary.withOpacity(0.5), // Серая рамка
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isSeekingAdvice ? Icons.help_outline : Icons.lightbulb_outline,
                                  size: 14,
                                  color: user.isSeekingAdvice 
                                      ? AppColors.primary 
                                      : AppColors.textSecondary, // Серый цвет иконки
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user.isSeekingAdvice ? 'Ищу советы' : 'Не ищу советы',
                                  style: TextStyle(
                                    color: user.isSeekingAdvice 
                                        ? AppColors.primary 
                                        : AppColors.textSecondary, // Серый цвет текста
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Карусель секций (Общая информация, Посты и т.д.) ---
  Widget _buildSectionCarousel() {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider, width: 1), bottom: BorderSide(color: AppColors.divider, width: 1))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSection = index;
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _selectedSection == index ? AppColors.primary : Colors.transparent, width: 3))),
              child: Text(_sections[index], style: TextStyle(fontSize: 14, fontWeight: _selectedSection == index ? FontWeight.w600 : FontWeight.w400, color: _selectedSection == index ? AppColors.primary : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }
  
  // --- Отображение выбранной секции ---
  Widget _buildSelectedSection(bool isOwnProfile, User user) {
    return PageView(
      controller: _pageController,
      // Обработчик смены страницы
      onPageChanged: (index) {
        setState(() {
          _selectedSection = index;
          // Прокручиваем вверх при смене секции, чтобы избежать проблем с NestedScrollView
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        });
      },
      children: [
        // --- Секция "Общая информация" ---
        SingleChildScrollView( // Оборачиваем в SingleChildScrollView, чтобы избежать Overflow
          child: _buildGeneralInfoSection(user),
        ),
        // --- Остальные секции (пока заглушки) ---
        const Center(child: Text("Посты пока в разработке")),
        const Center(child: Text("Советы пока в разработке")),
        const Center(child: Text("Комментарии пока в разработке")),
      ],
    );
  }

  // --- Секция "Общая информация" ---
  Widget _buildGeneralInfoSection(User user) {
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- БИОГРАФИЯ ---
          const Text('О себе:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _isEditing
            ? TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
            : Text(user.bio ?? 'Нет информации', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),

          // --- СИЛЬНЫЕ СТОРОНЫ ---
          _buildEditableTagList(
            'Сильные стороны:',
            _isEditing ? _editingStrongSides : user.strongSides,
            () {
              ref.read(allSkillsProvider).when(
                data: (allSkills) {
                  _showSkillPicker('Выберите сильные стороны', true, _editingNeedHelpIn, allSkills);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Ошибка загрузки навыков: $err')),
              );
            },
          ),

          // --- СЛАБЫЕ СТОРОНЫ ---
          _buildEditableTagList(
            'Слабые стороны:',
            _isEditing ? _editingNeedHelpIn : user.needHelpIn,
            () {
              ref.read(allSkillsProvider).when(
                data: (allSkills) {
                  _showSkillPicker('Выберите слабые стороны', false, _editingStrongSides, allSkills);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Ошибка загрузки навыков: $err')),
              );
            },
          ),
          const SizedBox(height: 14),

          // --- ПЕРЕКЛЮЧАТЕЛИ СОВЕТОВ (В ЗАВИСИМОСТИ ОТ РЕЖИМА) ---
          // Этот блок остается как есть, так как он правильно отображает переключатели
          _isEditing ? _buildEditingAdviceToggles() : const SizedBox.shrink(),

          // --- КНОПКА РЕДАКТИРОВАТЬ/СОХРАНИТЬ ---
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_isEditing) {
                  // Если были в режиме редактирования, сохраняем изменения
                  await _saveProfile();
                }
                // Переключаем режим редактирования
                setState(() {
                  _isEditing = !_isEditing;

                  if (_isEditing) { // Если мы ВОШЛИ в режим редактирования
                    // Получаем актуальные данные пользователя из провайдера
                    final authStateInSetState = ref.read(authProvider); 
                    final latestUser = authStateInSetState.currentUser;

                    if (latestUser != null) {
                      // --- КОРРЕКТНАЯ ИНИЦИАЛИЗАЦИЯ ПРИ ВХОДЕ В РЕЖИМ ---
                      // Копируем текущие данные пользователя во временные переменные
                      _editingStrongSides = List.from(latestUser.strongSides);
                      _editingNeedHelpIn = List.from(latestUser.needHelpIn);
                      _bioController.text = latestUser.bio ?? '';
                      
                      // !!! ПРЯМО КОПИРУЕМ СОСТОЯНИЕ ИЗ ПОЛЬЗОВАТЕЛЯ !!!
                      _editingIsOfferingAdvice = latestUser.isOfferingAdvice; 
                      _editingIsSeekingAdvice = latestUser.isSeekingAdvice;   
                      
                      print("Entering edit mode. Offering: ${_editingIsOfferingAdvice}, Seeking: ${_editingIsSeekingAdvice}"); // Для отладки
                    } else {
                      // Сброс, если пользователь неожиданно стал null
                      _editingStrongSides = [];
                      _editingNeedHelpIn = [];
                      _bioController.text = '';
                      _editingIsOfferingAdvice = false;
                      _editingIsSeekingAdvice = false; // --- Убедись, что и здесь сброс ---
                      print("Entering edit mode, user is null. Resetting."); // Для отладки
                    }
                  } else {
                    final authStateInSetState = ref.read(authProvider); 
                    final latestUser = authStateInSetState.currentUser;
                    if (latestUser != null) {
                       _bioController.text = latestUser.bio ?? '';
                    } else {
                       _bioController.text = '';
                    }
                  }
                });
              },
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? 'Сохранить' : 'Редактировать профиль'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Используем primary для обоих состояний
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ПЕРЕКЛЮЧАТЕЛЕЙ СОВЕТОВ ---

  Widget _buildEditingAdviceToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Настройки советов:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Я даю советы'),
          value: _editingIsOfferingAdvice,
          onChanged: (value) => setState(() => _editingIsOfferingAdvice = value),
          secondary: Icon(_editingIsOfferingAdvice ? Icons.thumb_up : Icons.thumb_down),
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Я ищу советы'),
          value: _editingIsSeekingAdvice,
          onChanged: (value) => setState(() => _editingIsSeekingAdvice = value),
          secondary: Icon(_editingIsSeekingAdvice ? Icons.help_outline : Icons.lightbulb_outline),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЙ ВИДЖЕТ ДЛЯ ОТОБРАЖЕНИЯ СПИСКА ТЕГОВ ---
  Widget _buildEditableTagList(String title, List<String> items, VoidCallback onAddPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (_isEditing) // Показываем кнопку "+" только в режиме редактирования
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: onAddPressed, // Вызов функции, которая откроет диалог
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            // В режиме редактирования можно удалить навык, нажав на крестик
            onDeleted: _isEditing ? () => setState(() => items.remove(item)) : null,
            deleteIcon: _isEditing ? const Icon(Icons.close, size: 18) : null,
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- МЕТОД СОХРАНЕНИЯ ПРОФИЛЯ ---
  // Убедись, что этот метод присутствует в классе _ProfileScreenState
  Future<void> _saveProfile() async {
    final authRepo = ref.read(userRepositoryProvider); // Получаем репозиторий
    final authNotifier = ref.read(authProvider.notifier); // Получаем нотифаер
    final authState = ref.read(authProvider); // Получаем текущее состояние
    final currentUser = authState.currentUser;

    // Если пользователя нет, выходим
    if (currentUser == null) return;

    try {
      // Собираем данные для отправки на сервер
      final dataToSend = {
        'bio': _bioController.text,
        'strongSides': _editingStrongSides,
        'needHelpIn': _editingNeedHelpIn,
        'isOfferingAdvice': _editingIsOfferingAdvice,
        'isSeekingAdvice': _editingIsSeekingAdvice,
      };

      // Отправляем данные на сервер
      await authRepo.updateProfile(dataToSend);
      
      // Получаем токен и обновляем состояние приложения, чтобы UI отобразил новые данные
      final token = authState.token;
      if (token != null) {
          await authNotifier.loadUserAndSetState(token); 
      }

      // Показываем уведомление об успехе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно сохранен!')),
        );
      }

    } catch (e) {
      // Показываем уведомление об ошибке, если сохранение не удалось
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }
}