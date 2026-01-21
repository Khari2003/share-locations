// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/apiEndpoints.dart';
import '../../../core/errors/failures.dart';
import '../auth/authViewModel.dart';
import '../../../domain/entities/location.dart';

// ViewModel quản lý trạng thái và logic của profile người dùng
class ProfileViewModel extends ChangeNotifier {
  Map<String, dynamic>? _userProfile; // Lưu thông tin profile người dùng
  bool _isLoading = false; // Trạng thái đang tải dữ liệu
  String? _errorMessage; // Thông báo lỗi nếu có

  // Getter để truy cập dữ liệu từ bên ngoài
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy thông tin profile từ API /users/:id
  Future<void> fetchUserProfile(BuildContext context) async {
    // Lấy thông tin xác thực từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.auth?.id == null || authViewModel.auth?.accessToken == null) {
      _errorMessage = 'Không tìm thấy thông tin xác thực';
      notifyListeners();
      return;
    }

    // Bật trạng thái loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gửi yêu cầu GET đến API để lấy profile
      final response = await http.get(
        Uri.parse('${ApiEndpoints.userById}${authViewModel.auth!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.auth!.accessToken}',
        },
      );

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
      } else {
        _errorMessage = 'Lỗi khi lấy thông tin profile: ${response.reasonPhrase}';
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi lấy profile';
    } finally {
      // Tắt trạng thái loading và thông báo thay đổi
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload ảnh lên Cloudinary
  Future<List<String>> uploadImages(List<XFile> images) async {
    // Bật trạng thái loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<String> imageUrls = []; // Danh sách URL của ảnh đã upload
    try {
      for (var image in images) {
        // Tạo yêu cầu multipart để upload ảnh
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/dsplmxojb/auto/upload'),
        );
        request.fields['upload_preset'] = 'chat-app-file';
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        // Gửi yêu cầu và xử lý phản hồi
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          imageUrls.add(jsonData['secure_url']);
        } else {
          throw Exception('Lỗi khi upload ảnh: ${jsonData['error']?['message'] ?? 'Unknown error'}');
        }
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi upload ảnh: $e';
    } finally {
      // Tắt trạng thái loading và thông báo thay đổi
      _isLoading = false;
      notifyListeners();
    }
    return imageUrls;
  }

  // Cập nhật thông tin profile (chỉ name và phone) qua API /users/:id
  Future<void> updateUserProfile(BuildContext context, {String? name, String? phone}) async {
    // Lấy thông tin xác thực từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.auth?.id == null || authViewModel.auth?.accessToken == null) {
      _errorMessage = 'Không tìm thấy thông tin xác thực';
      notifyListeners();
      return;
    }

    // Bật trạng thái loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gửi yêu cầu PUT để cập nhật profile
      final response = await http.put(
        Uri.parse('${ApiEndpoints.userById}${authViewModel.auth!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.auth!.accessToken}',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        }),
      );

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (name != null) await prefs.setString('userName', name);
      } else {
        _errorMessage = 'Lỗi khi cập nhật profile: ${response.reasonPhrase}';
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi cập nhật profile';
    } finally {
      // Tắt trạng thái loading và thông báo thay đổi
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật toàn bộ thông tin profile
  Future<void> updateFullProfile(
    BuildContext context, {
    String? name,
    String? phone,
    String? email,
    Location? location,
    List<String>? dietary,
    List<String>? cuisine,
    String? priceRange,
    String? profilePhoto,
    String? intro,
    String? website,
  }) async {
    // Lấy thông tin xác thực từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.auth?.id == null || authViewModel.auth?.accessToken == null) {
      _errorMessage = 'Không tìm thấy thông tin xác thực';
      notifyListeners();
      return;
    }

    // Bật trạng thái loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gửi yêu cầu PUT để cập nhật toàn bộ profile
      final response = await http.put(
        Uri.parse('${ApiEndpoints.userById}${authViewModel.auth!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.auth!.accessToken}',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (location != null) 'location': location.toJson(),
          if (profilePhoto != null) 'profilephoto': profilePhoto,
          if (dietary != null || cuisine != null || priceRange != null)
            'preferences': {
              if (dietary != null) 'dietary': dietary,
              if (cuisine != null) 'cuisine': cuisine,
              if (priceRange != null) 'priceRange': priceRange,
            },
          if (intro != null || website != null)
            'bio': {
              if (intro != null) 'intro': intro,
              if (website != null) 'website': website,
            },
        }),
      );

      // Xử lý phản hồi từ API
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (name != null) await prefs.setString('userName', name);
      } else {
        _errorMessage = 'Lỗi khi cập nhật profile: ${response.reasonPhrase}';
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      _errorMessage = e is ServerFailure ? e.message : 'Lỗi xảy ra khi cập nhật profile';
    } finally {
      // Tắt trạng thái loading và thông báo thay đổi
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thực hiện đăng xuất
  Future<void> logout(BuildContext context) async {
    // Gọi hàm logout từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.logout();
  }
}