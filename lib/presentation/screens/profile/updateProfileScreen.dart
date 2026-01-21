// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import './profileModelView.dart';
import '../../../presentation/widgets/addressSelectionWidget.dart';
import '../../../presentation/widgets/imagePickerWidget.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/entities/coordinates.dart';

// Màn hình cập nhật toàn bộ thông tin profile người dùng
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // Controllers cho các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Danh sách các lựa chọn cho chế độ ăn
  final Map<String, String> _dietaryOptions = {
    'chay-phat-giao': 'Chay Phật giáo',
    'chay-a-au': 'Chay Á - Âu',
    'chay-hien-dai': 'Chay hiện đại',
    'com-chay-binh-dan': 'Cơm chay bình dân',
    'buffet-chay': 'Buffet chay',
    'chay-ton-giao-khac': 'Chay tôn giáo khác',
  };

  // Danh sách các lựa chọn cho mức giá
  final Map<String, String> _priceRangeOptions = {
    'Low': 'Thấp',
    'Moderate': 'Trung bình',
    'High': 'Cao',
  };

  // Giá trị đã chọn cho preferences
  List<String> _selectedDietary = [];
  String? _selectedPriceRange;

  // Vị trí đã chọn
  Location? _selectedLocation;

  // Danh sách hình ảnh (chỉ dùng ảnh đầu tiên cho profile photo)
  List<XFile> _selectedImages = [];

  // Key cho Form để kiểm tra dữ liệu nhập
  final _formKey = GlobalKey<FormState>();

  // Trạng thái loading khi gửi yêu cầu API
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu profile ban đầu sau khi widget được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.fetchUserProfile(context).then((_) {
        if (profileViewModel.errorMessage != null) {
          // Hiển thị thông báo lỗi nếu không tải được profile
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tải profile: ${profileViewModel.errorMessage}')),
          );
        } else {
          final profile = profileViewModel.userProfile;
          if (profile != null) {
            // Cập nhật các giá trị ban đầu cho các trường nhập và trạng thái
            setState(() {
              _nameController.text = profile['name'] ?? '';
              _phoneController.text = profile['phone'] ?? '';
              _emailController.text = profile['email'] ?? '';
              _selectedLocation = profile['location'] != null
                  ? Location(
                      address: profile['location']['address'] ?? '',
                      city: profile['location']['city'] ?? '',
                      country: profile['location']['country'] ?? '',
                      coordinates: profile['location']['coordinates'] != null
                          ? Coordinates(
                              latitude: profile['location']['coordinates'][1],
                              longitude: profile['location']['coordinates'][0],
                            )
                          : null,
                    )
                  : null;
              _selectedDietary = (profile['preferences']?['dietary'] as List<dynamic>?)?.cast<String>() ?? [];
              _selectedPriceRange = profile['preferences']?['priceRange'];
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Giải phóng các controller để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Widget hiển thị các chip lựa chọn đa dạng cho chế độ ăn
  Widget _buildMultiSelectChips(
    String label,
    Map<String, String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.entries.map((entry) {
            final isSelected = selected.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (bool value) {
                // Cập nhật danh sách lựa chọn khi người dùng chọn/bỏ chọn
                setState(() {
                  if (value) {
                    selected.add(entry.key);
                  } else {
                    selected.remove(entry.key);
                  }
                  onChanged(selected);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Xử lý submit cập nhật profile
  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      // Bật trạng thái loading
      setState(() => _isLoading = true);
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);

      // Upload ảnh nếu có (chỉ lấy ảnh đầu tiên)
      String? profilePhotoUrl;
      if (_selectedImages.isNotEmpty) {
        final imageUrls = await profileViewModel.uploadImages(_selectedImages);
        profilePhotoUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
      }

      // Gọi API cập nhật toàn bộ profile
      await profileViewModel.updateFullProfile(
        context,
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text,
        location: _selectedLocation,
        dietary: _selectedDietary,
        priceRange: _selectedPriceRange ?? '',
        profilePhoto: profilePhotoUrl,
      );

      // Tắt trạng thái loading
      setState(() => _isLoading = false);

      // Xử lý kết quả từ API
      if (profileViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: ${profileViewModel.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật profile thành công')),
        );
        Navigator.pop(context); // Quay về màn hình profile
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final profile = profileViewModel.userProfile;
    // Xử lý ảnh đại diện để đảm bảo đúng định dạng List<String>?
    final initialImage = profile != null && profile['profilephoto'] != null
        ? [profile['profilephoto'] as String]
        : null;

    return Theme(
      data: appTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cập Nhật Profile'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần chọn ảnh đại diện
                    const Text('Ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ImagePickerWidget(
                      initialImages: initialImage,
                      onImagesChanged: (images) {
                        setState(() {
                          _selectedImages = images.take(1).toList(); // Chỉ lấy ảnh đầu tiên
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Trường nhập tên
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    // Trường nhập số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                          return 'Vui lòng nhập số điện thoại hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Trường nhập email (chỉ đọc)
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true, // Không cho phép chỉnh sửa email
                    ),
                    const SizedBox(height: 24),
                    // Phần chọn vị trí
                    const Text('Vị trí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AddressSelectionWidget(
                      initialLocation: _selectedLocation,
                      onLocationChanged: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Phần chọn ưu tiên
                    const Text('Ưu tiên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMultiSelectChips(
                      'Chế độ ăn',
                      _dietaryOptions,
                      _selectedDietary,
                      (newSelected) => setState(() => _selectedDietary = newSelected),
                    ),
                    const SizedBox(height: 16),
                    // Trường chọn mức giá
                    DropdownButtonFormField<String>(
                      value: _selectedPriceRange,
                      decoration: InputDecoration(
                        labelText: 'Mức giá',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _priceRangeOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriceRange = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    // Nút lưu thay đổi
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            // Hiển thị loading khi đang xử lý
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}