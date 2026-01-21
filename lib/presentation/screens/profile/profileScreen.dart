// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/theme.dart';
import './profileModelView.dart';
import '../../../presentation/widgets/addressSelectionWidget.dart';
import '../../../presentation/widgets/imagePickerWidget.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/entities/coordinates.dart';

// Màn hình hiển thị và chỉnh sửa thông tin profile người dùng
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller cho các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();

  // Danh sách các lựa chọn cho chế độ ăn
  final Map<String, String> _dietaryOptions = {
    'vegan': 'Vegan',
    'vegetarian': 'Vegetarian',
    'gluten-free': 'Gluten-Free',
    'halal': 'Halal',
    'kosher': 'Kosher',
    'other': 'Khác',
  };

  // Danh sách các lựa chọn cho mức giá
  final Map<String, String> _priceRangeOptions = {
    'Low': 'Thấp',
    'Moderate': 'Trung bình',
    'High': 'Cao',
  };

  // Giá trị đã chọn cho preferences
  List<String> _selectedDietary = [];
  List<String> _selectedCuisine = [];
  String? _selectedPriceRange;

  // Vị trí đã chọn
  Location? _selectedLocation;

  // Danh sách hình ảnh (chỉ dùng ảnh đầu tiên cho profile photo)
  List<XFile> _selectedImages = [];

  // Key cho Form để kiểm tra dữ liệu nhập
  final _formKey = GlobalKey<FormState>();

  // Trạng thái chỉnh sửa (true: hiển thị form chỉnh sửa đầy đủ)
  bool _isEditing = false;

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
              _introController.text = profile['bio']?['intro'] ?? '';
              _websiteController.text = profile['bio']?['website'] ?? '';
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
              _selectedCuisine = (profile['preferences']?['cuisine'] as List<dynamic>?)?.cast<String>() ?? [];
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
    _introController.dispose();
    _websiteController.dispose();
    _cuisineController.dispose();
    super.dispose();
  }

  // Widget hiển thị các chip lựa chọn đa dạng
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
  Future<void> _submitUpdate(ProfileViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Bật trạng thái loading
      setState(() => _isLoading = true);

      if (_isEditing) {
        // Upload ảnh nếu có (chỉ lấy ảnh đầu tiên)
        String? profilePhotoUrl;
        if (_selectedImages.isNotEmpty) {
          final imageUrls = await viewModel.uploadImages(_selectedImages);
          profilePhotoUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
        }

        // Cập nhật toàn bộ profile
        await viewModel.updateFullProfile(
          context,
          name: _nameController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          email: _emailController.text,
          location: _selectedLocation,
          dietary: _selectedDietary,
          cuisine: _selectedCuisine,
          priceRange: _selectedPriceRange ?? '',
          profilePhoto: profilePhotoUrl,
          intro: _introController.text.isEmpty ? null : _introController.text,
          website: _websiteController.text.isEmpty ? null : _websiteController.text,
        );
      } else {
        // Cập nhật chỉ tên và số điện thoại
        await viewModel.updateUserProfile(
          context,
          name: _nameController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        );
      }

      // Tắt trạng thái loading
      setState(() => _isLoading = false);

      // Xử lý kết quả từ API
      if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: ${viewModel.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật profile thành công')),
        );
        // Tắt chế độ chỉnh sửa
        setState(() => _isEditing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Hiển thị loading khi đang tải dữ liệu
          if (viewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Hiển thị thông báo lỗi nếu có
          if (viewModel.errorMessage != null) {
            return Scaffold(body: Center(child: Text(viewModel.errorMessage!)));
          }
          // Kiểm tra thông tin profile
          final profile = viewModel.userProfile;
          if (profile == null) {
            return const Scaffold(body: Center(child: Text('Không tìm thấy thông tin profile')));
          }

          // Xử lý ảnh đại diện để đảm bảo đúng định dạng List<String>?
          final initialImage = profile['profilephoto'] != null
              ? [profile['profilephoto'] as String]
              : null;

          // Giao diện chính của màn hình Profile
          return Scaffold(
            appBar: AppBar(
              title: const Text('Trang Cá Nhân'),
              actions: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      _submitUpdate(viewModel); // Lưu thay đổi
                    } else {
                      setState(() => _isEditing = true); // Bật chế độ chỉnh sửa
                    }
                  },
                ),
              ],
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
                        // Hiển thị ảnh đại diện
                        Center(
                          child: _isEditing
                              ? Column(
                                  children: [
                                    const Text('Ảnh đại diện',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    ImagePickerWidget(
                                      initialImages: initialImage,
                                      onImagesChanged: (images) {
                                        setState(() {
                                          _selectedImages = images.take(1).toList();
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profile['profilephoto'] != null
                                      ? NetworkImage(profile['profilephoto'] as String)
                                      : const AssetImage('assets/default_avatar.jpg') as ImageProvider,
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Trường nhập tên
                        TextFormField(
                          controller: _nameController,
                          enabled: true,
                          decoration: InputDecoration(
                            labelText: 'Tên',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: !_isEditing,
                            fillColor: !_isEditing ? Colors.grey[100] : null,
                          ),
                          validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                        ),
                        const SizedBox(height: 16),
                        // Trường nhập số điện thoại
                        TextFormField(
                          controller: _phoneController,
                          enabled: true,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: !_isEditing,
                            fillColor: !_isEditing ? Colors.grey[100] : null,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                              return 'Vui lòng nhập số điện thoại hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Hiển thị hoặc chỉnh sửa email
                        _isEditing
                            ? TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true, // Không cho phép chỉnh sửa email
                              )
                            : Text('Email: ${profile['email'] ?? 'Chưa thiết lập'}',
                                style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        // Hiển thị hoặc chỉnh sửa thông tin địa chỉ
                        _isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Vị trí',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  AddressSelectionWidget(
                                    initialLocation: _selectedLocation,
                                    onLocationChanged: (location) {
                                      setState(() {
                                        _selectedLocation = location;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Địa chỉ: ${profile['location']?['address'] ?? 'Chưa thiết lập'}'),
                                  Text(
                                      'Thành phố: ${profile['location']?['city'] ?? 'Chưa thiết lập'}'),
                                  Text(
                                      'Quốc gia: ${profile['location']?['country'] ?? 'Chưa thiết lập'}'),
                                ],
                              ),
                        const SizedBox(height: 16),
                        // Hiển thị hoặc chỉnh sửa thông tin tiểu sử
                        _isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tiểu sử',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _introController,
                                    decoration: InputDecoration(
                                      labelText: 'Giới thiệu',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _websiteController,
                                    decoration: InputDecoration(
                                      labelText: 'Website',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    keyboardType: TextInputType.url,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Giới thiệu: ${profile['bio']?['intro'] ?? 'Chưa thiết lập'}'),
                                  Text('Website: ${profile['bio']?['website'] ?? 'Chưa thiết lập'}'),
                                ],
                              ),
                        const SizedBox(height: 16),
                        // Hiển thị hoặc chỉnh sửa thông tin ưu tiên
                        _isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ưu tiên',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  _buildMultiSelectChips(
                                    'Chế độ ăn',
                                    _dietaryOptions,
                                    _selectedDietary,
                                    (newSelected) => setState(() => _selectedDietary = newSelected),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _cuisineController,
                                    decoration: InputDecoration(
                                      labelText: 'Món ăn ưa thích (cách nhau bằng dấu phẩy)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCuisine = value.split(',').map((e) => e.trim()).toList();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
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
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chế độ ăn: ${(profile['preferences']?['dietary'] as List<dynamic>?)?.map((key) => _dietaryOptions[key] ?? key).join(', ') ?? 'Chưa thiết lập'}',
                                  ),
                                  Text(
                                    'Món ăn ưa thích: ${(profile['preferences']?['cuisine'] as List<dynamic>?)?.join(', ') ?? 'Chưa thiết lập'}',
                                  ),
                                  Text(
                                      'Mức giá: ${profile['preferences']?['priceRange'] ?? 'Chưa thiết lập'}'),
                                ],
                              ),
                        const SizedBox(height: 24),
                        // Nút đăng xuất
                        ElevatedButton(
                          onPressed: () async {
                            // Gọi logout và điều hướng về màn hình welcome
                            await viewModel.logout(context);
                            Navigator.pushReplacementNamed(context, '/welcome');
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hiển thị loading khi đang xử lý
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}