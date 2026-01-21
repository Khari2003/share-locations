import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/coordinates.dart';

class Location with EquatableMixin {
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final Coordinates? coordinates;

  Location({
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.coordinates,
  });

  @override
  List<Object?> get props => [address, city, postalCode, country, coordinates];

  @override
  String toString() => 'Location(address: $address, city: $city, postalCode: $postalCode, country: $country, coordinates: $coordinates)';

  // Thêm phương thức toJson
  Map<String, dynamic> toJson() => {
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (postalCode != null) 'postalCode': postalCode,
        if (country != null) 'country': country,
        if (coordinates != null) 'coordinates': coordinates!.toJson(),
      };
}