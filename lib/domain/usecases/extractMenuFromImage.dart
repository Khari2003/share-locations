import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/domain/repositories/ocrRepository.dart';
import 'package:my_app/domain/entities/store.dart';

/// Use case để trích xuất menu từ ảnh sử dụng OCR
/// 
/// Use case này đóng gói logic nghiệp vụ để đọc menu từ ảnh
/// Sử dụng OcrRepository để thực hiện việc trích xuất
class ExtractMenuFromImage {
  final OcrRepository repository;

  ExtractMenuFromImage(this.repository);

  /// Thực thi use case để trích xuất menu từ ảnh
  /// 
  /// [image] - File ảnh chứa menu cần đọc
  /// 
  /// Trả về: Either<Failure, List<MenuItem>>
  ///   - Left: Failure nếu có lỗi xảy ra
  ///   - Right: List<MenuItem> chứa danh sách món ăn đã trích xuất
  Future<Either<Failure, List<MenuItem>>> call(XFile image) async {
    return await repository.extractMenuFromImage(image);
  }
}