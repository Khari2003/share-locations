import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/review.dart';
import 'package:my_app/domain/usecases/review/getStoreReviews.dart';
import 'package:my_app/domain/usecases/review/leaveReview.dart';
import 'package:flutter/foundation.dart';

// ViewModel để quản lý logic giao diện cho chức năng đánh giá
class ReviewViewModel extends ChangeNotifier {
  final LeaveReview leaveReview;
  final GetStoreReviews getStoreReviews;

  ReviewViewModel({
    required this.leaveReview,
    required this.getStoreReviews,
  });

  // Trạng thái tải
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Danh sách đánh giá
  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  // Thông báo lỗi
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Gửi đánh giá mới cho cửa hàng
  Future<void> submitReview({
    required String storeId,      // ID của cửa hàng cần đánh giá
    required int rating,          // Số sao đánh giá (thường từ 1-5)
    String? comment,              // Nội dung bình luận (tùy chọn)
    List<String> imagePaths = const [], // Danh sách đường dẫn hình ảnh đính kèm
    required String token,        // Token xác thực người dùng
  }) async {
    // Bật trạng thái loading và xóa lỗi cũ
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi use case để thực hiện việc gửi đánh giá
      final result = await leaveReview.call(
        storeId: storeId,
        rating: rating,
        comment: comment,
        imagePaths: imagePaths,
        token: token,
      );

      // Xử lý kết quả trả về (Either<Failure, Review>)
      result.fold(
        (failure) {
          // Trường hợp thất bại: chuyển đổi failure thành thông báo lỗi
          _errorMessage = _mapFailureToMessage(failure);
        },
        (review) {
          // Trường hợp thành công: thêm đánh giá mới vào danh sách
          _reviews.add(review);
          _errorMessage = null;
        },
      );
    } catch (e) {
      // Xử lý các lỗi ngoại lệ không mong muốn
      _errorMessage = 'Đã xảy ra lỗi không xác định: $e';
    } finally {
      // Tắt trạng thái loading và thông báo cho listeners
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh sách đánh giá của cửa hàng với phân trang
  Future<void> fetchStoreReviews({
    required String storeId,  // ID của cửa hàng cần lấy đánh giá
    required int page,        // Số trang cần lấy (pagination)
    required String token,    // Token xác thực người dùng
  }) async {
    // Bật trạng thái loading và xóa thông báo lỗi cũ
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi use case để lấy danh sách đánh giá từ repository
      final result = await getStoreReviews.call(
        storeId: storeId,
        page: page,
        token: token,
      );

      // Xử lý kết quả trả về (Either<Failure, List<Review>>)
      result.fold(
        (failure) {
          // Trường hợp thất bại: chuyển đổi failure thành thông báo lỗi
          _errorMessage = _mapFailureToMessage(failure);
        },
        (reviews) {
          // Trường hợp thành công: xử lý danh sách đánh giá
          if (page == 1) {
            // Nếu là trang đầu tiên: thay thế toàn bộ danh sách (refresh)
            _reviews = reviews;
          } else {
            // Nếu là trang tiếp theo: thêm vào cuối danh sách hiện tại (load more)
            _reviews.addAll(reviews);
          }
          _errorMessage = null;
        },
      );
    } catch (e) {
      // Xử lý các lỗi ngoại lệ không mong muốn
      _errorMessage = 'Đã xảy ra lỗi không xác định: $e';
    } finally {
      // Tắt trạng thái loading và thông báo cho listeners cập nhật UI
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ánh xạ lỗi thành thông báo người dùng
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Đã xảy ra lỗi không xác định';
  }

  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}