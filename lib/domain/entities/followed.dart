import 'package:equatable/equatable.dart';

// Lớp thực thể Followed đại diện cho thông tin theo dõi trong domain layer
class Followed extends Equatable {
  final String? user;
  final DateTime? followedAt;

  const Followed({this.user, this.followedAt});

  @override
  List<Object?> get props => [user, followedAt];
}