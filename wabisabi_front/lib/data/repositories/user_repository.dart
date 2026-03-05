import '../models/user.dart';
import '../mock_data/mock_users.dart';

class UserRepository {
  final List<User> _users = [];
  final String _currentUserId = 'sakura_art';

  UserRepository() {
    _init();
  }

  void _init() {
    _users.addAll(MockUsers.allUsers);
  }

  User getCurrentUser() {
    return getUserById(_currentUserId);
  }

  User getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return _users.first;
    }
  }

  bool isCurrentUser(String userId) {
    return userId == _currentUserId;
  }
}