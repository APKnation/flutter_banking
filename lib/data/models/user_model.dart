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
}
