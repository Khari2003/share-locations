// ApiEndpoints.dart

// Lớp chứa các endpoint API để giao tiếp với backend
class ApiEndpoints {
  // URL gốc của backend
  static const String baseUrl = 'https://server-morning-forest-197.fly.dev';

  // Auth endpoints
  static const String login = '$baseUrl/api/auth/login'; // POST: Đăng nhập người dùng
  static const String register = '$baseUrl/api/auth/register'; // POST: Đăng ký người dùng mới
  static const String forgotPassword = '$baseUrl/api/auth/forgotPassword'; // POST: Yêu cầu đặt lại mật khẩu
  static const String verifyOtp = '$baseUrl/api/auth/verify-otp'; // POST: Xác minh OTP
  static const String resetPassword = '$baseUrl/api/auth/reset-password'; // POST: Đặt lại mật khẩu
  static const String logout = '$baseUrl/api/auth/logout'; // POST: Đăng xuất người dùng
  static const String verifyToken = '$baseUrl/api/auth/verifyToken'; // POST: Xác minh accessToken
  static const String refreshToken = '$baseUrl/api/auth/refresh-token'; // POST: Làm mới accessToken bằng refreshToken

  // User endpoints
  static const String userById = '$baseUrl/api/users/'; // GET: Lấy/cập nhật thông tin user

  // Store endpoints
  static const String stores = '$baseUrl/api/stores'; // GET: Lấy danh sách cửa hàng
  static const String searchStores = '$baseUrl/api/stores/search'; // GET: Tìm kiếm cửa hàng
  static const String createStore = '$baseUrl/api/stores'; // POST: Tạo cửa hàng mới
  static const String updateStore = '$baseUrl/api/stores'; // PUT: Cập nhật cửa hàng (/api/stores/:id)
  static const String deleteStore = '$baseUrl/api/stores'; // DELETE: Xóa cửa hàng (/api/stores/:id)

  // Review endpoints
  static const String leaveReview = '$baseUrl/api/stores/:id/reviews'; // POST: Gửi đánh giá cho cửa hàng
  static const String getStoreReviews = '$baseUrl/api/stores/:id/reviews'; // GET: Lấy danh sách đánh giá của cửa hàng

  // OCR endpoints
  static const String ocrMenu = '$baseUrl/api/ocr/menu'; // POST: OCR để lấy menu từ ảnh
}