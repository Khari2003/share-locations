// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_app/domain/usecases/searchPlaces.dart';

enum SearchType { specific, region }

class SearchPlacesViewModel extends ChangeNotifier {
  final SearchPlaces searchPlaces;

  SearchPlacesViewModel({required this.searchPlaces}) {
    _loadProvinces();
  }

  SearchType _searchType = SearchType.specific;
  String _query = '';
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _wards = [];
  String? _selectedProvince;
  String? _selectedWard;
  double _radius = 1000.0;

  SearchType get searchType => _searchType;
  String get query => _query;
  List<Map<String, String>> get results => _results;
  bool get isLoading => _isLoading;
  List<Map<String, String>> get provinces => _provinces;
  List<Map<String, String>> get wards => _wards;
  String? get selectedProvince => _selectedProvince;
  String? get selectedWard => _selectedWard;
  double get radius => _radius;
  bool get canSearchRegion => _selectedProvince != null;

  void updateSearchType(SearchType type) {
    _searchType = type;
    _results = [];
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void updateProvince(String? value) async {
    _selectedProvince = value;
    _selectedWard = null;
    _wards = await _loadWards(value);
    notifyListeners();
  }

  void updateWard(String? value) {
    _selectedWard = value;
    notifyListeners();
  }

  void updateRadius(double value) {
    _radius = value;
    notifyListeners();
  }

  Future<void> _loadProvinces() async {
    try {
      final String response = await rootBundle.loadString('province.json');
      final Map<String, dynamic> data = json.decode(response);
      
      _provinces = data.entries.map((entry) {
        final provinceData = entry.value as Map<String, dynamic>;
        return {
          'code': provinceData['code'].toString(),
          'name': provinceData['name'].toString(),
          'name_with_type': provinceData['name_with_type'].toString(),
        };
      }).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading province.json: $e');
    }
  }

  Future<List<Map<String, String>>> _loadWards(String? provinceCode) async {
    if (provinceCode == null) return [];
    try {
      final String response = await rootBundle.loadString('ward.json');
      final Map<String, dynamic> data = json.decode(response);
      
      return data.entries
          .where((entry) {
            final wardData = entry.value as Map<String, dynamic>;
            return wardData['parent_code'].toString() == provinceCode;
          })
          .map((entry) {
            final wardData = entry.value as Map<String, dynamic>;
            return {
              'code': wardData['code'].toString(),
              'name': wardData['name'].toString(),
              'name_with_type': wardData['name_with_type'].toString(),
              'parent_code': wardData['parent_code'].toString(),
            };
          })
          .toList();
    } catch (e) {
      print('Error loading wards: $e');
      return [];
    }
  }

  Future<void> search() async {
    // Kiểm tra điều kiện tìm kiếm trước khi thực hiện
    if (_searchType == SearchType.specific && _query.isEmpty) return;
    if (_searchType == SearchType.region && _selectedProvince == null) return;

    // Đặt trạng thái đang tải và thông báo cho listeners
    _isLoading = true;
    notifyListeners();

    if (_searchType == SearchType.specific) {
      // Tìm kiếm địa điểm cụ thể theo tên/địa chỉ
      final result = await searchPlaces(_query);
      
      result.fold(
        (failure) {
          // Xử lý lỗi khi tìm kiếm thất bại
          _results = [];
          print('Error searching places: $failure');
        },
        (places) {
          // Chuyển đổi kết quả tìm kiếm sang định dạng map cho vị trí chính xác
          _results = places.map((place) {
            return {
              'lat': place.coordinates.latitude.toString(),
              'lon': place.coordinates.longitude.toString(),
              'name': place.name,
              'type': 'exact', // Đánh dấu là tìm kiếm vị trí chính xác
            };
          }).toList();
        },
      );
    } else {
      // Tìm kiếm theo khu vực: Xây dựng truy vấn từ tỉnh/phường đã chọn
      
      // Tìm thông tin tỉnh/thành phố đã chọn
      final province = _provinces.firstWhere(
        (p) => p['code'] == _selectedProvince,
        orElse: () => {},
      );

      // Tìm thông tin phường/xã đã chọn nếu có
      final ward = _selectedWard != null
          ? _wards.firstWhere(
              (w) => w['code'] == _selectedWard,
              orElse: () => {},
            )
          : {};

      // Xây dựng chuỗi truy vấn từ các đơn vị hành chính đã chọn
      List<String> queryParts = [];
      if (ward['name'] != null && ward['name']!.isNotEmpty) {
        queryParts.add(ward['name']!);
      }
      if (province['name'] != null && province['name']!.isNotEmpty) {
        queryParts.add(province['name']!);
      }
      
      // Nối các phần với dấu phẩy (ví dụ: "Hoàn Kiếm, Hà Nội")
      final query = queryParts.join(', ');

      // Thực hiện tìm kiếm theo khu vực
      final result = await searchPlaces(query);
      
      result.fold(
        (failure) {
          // Xử lý lỗi khi tìm kiếm thất bại
          _results = [];
          print('Error searching region: $failure');
        },
        (places) {
          // Chuyển đổi kết quả với loại khu vực và thông tin bán kính
          _results = places.map((place) {
            return {
              'lat': place.coordinates.latitude.toString(),
              'lon': place.coordinates.longitude.toString(),
              'name': place.name,
              'type': 'region', // Đánh dấu là tìm kiếm theo khu vực
              'radius': _radius.toString(), // Bao gồm bán kính tìm kiếm
            };
          }).toList();
        },
      );
    }

    // Tắt trạng thái đang tải và thông báo cho listeners
    _isLoading = false;
    notifyListeners();
  }
}