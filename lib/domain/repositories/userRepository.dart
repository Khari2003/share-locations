import 'package:my_app/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/failures.dart';

// Giao diện định nghĩa các phương thức để tương tác với dữ liệu người dùng trong domain layer
abstract class UserRepository {
  // Lấy danh sách tất cả người dùng
  Future<Either<Failure, List<User>>> getUsers();
  // Lấy thông tin người dùng theo ID
  Future<User> getUserById(String id);
  // Cập nhật thông tin người dùng
  Future<User> updateUser(String id, Map<String, dynamic> userData);
  // Cập nhật sở thích của người dùng
  Future<User> updatePreferences(String id, Map<String, dynamic> preferences);
  // Lấy danh sách đánh giá của người dùng
  Future<List<dynamic>> getUserReviews(String id);
  // Tạo một cuộc trò chuyện mới
  Future<dynamic> createConversation(String userId, String recipientId);
  // Lấy danh sách cuộc trò chuyện của người dùng
  Future<List<dynamic>> getConversations(String userId);
}