import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String initials;
  final String kycStatus;
  final DateTime createdAt;
  final String? membershipTier; // 'standard', 'gold', 'platinum'

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    required this.kycStatus,
    required this.createdAt,
    this.membershipTier = 'gold',
  });

  factory UserModel.fromJson(String docId, Map<String, dynamic> json) {
    return UserModel(
      id: docId,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? 'verified',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      membershipTier: json['membershipTier'] as String? ?? 'standard',
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) =>
      UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'initials': initials,
        'kycStatus': kycStatus,
        'createdAt': Timestamp.fromDate(createdAt),
        'membershipTier': membershipTier,
      };
}
