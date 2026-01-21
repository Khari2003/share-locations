import 'package:equatable/equatable.dart';
import 'package:my_app/domain/entities/bio.dart';

// Lớp mô hình BioModel đại diện cho dữ liệu tiểu sử trong data layer
class BioModel extends Equatable {
  final String? intro;
  final String? website;

  const BioModel({this.intro, this.website});

  // Chuyển đổi từ JSON sang BioModel
  factory BioModel.fromJson(Map<String, dynamic> json) {
    return BioModel(
      intro: json['intro'],
      website: json['website'],
    );
  }

  // Chuyển đổi BioModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'intro': intro,
      'website': website,
    };
  }

  // Chuyển đổi BioModel sang thực thể Bio trong domain layer
  Bio toEntity() {
    return Bio(
      intro: intro,
      website: website,
    );
  }

  @override
  List<Object?> get props => [intro, website];
}