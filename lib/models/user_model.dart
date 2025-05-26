class UserModel {
  final int id;
  final String name;
  final String email;
  final String userType; // 'client' or 'contractor'
  final String? phone;
  final String? contractorStatus; // 'pending', 'approved', 'rejected'
  final String subscriptionStatus; // 'free', 'basic', 'professional', 'enterprise'
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone,
    this.contractorStatus,
    required this.subscriptionStatus,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      userType: json['user_type'],
      phone: json['phone'],
      contractorStatus: json['contractor_status'],
      subscriptionStatus: json['subscription_status'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      roles: json['roles'] != null
          ? List<String>.from(json['roles'].map((role) => role['name']))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_type': userType,
      'phone': phone,
      'contractor_status': contractorStatus,
      'subscription_status': subscriptionStatus,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles,
    };
  }

  bool get isClient => userType == 'client';
  bool get isContractor => userType == 'contractor';
  bool get isContractorApproved => contractorStatus == 'approved';
  bool get hasActiveSubscription => subscriptionStatus != 'free';
}