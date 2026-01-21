import 'package:my_app/domain/repositories/userRepository.dart';

// Use case để lấy danh sách đánh giá của người dùng
class GetUserReviews {
  final UserRepository repository;

  GetUserReviews(this.repository);

  // Thực thi để lấy danh sách đánh giá của người dùng
  Future<List<dynamic>> call(String id) async {
    return await repository.getUserReviews(id);
  }
}