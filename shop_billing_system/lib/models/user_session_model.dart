class UserSession {
  final String userId;
  final String name;
  final String role;
  final String businessId;
  final String businessName;

  UserSession({
    required this.userId,
    required this.name,
    required this.role,
    required this.businessId,
    this.businessName = 'Jinnah Super Market',
  });

  factory UserSession.guest() {
    return UserSession(
      userId: 'usr_admin',
      name: 'Administrator',
      role: 'Owner',
      businessId: 'biz_default',
      businessName: 'Jinnah Super Market',
    );
  }

  factory UserSession.fromMap(Map<dynamic, dynamic> map) {
    return UserSession(
      userId: map['userId']?.toString() ?? 'usr_admin',
      name: map['name']?.toString() ?? 'Administrator',
      role: map['role']?.toString() ?? 'Owner',
      businessId: map['businessId']?.toString() ?? 'biz_default',
      businessName: map['businessName']?.toString() ?? 'Jinnah Super Market',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'businessId': businessId,
      'businessName': businessName,
    };
  }
}
