import 'package:dartz/dartz.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/user/userDatasource.dart';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// Lớp triển khai giao diện UserRepository để xử lý các thao tác liên quan đến người dùng
class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  // Lấy danh sách tất cả người dùng
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final userModels = await dataSource.getUsers();
      final users = userModels.map((userModel) => User(
            id: userModel.id,
            name: userModel.name,
            email: userModel.email,
            gender: userModel.gender,
            phone: userModel.phone,
            profilePhoto: userModel.profilePhoto,
            storyDate: userModel.storyDate,
            isAdmin: userModel.isAdmin,
            location: userModel.location,
            favoriteStores: userModel.favoriteStores,
            wishList: userModel.wishList,
            conversations: userModel.conversations,
            resetPasswordOtp: userModel.resetPasswordOtp,
            resetPasswordOtpExpiration: userModel.resetPasswordOtpExpiration,
          )).toList();
      return Right(users);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Không thể lấy danh sách người dùng'));
    }
  }

  @override
  // Lấy thông tin người dùng theo ID
  Future<User> getUserById(String id) async {
    if (id.isEmpty) {
      throw ServerFailure('ID người dùng không được để trống');
    }
    try {
      final userModel = await dataSource.getUserById(id);
      return User(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        gender: userModel.gender,
        phone: userModel.phone,
        profilePhoto: userModel.profilePhoto,
        storyDate: userModel.storyDate,
        isAdmin: userModel.isAdmin,
        location: userModel.location,
        favoriteStores: userModel.favoriteStores,
        wishList: userModel.wishList,
        conversations: userModel.conversations,
        resetPasswordOtp: userModel.resetPasswordOtp,
        resetPasswordOtpExpiration: userModel.resetPasswordOtpExpiration,
      );
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể lấy thông tin người dùng');
    }
  }

  @override
  // Cập nhật thông tin người dùng
  Future<User> updateUser(String id, Map<String, dynamic> userData) async {
    if (id.isEmpty) {
      throw ServerFailure('ID người dùng không được để trống');
    }
    try {
      final userModel = await dataSource.updateUser(id, userData);
      return User(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        gender: userModel.gender,
        phone: userModel.phone,
        profilePhoto: userModel.profilePhoto,
        storyDate: userModel.storyDate,
        isAdmin: userModel.isAdmin,
        location: userModel.location,
        favoriteStores: userModel.favoriteStores,
        wishList: userModel.wishList,
        conversations: userModel.conversations,
        resetPasswordOtp: userModel.resetPasswordOtp,
        resetPasswordOtpExpiration: userModel.resetPasswordOtpExpiration,
      );
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể cập nhật thông tin người dùng');
    }
  }

  @override
  // Cập nhật sở thích của người dùng
  Future<User> updatePreferences(String id, Map<String, dynamic> preferences) async {
    if (id.isEmpty) {
      throw ServerFailure('ID người dùng không được để trống');
    }
    try {
      final userModel = await dataSource.updatePreferences(id, preferences);
      return User(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        gender: userModel.gender,
        phone: userModel.phone,
        profilePhoto: userModel.profilePhoto,
        storyDate: userModel.storyDate,
        isAdmin: userModel.isAdmin,
        location: userModel.location,
        favoriteStores: userModel.favoriteStores,
        wishList: userModel.wishList,
        conversations: userModel.conversations,
        resetPasswordOtp: userModel.resetPasswordOtp,
        resetPasswordOtpExpiration: userModel.resetPasswordOtpExpiration,
      );
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể cập nhật sở thích');
    }
  }

  @override
  // Lấy danh sách đánh giá của người dùng
  Future<List<dynamic>> getUserReviews(String id) async {
    if (id.isEmpty) {
      throw ServerFailure('ID người dùng không được để trống');
    }
    try {
      return await dataSource.getUserReviews(id);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể lấy danh sách đánh giá');
    }
  }

  @override
  // Tạo một cuộc trò chuyện mới
  Future<dynamic> createConversation(String userId, String recipientId) async {
    if (userId.isEmpty || recipientId.isEmpty) {
      throw ServerFailure('ID người dùng hoặc người nhận không được để trống');
    }
    try {
      return await dataSource.createConversation(userId, recipientId);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể tạo cuộc trò chuyện');
    }
  }

  @override
  // Lấy danh sách cuộc trò chuyện của người dùng
  Future<List<dynamic>> getConversations(String userId) async {
    if (userId.isEmpty) {
      throw ServerFailure('ID người dùng không được để trống');
    }
    try {
      return await dataSource.getConversations(userId);
    } catch (e) {
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Không thể lấy danh sách cuộc trò chuyện');
    }
  }
}