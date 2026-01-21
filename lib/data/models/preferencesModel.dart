import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/preferences.dart';

// Lớp mô hình PreferencesModel đại diện cho dữ liệu sở thích trong data layer
class PreferencesModel extends Equatable {
  final List<String>? dietary;
  final List<String>? cuisine;
  final String? priceRange;

  const PreferencesModel({this.dietary, this.cuisine, this.priceRange});

  // Chuyển đổi từ JSON sang PreferencesModel
  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      dietary: (json['dietary'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      cuisine: (json['cuisine'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      priceRange: json['priceRange'],
    );
  }

  // Chuyển đổi PreferencesModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'dietary': dietary,
      'cuisine': cuisine,
      'priceRange': priceRange,
    };
  }

  // Chuyển đổi PreferencesModel sang thực thể Preferences trong domain layer
  Preferences toEntity() {
    return Preferences(
      dietary: dietary,
      cuisine: cuisine,
      priceRange: priceRange,
    );
  }

  @override
  List<Object?> get props => [dietary, cuisine, priceRange];
}