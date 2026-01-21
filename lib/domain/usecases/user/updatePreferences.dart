import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để cập nhật sở thích của người dùng
class UpdatePreferences {
  final UserRepository repository;

  UpdatePreferences(this.repository);

  // Thực thi để cập nhật sở thích người dùng
  Future<User> call(String id, Map<String, dynamic> preferences) async {
    return await repository.updatePreferences(id, preferences);
  }
}