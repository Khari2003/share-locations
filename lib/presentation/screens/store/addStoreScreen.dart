// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/addressSelectionWidget.dart';
import 'package:my_app/presentation/widgets/imagePickerWidget.dart';
import 'package:my_app/presentation/widgets/storeFormWidget.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:provider/provider.dart';

class AddStoreScreen extends StatefulWidget {
  final AuthViewModel authViewModel;
  const AddStoreScreen({super.key, required this.authViewModel});

  @override
  _AddStoreScreenState createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitStore() async {
    // Kiểm tra tính hợp lệ của form
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại biểu mẫu')),
      );
      return;
    }

    // Lấy instance của StoreViewModel
    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    final formState = storeFormKey.currentState;
    
    // Kiểm tra xem formState có tồn tại không
    if (formState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể lấy dữ liệu biểu mẫu')),
      );
      return;
    }

    // Kiểm tra xem người dùng đã chọn vị trí với tọa độ hợp lệ chưa
    if (storeViewModel.selectedLocation?.coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí có tọa độ')),
      );
      return;
    }

    // Bật trạng thái loading
    setState(() => _isLoading = true);

    try {
      // Tải tất cả hình ảnh đã chọn lên Cloudinary và nhận về danh sách URL
      final imageUrls = await storeViewModel.uploadImages(storeViewModel.selectedImages);

      // Tạo đối tượng StoreModel với dữ liệu từ form
      final store = StoreModel(
        name: formState.name!,
        type: formState.type!,
        description: formState.description,
        location: storeViewModel.selectedLocation,
        priceRange: formState.priceRange!,
        menu: storeViewModel.menuItems,
        images: imageUrls,
        createdAt: DateTime.now(),
        reviews: [],
        owner: widget.authViewModel.auth?.id ?? 'unknown', // ID người tạo
        rating: 0.0, // Rating ban đầu
      );

      // In ra dữ liệu store để debug
      debugPrint('Store to be sent: ${store.toJson()}');

      // Gửi request tạo nhà hàng mới
      await storeViewModel.createStore(store);

      // Tắt trạng thái loading
      setState(() => _isLoading = false);

      // Kiểm tra kết quả tạo nhà hàng
      if (storeViewModel.errorMessage != null) {
        // Hiển thị thông báo lỗi nếu có
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo nhà hàng thất bại: ${storeViewModel.errorMessage}')),
        );
      } else {
        // Tạo thành công: Reset form và dữ liệu
        formState.reset();
        storeViewModel.reset();
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo nhà hàng thành công')),
        );
        
        // Chuyển hướng về màn hình map
        Navigator.pushReplacementNamed(context, '/map');
      }
    } catch (e) {
      // Xử lý lỗi ngoại lệ
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thêm nhà hàng mới',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: appTheme().primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin nhà hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            StoreFormWidget(key: storeFormKey),
                            const SizedBox(height: 24),
                            const Text(
                              'Hình ảnh nhà hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ImagePickerWidget(
                              onImagesChanged: (images) {
                                Provider.of<StoreViewModel>(context, listen: false).setSelectedImages(images);
                              },
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Vị trí nhà hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AddressSelectionWidget(
                              onLocationChanged: (location) {
                                Provider.of<StoreViewModel>(context, listen: false).setLocation(location);
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitStore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme().primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Thêm nhà hàng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}