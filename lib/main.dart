// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:my_app/data/models/storeModel.dart';
import 'package:my_app/presentation/screens/profile/profileModelView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/injectionContainer.dart' as di;
import 'domain/usecases/getCurrentLocation.dart';
import 'domain/usecases/store/getStores.dart';
import 'domain/usecases/getRoute.dart';
import 'domain/usecases/store/updateStore.dart';
import 'domain/usecases/store/deleteStore.dart';
import 'presentation/screens/auth/loginScreen.dart';
import 'presentation/screens/auth/registerScreen.dart';
import 'presentation/screens/auth/forgotPasswordScreen.dart';
import 'presentation/screens/auth/verifyOtpScreen.dart';
import 'presentation/screens/auth/resetPasswordScreen.dart';
import 'presentation/screens/auth/welcomeScreen.dart';
import 'presentation/screens/map/mapScreen.dart';
import 'presentation/screens/store/addStoreScreen.dart';
import 'presentation/screens/store/editStoreScreen.dart';
import 'presentation/screens/auth/authViewModel.dart';
import 'presentation/screens/search/searchPlacesViewModel.dart';
import 'presentation/screens/store/storeViewModel.dart';
import 'presentation/screens/profile/profileScreen.dart';

// Hàm main - điểm khởi đầu của ứng dụng
void main() async {
  // Đảm bảo Flutter widgets đã được khởi tạo trước khi chạy code async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo dependency injection container
  await di.init();
  
  // Lấy instance của AuthViewModel và load dữ liệu người dùng đã lưu
  final authViewModel = di.sl<AuthViewModel>();
  await authViewModel.loadUserData();
  
  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Xác định màn hình khởi đầu dựa trên trạng thái đăng nhập
  Future<String> _getInitialRoute() async {
    try {
      // Lấy SharedPreferences để đọc dữ liệu đã lưu
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      
      // Lấy AuthViewModel và xác thực token
      final authViewModel = di.sl<AuthViewModel>();
      await authViewModel.verifyToken();
      
      // Nếu có token, người dùng chọn "Ghi nhớ đăng nhập" và token còn hợp lệ
      // thì chuyển thẳng đến màn hình map
      if (token != null && rememberMe && authViewModel.auth != null) {
        return '/map';
      }
      
      // Ngược lại, hiển thị màn hình welcome
      return '/welcome';
    } catch (e) {
      // Nếu có lỗi, mặc định về màn hình welcome
      return '/welcome';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Cung cấp các providers cho toàn bộ ứng dụng
      providers: [
        // AuthViewModel - quản lý trạng thái xác thực
        ChangeNotifierProvider.value(value: di.sl<AuthViewModel>()),
        
        // Use cases - các nghiệp vụ của ứng dụng
        Provider<GetCurrentLocation>(create: (_) => di.sl<GetCurrentLocation>()),
        Provider<GetStores>(create: (_) => di.sl<GetStores>()),
        Provider<GetRoute>(create: (_) => di.sl<GetRoute>()),
        Provider<UpdateStore>(create: (_) => di.sl<UpdateStore>()),
        Provider<DeleteStore>(create: (_) => di.sl<DeleteStore>()),
        
        // ViewModels - quản lý trạng thái các màn hình
        ChangeNotifierProvider(create: (_) => di.sl<SearchPlacesViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<StoreViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileViewModel>()),
      ],
      child: MaterialApp(
        // Route ban đầu là '/' - sẽ quyết định hiển thị welcome hay map
        initialRoute: '/',
        routes: {
          // Route root - xác định màn hình khởi đầu
          '/': (context) => FutureBuilder<String>(
                future: _getInitialRoute(),
                builder: (context, snapshot) {
                  // Hiển thị loading trong khi đang xác định route
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  // Chuyển đến map hoặc welcome tùy vào kết quả
                  return snapshot.data == '/map' ? const MapScreen() : const WelcomeScreen();
                },
              ),
          // Các routes cho các màn hình xác thực
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-otp': (context) => const VerifyOtpScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          
          // Route cho màn hình chính
          '/map': (context) => const MapScreen(),
          
          // Route cho màn hình tạo cửa hàng - nhận AuthViewModel qua arguments
          '/create-store': (context) {
            final authViewModel = ModalRoute.of(context)!.settings.arguments as AuthViewModel;
            return AddStoreScreen(authViewModel: authViewModel);
          },
          
          // Route cho màn hình chỉnh sửa cửa hàng - nhận StoreModel qua arguments
          '/edit-store': (context) {
            final store = ModalRoute.of(context)!.settings.arguments as StoreModel;
            return EditStoreScreen(store: store);
          },
          
          // Route profile đã được comment out
          // '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}