import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để lấy danh sách tất cả người dùng
class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  // Thực thi để lấy danh sách người dùng
  Future<Either<Failure, List<User>>> call() async {
    return await repository.getUsers();
  }
}