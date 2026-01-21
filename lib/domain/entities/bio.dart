import 'package:equatable/equatable.dart';

// Lớp thực thể Bio đại diện cho thông tin tiểu sử trong domain layer
class Bio extends Equatable {
  final String? intro;
  final String? website;

  const Bio({this.intro, this.website});

  @override
  List<Object?> get props => [intro, website];
}