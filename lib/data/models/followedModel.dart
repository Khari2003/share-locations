import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/followed.dart';

// Lớp mô hình FollowedModel đại diện cho dữ liệu theo dõi trong data layer
class FollowedModel extends Equatable {
  final String? user;
  final DateTime? followedAt;

  const FollowedModel({this.user, this.followedAt});

  // Chuyển đổi từ JSON sang FollowedModel
  factory FollowedModel.fromJson(Map<String, dynamic> json) {
    return FollowedModel(
      user: json['user']?.toString(),
      followedAt: json['followedAt'] != null ? DateTime.parse(json['followedAt']) : null,
    );
  }

  // Chuyển đổi FollowedModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'followedAt': followedAt?.toIso8601String(),
    };
  }

  // Chuyển đổi FollowedModel sang thực thể Followed trong domain layer
  Followed toEntity() {
    return Followed(
      user: user,
      followedAt: followedAt,
    );
  }

  @override
  List<Object?> get props => [user, followedAt];
}