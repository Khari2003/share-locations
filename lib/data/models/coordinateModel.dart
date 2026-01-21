// ignore_for_file: file_names

import '../../domain/entities/coordinates.dart';

class CoordinateModel extends Coordinates {
  CoordinateModel({
    required super.latitude,
    required super.longitude,
  });

  factory CoordinateModel.fromJson(Map<String, dynamic> json) {
    return CoordinateModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}