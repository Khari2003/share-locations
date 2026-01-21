import 'package:equatable/equatable.dart';

// Lớp thực thể Preferences đại diện cho sở thích của người dùng trong domain layer
class Preferences extends Equatable {
  final List<String>? dietary;
  final List<String>? cuisine;
  final String? priceRange;

  const Preferences({this.dietary, this.cuisine, this.priceRange});

  @override
  List<Object?> get props => [dietary, cuisine, priceRange];
}