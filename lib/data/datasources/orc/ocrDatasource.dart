import 'package:http/http.dart' as http;
import 'package:my_app/core/errors/exceptions.dart';
import 'dart:convert';
import 'package:my_app/core/constants/apiEndpoints.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/domain/entities/store.dart';

/// Data source trừu tượng cho OCR (Optical Character Recognition)
/// Định nghĩa các phương thức để trích xuất menu từ ảnh
abstract class OcrDataSource {
  /// Trích xuất danh sách món ăn từ ảnh menu
  /// 
  /// [image] - File ảnh chứa menu cần đọc
  /// 
  /// Trả về: List<MenuItem> - Danh sách các món ăn đã trích xuất
  /// 
  /// Throws: ServerException nếu có lỗi từ server
  Future<List<MenuItem>> extractMenuFromImage(XFile image);
}

/// Implementation của OcrDataSource
/// Xử lý việc gọi API OCR để đọc menu từ ảnh
class OcrDataSourceImpl implements OcrDataSource {
  final http.Client client;

  OcrDataSourceImpl(this.client);

  // Trích xuất danh sách món ăn từ ảnh menu sử dụng OCR
  @override
  Future<List<MenuItem>> extractMenuFromImage(XFile image) async {
    try {
      // Tạo multipart request để upload ảnh
      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.ocrMenu));
      
      // Thêm file ảnh vào request
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // Gửi request và nhận response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log thông tin response để debug
      print('OCR Response status: ${response.statusCode}');
      print('OCR Response body: ${response.body}');

      // Xử lý response dựa trên status code
      if (response.statusCode == 200) {
        // Phân tích dữ liệu JSON trả về
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Kiểm tra kết quả thành công và có dữ liệu menu
        if (data['success'] == true && data['menu'] != null) {
          final List<dynamic> menuList = data['menu'];
          
          // Chuyển đổi từng item trong menu thành MenuItem entity
          return menuList.map((item) {
            return MenuItem(
              name: item['name']?.toString() ?? '', // Tên món ăn
              price: item['price']?.toDouble() ?? 0.0, // Giá món ăn
            );
          }).toList();
        } else {
          // Không có dữ liệu menu trong response
          throw ServerException('Không thể trích xuất menu từ ảnh');
        }
      } else if (response.statusCode == 400) {
        // Bad Request - ảnh không hợp lệ
        throw ServerException('Ảnh không hợp lệ hoặc không thể đọc được');
      } else if (response.statusCode == 401) {
        // Unauthorized - chưa xác thực
        throw ServerException('Chưa xác thực');
      } else if (response.statusCode == 500) {
        // Internal Server Error
        throw ServerException('Lỗi server khi xử lý ảnh');
      } else {
        // Các mã lỗi khác - trích xuất thông báo lỗi từ response
        final errorMessage = _extractErrorMessage(response);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      // Log lỗi để debug
      print('OCR Error: $e');
      
      // Nếu đã là ServerException thì throw lại
      if (e is ServerException) {
        rethrow;
      }
      
      // Các lỗi khác (network, parsing, etc.)
      throw ServerException('Lỗi không xác định khi trích xuất menu: $e');
    }
  }

  // Trích xuất thông báo lỗi từ response body
  String _extractErrorMessage(http.Response response) {
    try {
      // Parse JSON từ response body
      final json = jsonDecode(response.body);
      
      // Lấy message hoặc error từ JSON, nếu không có thì dùng thông báo mặc định
      return json['message'] ?? json['error'] ?? 'Lỗi server (Mã trạng thái ${response.statusCode})';
    } catch (e) {
      // Nếu không thể parse JSON, trả về thông báo lỗi chung
      return 'Không thể phân tích phản hồi server (Mã trạng thái ${response.statusCode})';
    }
  }
}