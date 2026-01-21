import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Auth datasources & repositories
import 'package:my_app/data/datasources/auth/authDatasource.dart';
import 'package:my_app/data/repositories/authRepositoryImpl.dart';
import 'package:my_app/domain/repositories/authRepository.dart';

// Coordinate datasources & repositories
import 'package:my_app/data/datasources/coordinates/coordinateDatasource.dart';
import 'package:my_app/data/repositories/coordinateRepositoryImpl.dart';
import 'package:my_app/domain/repositories/coordinateRepository.dart';

// OSM datasources & repositories
import 'package:my_app/data/datasources/osm/osmDatasource.dart';
import 'package:my_app/data/repositories/osmRepositoryImpl.dart';
import 'package:my_app/domain/repositories/osmRepository.dart';

// Review datasources & repositories
import 'package:my_app/data/datasources/review/reviewDatasource.dart';
import 'package:my_app/data/repositories/reviewRepositoryImpl.dart';
import 'package:my_app/domain/repositories/reviewRepository.dart';

// Route datasources & repositories
import 'package:my_app/data/datasources/route/routeDatasource.dart';
import 'package:my_app/data/repositories/routeRepositoryImpl.dart';
import 'package:my_app/domain/repositories/routeRepository.dart';

// Store datasources & repositories
import 'package:my_app/data/datasources/store/storeDatasource.dart';
import 'package:my_app/data/repositories/storeRepositoryImpl.dart';
import 'package:my_app/domain/repositories/storeRepository.dart';

// User datasources & repositories
import 'package:my_app/data/datasources/user/userDatasource.dart';
import 'package:my_app/data/repositories/userRepositoryImpl.dart';
import 'package:my_app/domain/repositories/userRepository.dart';

// OCR datasources & repositories
import 'package:my_app/data/datasources/orc/ocrDatasource.dart';
import 'package:my_app/data/repositories/ocrRepositoryImpl.dart';
import 'package:my_app/domain/repositories/ocrRepository.dart';

// Auth use cases
import 'package:my_app/domain/usecases/auth/forgotPassword.dart';
import 'package:my_app/domain/usecases/auth/login.dart';
import 'package:my_app/domain/usecases/auth/register.dart';
import 'package:my_app/domain/usecases/auth/resetPassword.dart';
import 'package:my_app/domain/usecases/auth/verifyOtp.dart';

// Location use cases
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/searchPlaces.dart';
import 'package:my_app/domain/usecases/getRoute.dart';

// Review use cases
import 'package:my_app/domain/usecases/review/getStoreReviews.dart';
import 'package:my_app/domain/usecases/review/leaveReview.dart';

// Store use cases
import 'package:my_app/domain/usecases/store/createStore.dart';
import 'package:my_app/domain/usecases/store/deleteStore.dart';
import 'package:my_app/domain/usecases/store/getStores.dart';
import 'package:my_app/domain/usecases/store/updateStore.dart';

// User use cases
import 'package:my_app/domain/usecases/user/getUsers.dart';
import 'package:my_app/domain/usecases/user/getUserById.dart';
import 'package:my_app/domain/usecases/user/updateUser.dart';
import 'package:my_app/domain/usecases/user/updatePreferences.dart';
import 'package:my_app/domain/usecases/user/getUserReviews.dart';
import 'package:my_app/domain/usecases/user/createConversation.dart';
import 'package:my_app/domain/usecases/user/getConversations.dart';

// OCR use cases
import 'package:my_app/domain/usecases/extractMenuFromImage.dart';

// View Models
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/screens/review/reviewViewModel.dart';
import 'package:my_app/presentation/screens/search/searchPlacesViewModel.dart';
import 'package:my_app/presentation/screens/store/storeViewModel.dart';
import 'package:my_app/presentation/screens/profile/profileModelView.dart';

/// Service Locator - Quản lý Dependency Injection cho toàn bộ ứng dụng
final sl = GetIt.instance;

/// Khởi tạo tất cả dependencies
/// Gọi hàm này trong main() trước khi chạy app
Future<void> init() async {
  // ============= EXTERNAL DEPENDENCIES =============
  // HTTP Client - Sử dụng chung cho tất cả network requests
  sl.registerLazySingleton(() => http.Client());

  // ============= DATA SOURCES =============
  // Auth - Xác thực người dùng
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));
  
  // Coordinate - Lấy vị trí hiện tại
  sl.registerLazySingleton<CoordinateDataSource>(() => CoordinateDataSourceImpl());
  
  // OSM - OpenStreetMap API (tìm kiếm địa điểm, reverse geocoding)
  sl.registerLazySingleton<OSMDataSource>(() => OSMDataSourceImpl());
  
  // Review - Đánh giá cửa hàng
  sl.registerLazySingleton<ReviewDataSource>(() => ReviewDataSourceImpl(sl()));
  
  // Route - Tìm đường đi
  sl.registerLazySingleton<RouteDataSource>(() => RouteDataSourceImpl());
  
  // Store - Quản lý cửa hàng
  sl.registerLazySingleton<StoreDataSource>(() => StoreDataSourceImpl(sl()));
  
  // User - Quản lý người dùng
  sl.registerLazySingleton<UserDataSource>(() => UserDataSourceImpl(sl()));
  
  // OCR - Trích xuất menu từ ảnh bằng AI
  sl.registerLazySingleton<OcrDataSource>(() => OcrDataSourceImpl(sl()));

  // ============= REPOSITORIES =============
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  
  // Coordinate Repository
  sl.registerLazySingleton<CoordinateRepository>(() => CoordinateRepositoryImpl(sl()));
  
  // OSM Repository
  sl.registerLazySingleton<OSMRepository>(() => OSMRepositoryImpl(sl()));
  
  // Review Repository
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(dataSource: sl()));
  
  // Route Repository
  sl.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(sl()));
  
  // Store Repository
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(sl()));
  
  // User Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  
  // OCR Repository
  sl.registerLazySingleton<OcrRepository>(() => OcrRepositoryImpl(sl()));

  // ============= USE CASES =============
  
  // --- Auth Use Cases ---
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  
  // --- Location Use Cases ---
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));
  
  // --- Review Use Cases ---
  sl.registerLazySingleton(() => LeaveReview(sl()));
  sl.registerLazySingleton(() => GetStoreReviews(sl()));
  
  // --- Store Use Cases ---
  sl.registerLazySingleton(() => CreateStore(sl()));
  sl.registerLazySingleton(() => UpdateStore(sl()));
  sl.registerLazySingleton(() => DeleteStore(sl()));
  sl.registerLazySingleton(() => GetStores(sl()));
  
  // --- User Use Cases ---
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => GetUserById(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => UpdatePreferences(sl()));
  sl.registerLazySingleton(() => GetUserReviews(sl()));
  sl.registerLazySingleton(() => CreateConversation(sl()));
  sl.registerLazySingleton(() => GetConversations(sl()));
  
  // --- OCR Use Cases ---
  // ExtractMenuFromImage: Trích xuất menu từ ảnh sử dụng AI
  sl.registerLazySingleton(() => ExtractMenuFromImage(sl()));

  // ============= VIEW MODELS =============
  
  // AuthViewModel - Singleton vì cần duy trì trạng thái đăng nhập
  sl.registerSingleton<AuthViewModel>(
    AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyOtpUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
  
  // MapViewModel - Factory vì mỗi màn hình map cần instance riêng
  sl.registerFactory(() => MapViewModel(
        getCurrentLocation: sl(),
        getStores: sl(),
        getRoute: sl(),
      ));
  
  // ReviewViewModel - Factory vì mỗi màn hình review cần instance riêng
  sl.registerFactory(() => ReviewViewModel(
        leaveReview: sl(),
        getStoreReviews: sl(),
      ));
  
  // SearchPlacesViewModel - Factory vì mỗi lần tìm kiếm cần instance mới
  sl.registerFactory(() => SearchPlacesViewModel(searchPlaces: sl()));
  
  // StoreViewModel - Factory vì mỗi màn hình tạo/sửa store cần instance riêng
  sl.registerFactory(() => StoreViewModel(
        createStoreUseCase: sl(),
        searchPlacesUseCase: sl(),
        osmDataSource: sl(),
        getCurrentLocation: sl(),
        updateStoreUseCase: sl(),
        deleteStoreUseCase: sl(),
      ));
  
  // ProfileViewModel - Factory vì mỗi màn hình profile cần instance riêng
  sl.registerFactory(() => ProfileViewModel());
}