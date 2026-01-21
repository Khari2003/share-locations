import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để tạo một cuộc trò chuyện mới
class CreateConversation {
  final UserRepository repository;

  CreateConversation(this.repository);

  // Thực thi để tạo cuộc trò chuyện mới
  Future<dynamic> call(String userId, String recipientId) async {
    return await repository.createConversation(userId, recipientId);
  }
}