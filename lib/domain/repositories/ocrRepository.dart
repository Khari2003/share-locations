import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/entities/store.dart';

/// Repository interface cho OCR
/// Định nghĩa contract để trích xuất menu từ ảnh
abstract class OcrRepository {
  /// Trích xuất danh sách món ăn từ ảnh menu
  /// 
  /// [image] - File ảnh chứa menu cần đọc
  /// 
  /// Trả về: Either<Failure, List<MenuItem>>
  ///   - Left: Failure nếu có lỗi
  ///   - Right: List<MenuItem> nếu thành công
  Future<Either<Failure, List<MenuItem>>> extractMenuFromImage(XFile image);
}