import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để lấy danh sách cuộc trò chuyện của người dùng
class GetConversations {
  final UserRepository repository;

  GetConversations(this.repository);

  // Thực thi để lấy danh sách cuộc trò chuyện
  Future<List<dynamic>> call(String userId) async {
    return await repository.getConversations(userId);
  }
}