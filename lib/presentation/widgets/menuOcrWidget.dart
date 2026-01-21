// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/domain/entities/store.dart';
import 'package:my_app/domain/usecases/extractMenuFromImage.dart';

/// Widget để quét và trích xuất menu từ ảnh sử dụng OCR
/// 
/// Widget này cho phép người dùng chụp ảnh hoặc chọn ảnh từ thư viện
/// để tự động đọc menu bằng AI
class MenuOcrWidget extends StatefulWidget {
  /// Use case để trích xuất menu từ ảnh
  final ExtractMenuFromImage extractMenuFromImage;
  
  /// Callback được gọi khi menu đã được trích xuất thành công
  final Function(List<MenuItem>) onMenuExtracted;

  const MenuOcrWidget({
    super.key,
    required this.extractMenuFromImage,
    required this.onMenuExtracted,
  });

  @override
  State<MenuOcrWidget> createState() => _MenuOcrWidgetState();
}

class _MenuOcrWidgetState extends State<MenuOcrWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  /// Chọn ảnh và trích xuất menu
  /// 
  /// [source] - Nguồn ảnh (camera hoặc gallery)
  Future<void> _pickImageAndExtractMenu(ImageSource source) async {
    try {
      // Chọn ảnh từ nguồn được chỉ định
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      // Nếu không có ảnh được chọn, return
      if (image == null) return;

      // Bắt đầu trạng thái xử lý
      setState(() => _isProcessing = true);

      // Gọi use case để trích xuất menu từ ảnh
      final result = await widget.extractMenuFromImage(image);

      // Xử lý kết quả từ use case
      result.fold(
        // Trường hợp lỗi
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // Trường hợp thành công
        (menuItems) {
          // Gọi callback để trả kết quả về parent widget
          widget.onMenuExtracted(menuItems);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã trích xuất ${menuItems.length} món ăn'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      // Xử lý lỗi không mong đợi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không xác định: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Kết thúc trạng thái xử lý
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Hiển thị dialog để chọn nguồn ảnh (camera hoặc gallery)
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndExtractMenu(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndExtractMenu(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isProcessing ? null : _showImageSourceDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon camera hoặc loading
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isProcessing ? Icons.hourglass_empty : Icons.camera_alt,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Text mô tả
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isProcessing ? 'Đang xử lý...' : 'Quét menu từ ảnh',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isProcessing
                          ? 'AI đang đọc menu từ ảnh'
                          : 'Chụp hoặc chọn ảnh menu để tự động nhập',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Progress indicator hoặc arrow icon
              if (_isProcessing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}