import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/location.dart';
import 'package:my_app/domain/entities/coordinates.dart';

// Lớp mô hình UserModel đại diện cho dữ liệu người dùng trong data layer
class UserModel extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? passwordHash;
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

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.passwordHash,
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

  // Chuyển đổi từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    Coordinates? coordinates;
    if (json['location']?['coordinates']?['coordinates'] != null) {
      coordinates = Coordinates(
        longitude: (json['location']['coordinates']['coordinates'][0] as num).toDouble(),
        latitude: (json['location']['coordinates']['coordinates'][1] as num).toDouble(),
      );
    }
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      gender: json['gender'],
      phone: json['phone'],
      profilePhoto: json['profilephoto'],
      storyDate: json['storydate'] != null ? DateTime.parse(json['storydate']) : null,
      isAdmin: json['isAdmin'],
      location: json['location'] != null
          ? Location(
              address: json['location']['address'] as String?,
              city: json['location']['city'] as String?,
              postalCode: json['location']['postalCode'] as String?,
              country: json['location']['country'] as String?,
              coordinates: coordinates,
            )
          : null,
      favoriteStores: (json['favoriteStores'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      wishList: (json['wishList'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      conversations: (json['conversations'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      resetPasswordOtp: json['resetPasswordOtp'],
      resetPasswordOtpExpiration: json['resetPasswordOtpExpiration'] != null
          ? DateTime.parse(json['resetPasswordOtpExpiration'])
          : null,
    );
  }

  // Chuyển đổi UserModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'gender': gender,
      'phone': phone,
      'profilephoto': profilePhoto,
      'storydate': storyDate?.toIso8601String(),
      'isAdmin': isAdmin,
      'location': location?.toJson(),
      'favoriteStores': favoriteStores,
      'wishList': wishList,
      'conversations': conversations,
      'resetPasswordOtp': resetPasswordOtp,
      'resetPasswordOtpExpiration': resetPasswordOtpExpiration?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        passwordHash,
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