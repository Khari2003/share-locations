import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để cập nhật thông tin người dùng
class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  // Thực thi để cập nhật thông tin người dùng
  Future<User> call(String id, Map<String, dynamic> userData) async {
    return await repository.updateUser(id, userData);
  }
}