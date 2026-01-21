// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/widgets/addressSelectionWidget.dart';
import 'package:my_app/presentation/widgets/imagePickerWidget.dart';
import 'package:my_app/presentation/widgets/storeFormWidget.dart';
import 'package:provider/provider.dart';
import 'package:my_app/core/constants/theme.dart';

// Lớp màn hình chỉnh sửa thông tin nhà hàng
class EditStoreScreen extends StatefulWidget {
  final StoreModel store;

  const EditStoreScreen({super.key, required this.store});

  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

// Lớp trạng thái của màn hình chỉnh sửa nhà hàng
class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>(); // Khóa biểu mẫu để kiểm tra dữ liệu
  bool _isLoading = false; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu ban đầu từ nhà hàng
    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    storeViewModel.setLocation(widget.store.location ?? Location(address: '', city: '', coordinates: null));
    storeViewModel.setSelectedImages([]);
    storeViewModel.setMenuItems(widget.store.menu);
  }

  // Lưu thông tin nhà hàng đã chỉnh sửa
  Future<void> _saveStore() async {
    if (_formKey.currentState!.validate()) {
      final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
      final formState = storeFormKey.currentState;
      if (formState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không thể lấy dữ liệu biểu mẫu')),
        );
        return;
      }

      // Kiểm tra tọa độ vị trí
      if (storeViewModel.selectedLocation?.coordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn vị trí có tọa độ')),
        );
        return;
      }

      // Tạo đối tượng nhà hàng mới với thông tin cập nhật
      final updatedStore = StoreModel(
        id: widget.store.id,
        name: formState.name ?? widget.store.name,
        type: formState.type ?? widget.store.type,
        description: formState.description,
        location: storeViewModel.selectedLocation ?? widget.store.location,
        priceRange: formState.priceRange ?? widget.store.priceRange,
        menu: storeViewModel.menuItems,
        images: storeViewModel.selectedImages.isNotEmpty
            ? await storeViewModel.uploadImages(storeViewModel.selectedImages)
            : widget.store.images,
        owner: widget.store.owner,
        reviews: widget.store.reviews,
        isApproved: widget.store.isApproved,
        createdAt: widget.store.createdAt,
      );

      setState(() => _isLoading = true); // Bắt đầu trạng thái tải

      // Gọi hàm cập nhật nhà hàng
      await storeViewModel.updateStore(widget.store.id!, updatedStore);

      setState(() => _isLoading = false); // Kết thúc trạng thái tải

      // Xử lý kết quả cập nhật
      if (storeViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật nhà hàng thất bại: ${storeViewModel.errorMessage}')),
        );
      } else {
        // Đặt lại biểu mẫu sau khi cập nhật thành công
        formState.reset();
        storeViewModel.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật nhà hàng thành công')),
        );
        Navigator.pushReplacementNamed(context, '/map'); // Chuyển hướng đến màn hình bản đồ
      }
    }
  }

  // Xóa nhà hàng
  Future<void> _deleteStore() async {
    setState(() => _isLoading = true); // Bắt đầu trạng thái tải

    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    // Gọi hàm xóa nhà hàng
    await storeViewModel.deleteStore(widget.store.id!);

    setState(() => _isLoading = false); // Kết thúc trạng thái tải

    // Xử lý kết quả xóa
    if (storeViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa nhà hàng thất bại: ${storeViewModel.errorMessage}')),
      );
    } else {
      // Đặt lại biểu mẫu sau khi xóa thành công
      storeFormKey.currentState?.reset();
      storeViewModel.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa nhà hàng thành công')),
      );
      Navigator.pushReplacementNamed(context, '/map'); // Chuyển hướng đến màn hình bản đồ
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPriceRange = widget.store.priceRange;

    // Xây dựng giao diện màn hình chỉnh sửa
    return Theme(
      data: appTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa nhà hàng',
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
                            // Widget biểu mẫu thông tin nhà hàng
                            StoreFormWidget(
                              key: storeFormKey,
                              initialName: widget.store.name,
                              initialDescription: widget.store.description,
                              initialPriceRange: initialPriceRange,
                              initialType: widget.store.type,
                              initialMenu: widget.store.menu,
                            ),
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
                            // Widget chọn hình ảnh
                            ImagePickerWidget(
                              initialImages: widget.store.images,
                              onImagesChanged: (List<XFile> images) {
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
                            // Widget chọn vị trí
                            AddressSelectionWidget(
                              initialLocation: widget.store.location,
                              onLocationChanged: (Location location) {
                                Provider.of<StoreViewModel>(context, listen: false).setLocation(location);
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveStore,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: appTheme().primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Text(
                                        'Lưu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              // Hiển thị hộp thoại xác nhận xóa
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Xác nhận xóa'),
                                                  content: const Text('Bạn có chắc chắn muốn xóa nhà hàng này?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Hủy'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteStore();
                                                      },
                                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Hiển thị vòng tròn tải khi đang xử lý
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