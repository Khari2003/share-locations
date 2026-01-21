import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/location.dart';

// Lớp thực thể User đại diện cho người dùng trong domain layer
class User extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? phone;
  final String? profilePhoto;
  final DateTime? storyDate;
  final bool? isAdmin;
  final Location? location;
  final List<String>? favoriteStores;
  final List<String>? wishList;
  final List<String>? conversations;
  final String? resetPasswordOtp;
  final DateTime? resetPasswordOtpExpiration;

  const User({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.phone,
    this.profilePhoto,
    this.storyDate,
    this.isAdmin,
    this.location,
    this.favoriteStores,
    this.wishList,
    this.conversations,
    this.resetPasswordOtp,
    this.resetPasswordOtpExpiration,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        gender,
        phone,
        profilePhoto,
        storyDate,
        isAdmin,
        location,
        favoriteStores,
        wishList,
        conversations,
        resetPasswordOtp,
        resetPasswordOtpExpiration,
      ];
}