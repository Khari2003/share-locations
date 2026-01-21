import 'package:latlong2/latlong.dart';

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() => 'Coordinates(latitude: $latitude, longitude: $longitude)';

  Map<String, dynamic> toJson() => {
        'coordinates': [longitude, latitude],
      };
}