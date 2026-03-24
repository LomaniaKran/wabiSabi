import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/providers/auth_provider.dart';
import 'package:wabisabi_front/providers/providers.dart';
import 'login_screen.dart';

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
  List<String> _editingStrongSides = [];
  List<String> _editingNeedHelpIn = [];
  final TextEditingController _bioController = TextEditingController();
  
  // Мастер-лист доступных навыков
  final List<String> _allAvailableSkills = [
    'Анатомия', 'Цвет', 'Композиция', 'Скетчинг', 'Перспектива', 
    'Дизайн', 'Светотень', 'Линия', 'Акварель', 'Цифровая живопись'
  ];

  final List<String> _sections = [
    'Общая информация',
    'Посты',
    'Советы',
    'Комментарии',
  ];

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

  void _showSkillPicker(String title, bool isStrongSides, List<String> skillsToExclude) {
    // Временные списки для выбора
    List<String> tempSelected = isStrongSides ? List.from(_editingStrongSides) : List.from(_editingNeedHelpIn);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allAvailableSkills.length,
              itemBuilder: (context, index) {
                final skill = _allAvailableSkills[index];
                final isSelected = tempSelected.contains(skill);
                
                // --- НОВЫЙ БЛОК: Проверяем, нужно ли блокировать этот навык ---
                final bool isDisabled = skillsToExclude.contains(skill);
                
                return CheckboxListTile(
                  title: Text(skill),
                  value: isSelected,
                  onChanged: isDisabled 
                    ? null // Если isDisabled, делаем null, что отключает Checkbox
                    : (bool? checked) {
                      setDialogState(() {
                        if (checked == true) tempSelected.add(skill);
                        else tempSelected.remove(skill);
                      });
                    },
                  // Дополнительно делаем текст неактивным, как ты просила
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
                setState(() {
                  if (isStrongSides) _editingStrongSides = tempSelected;
                  else _editingNeedHelpIn = tempSelected;
                });
                Navigator.pop(context);
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

    if (!authState.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              title: _showAppBar ? Center(child: Container(height: 4, width: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(2)))) : null,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildProfileHeader(user),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildSectionCarousel(),
              ),
            ),
          ];
        },
        body: _buildSelectedSection(isOwnProfile, user),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 70),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: user.avatarUrl != null 
                      ? ClipOval(child: Image.network(user.avatarUrl!, fit: BoxFit.cover))
                      : Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(color: _getStatusColor(user.status).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(user.status, style: TextStyle(color: _getStatusColor(user.status), fontSize: 12, fontWeight: FontWeight.w600)),
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

  Widget _buildSelectedSection(bool isOwnProfile, User user) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _selectedSection = index),
      children: [
        _buildGeneralInfoSection(user),
        const Center(child: Text("Посты пока в разработке")),
        const Center(child: Text("Советы пока в разработке")),
        const Center(child: Text("Комментарии пока в разработке")),
      ],
    );
  }

  Widget _buildGeneralInfoSection(User user) {
    // Инициализируем контроллер текстом из юзера, если еще не сделали
    if (_bioController.text.isEmpty && user.bio != null) {
      _bioController.text = user.bio!;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('О себе:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          
          // РЕЖИМ РЕДАКТИРОВАНИЯ
          _isEditing 
            ? TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
            : Text(user.bio ?? 'Нет информации', style: const TextStyle(fontSize: 14)),
          
          const SizedBox(height: 20),

          // СИЛЬНЫЕ СТОРОНЫ
          _buildEditableTagList(
            'Сильные стороны:', 
            _isEditing ? _editingStrongSides : user.strongSides,
            () => _showSkillPicker(
              'Выберите сильные стороны', 
              true,
              _isEditing ? _editingNeedHelpIn : const [] // Исключаем то, что выбрано в "Слабых сторонах"
            ), 
          ),

          // СЛАБЫЕ СТОРОНЫ
          _buildEditableTagList(
            'Слабые стороны:', 
            _isEditing ? _editingNeedHelpIn : user.needHelpIn,
            () => _showSkillPicker(
              'Выберите слабые стороны', 
              false,
              _isEditing ? _editingStrongSides : const [] // Исключаем то, что выбрано в "Сильных сторонах"
            ),
          ),

          const SizedBox(height: 32),
          
          // КНОПКА
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_isEditing) {
                  // НАЖАТА КНОПКА "СОХРАНИТЬ"
                  await _saveProfile(); 
                }
                
                // Всегда переключаем режим
                setState(() {
                  _isEditing = !_isEditing;
                  // Если вышли из режима редактирования, сбрасываем контроллер биографии на старое значение
                  if (!_isEditing && user.bio != null) {
                      _bioController.text = user.bio!;
                  }
                });
              },
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? 'Сохранить' : 'Редактировать профиль'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? AppColors.primary : AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTagList(String title, List<String> items, VoidCallback onAddPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: onAddPressed,
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
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Future<void> _saveProfile() async {
    final authRepo = ref.read(userRepositoryProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider); // Получаем состояние
    final currentUser = authState.currentUser;

    if (currentUser == null) return;

    try {
      final dataToSend = {
        'bio': _bioController.text,
        'strongSides': _editingStrongSides, // <<< ИСПОЛЬЗУЕМ ВРЕМЕННЫЙ СПИСОК
        'needHelpIn': _editingNeedHelpIn,   // <<< ИСПОЛЬЗУЕМ ВРЕМЕННЫЙ СПИСОК
        'isOfferingAdvice': currentUser.isOfferingAdvice, // Передаем текущее значение, пока не реализуем UI для него
      };

      await authRepo.updateProfile(dataToSend);
      
      final token = authState.token;
      if (token != null) {
          await authNotifier.loadUserAndSetState(token); // Загружаем обновленный профиль
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно сохранен!')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }
}