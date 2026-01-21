import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/errors/exceptions.dart';
import 'package:my_app/core/errors/failures.dart';
import 'package:my_app/data/datasources/orc/ocrDatasource.dart';
import 'package:my_app/domain/repositories/ocrRepository.dart';
import 'package:my_app/domain/entities/store.dart';

/// Implementation của OcrRepository
/// Xử lý việc gọi data source và chuyển đổi exception thành failure
class OcrRepositoryImpl implements OcrRepository {
  final OcrDataSource dataSource;

  OcrRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<MenuItem>>> extractMenuFromImage(XFile image) async {
    try {
      // Gọi data source để trích xuất menu từ ảnh
      final menuItems = await dataSource.extractMenuFromImage(image);
      
      // Trả về kết quả thành công
      return Right(menuItems);
    } on ServerException catch (e) {
      // Chuyển đổi ServerException thành ServerFailure
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Xử lý các exception không mong đợi
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}