import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/authRepository.dart';
import '../datasources/auth/authDatasource.dart';

// Implementation của AuthRepository - lớp trung gian giữa domain và data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  // Đăng nhập với email và mật khẩu
  @override
  Future<Auth> login(String email, String password) async {
    // Kiểm tra dữ liệu đầu vào không được rỗng
    if (email.isEmpty || password.isEmpty) {
      throw ServerFailure('Email and password cannot be empty');
    }
    try {
      // Gọi data source để thực hiện đăng nhập
      final authModel = await dataSource.login(email, password);
      
      // Chuyển đổi từ AuthModel (data layer) sang Auth entity (domain layer)
      return Auth(
        id: authModel.id,
        name: authModel.name,
        email: authModel.email,
        isAdmin: authModel.isAdmin,
        accessToken: authModel.accessToken,
        refreshToken: authModel.refreshToken,
      );
    } catch (e) {
      // Xử lý exception và chuyển đổi thành Failure
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during login');
    }
  }

  // Đăng ký tài khoản mới
  @override
  Future<Auth> register(String name, String email, String password, String phone) async {
    // Kiểm tra tất cả các trường bắt buộc
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      throw ServerFailure('All fields are required');
    }
    try {
      // Gọi data source để thực hiện đăng ký
      final authModel = await dataSource.register(name, email, password, phone);
      
      // Chuyển đổi AuthModel sang Auth entity
      return Auth(
        id: authModel.id,
        name: authModel.name,
        email: authModel.email,
      );
    } catch (e) {
      // Xử lý exception
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during registration');
    }
  }

  // Quên mật khẩu - gửi OTP đến email
  @override
  Future<Auth> forgotPassword(String email) async {
    // Kiểm tra email không được rỗng
    if (email.isEmpty) {
      throw ServerFailure('Email cannot be empty');
    }
    try {
      // Gọi data source để gửi yêu cầu quên mật khẩu
      final authModel = await dataSource.forgotPassword(email);
      
      // Trả về entity với thông báo từ server
      return Auth(message: authModel.message);
    } catch (e) {
      // Xử lý exception
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during forgot password');
    }
  }

  // Xác thực mã OTP
  @override
  Future<Auth> verifyOtp(String email, String otp) async {
    // Kiểm tra email và OTP không được rỗng
    if (email.isEmpty || otp.isEmpty) {
      throw ServerFailure('Email and OTP cannot be empty');
    }
    try {
      // Gọi data source để xác thực OTP
      final authModel = await dataSource.verifyOtp(email, otp);
      
      // Trả về entity với thông báo xác thực
      return Auth(message: authModel.message);
    } catch (e) {
      // Xử lý exception
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during OTP verification');
    }
  }

  // Đặt lại mật khẩu mới sau khi xác thực OTP thành công
  @override
  Future<Auth> resetPassword(String email, String newPassword) async {
    // Kiểm tra email và mật khẩu mới không được rỗng
    if (email.isEmpty || newPassword.isEmpty) {
      throw ServerFailure('Email and new password cannot be empty');
    }
    try {
      // Gọi data source để đặt lại mật khẩu
      final authModel = await dataSource.resetPassword(email, newPassword);
      
      // Trả về entity với thông báo kết quả
      return Auth(message: authModel.message);
    } catch (e) {
      // Xử lý exception
      if (e is ServerException) {
        throw ServerFailure(e.message);
      }
      throw ServerFailure('Unknown error during password reset');
    }
  }
}