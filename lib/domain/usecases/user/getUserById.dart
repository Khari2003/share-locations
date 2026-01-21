import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để lấy thông tin người dùng theo ID
class GetUserById {
  final UserRepository repository;

  GetUserById(this.repository);

  // Thực thi để lấy thông tin người dùng theo ID
  Future<User> call(String id) async {
    return await repository.getUserById(id);
  }
}