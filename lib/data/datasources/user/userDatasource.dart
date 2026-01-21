import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/data/models/userModel.dart';

// Lớp trừu tượng định nghĩa các phương thức để tương tác với dữ liệu người dùng
abstract class UserDataSource {
  // Lấy danh sách tất cả người dùng
  Future<List<UserModel>> getUsers();
  // Lấy thông tin người dùng theo ID
  Future<UserModel> getUserById(String id);
  // Cập nhật thông tin người dùng
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData);
  // Cập nhật sở thích của người dùng
  Future<UserModel> updatePreferences(String id, Map<String, dynamic> preferences);
  // Lấy danh sách đánh giá của người dùng
  Future<List<dynamic>> getUserReviews(String id);
  // Tạo một cuộc trò chuyện mới
  Future<dynamic> createConversation(String userId, String recipientId);
  // Lấy danh sách cuộc trò chuyện của người dùng
  Future<List<dynamic>> getConversations(String userId);
}

// Lớp triển khai các phương thức của UserDataSource
class UserDataSourceImpl implements UserDataSource {
  final http.Client client;

  UserDataSourceImpl(this.client);

  @override
  // Lấy danh sách tất cả người dùng từ server
  Future<List<UserModel>> getUsers() async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.userById),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Chuyển đổi danh sách JSON thành danh sách UserModel
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể lấy danh sách người dùng');
    }
  }

  @override
  // Lấy thông tin chi tiết của một người dùng theo ID
  Future<UserModel> getUserById(String id) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.userById}$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Chuyển đổi JSON thành UserModel
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không tìm thấy người dùng');
    }
  }

  @override
  // Cập nhật thông tin người dùng
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await client.put(
      Uri.parse('${ApiEndpoints.userById}$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      // Trả về thông tin người dùng đã được cập nhật
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể cập nhật thông tin người dùng');
    }
  }

  @override
  // Cập nhật sở thích của người dùng
  Future<UserModel> updatePreferences(String id, Map<String, dynamic> preferences) async {
    final response = await client.put(
      Uri.parse('${ApiEndpoints.userById}$id/preferences'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(preferences),
    );

    if (response.statusCode == 200) {
      // Trả về thông tin sở thích đã được cập nhật
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể cập nhật sở thích');
    }
  }

  @override
  // Lấy danh sách đánh giá của người dùng
  Future<List<dynamic>> getUserReviews(String id) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.userById}$id/reviews'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Trả về danh sách đánh giá
      return jsonDecode(response.body);
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể lấy danh sách đánh giá');
    }
  }

  @override
  // Tạo một cuộc trò chuyện mới giữa hai người dùng
  Future<dynamic> createConversation(String userId, String recipientId) async {
    final response = await client.post(
      Uri.parse('${ApiEndpoints.userById}$userId/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recipientId': recipientId}),
    );

    if (response.statusCode == 201) {
      // Trả về thông tin cuộc trò chuyện đã được tạo
      return jsonDecode(response.body);
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể tạo cuộc trò chuyện');
    }
  }

  @override
  // Lấy danh sách tất cả cuộc trò chuyện của người dùng
  Future<List<dynamic>> getConversations(String userId) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.userById}$userId/conversations'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Trả về danh sách các cuộc trò chuyện
      return jsonDecode(response.body);
    } else {
      throw ServerException(jsonDecode(response.body)['message'] ?? 'Không thể lấy danh sách cuộc trò chuyện');
    }
  }
}