class ServiceRequestModel {
  final int id;
  final int clientId;
  final int contractorId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClientInfo? client;
  final ContractorInfo? contractor;

  ServiceRequestModel({
    required this.id,
    required this.clientId,
    required this.contractorId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.contractor,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'],
      clientId: json['client_id'],
      contractorId: json['contractor_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      client:
          json['client'] != null ? ClientInfo.fromJson(json['client']) : null,
      contractor: json['contractor'] != null
          ? ContractorInfo.fromJson(json['contractor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'contractor_id': contractorId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'client': client?.toJson(),
      'contractor': contractor?.toJson(),
    };
  }

  ServiceRequestModel copyWith({
    int? id,
    int? clientId,
    int? contractorId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientInfo? client,
    ContractorInfo? contractor,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      contractorId: contractorId ?? this.contractorId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      contractor: contractor ?? this.contractor,
    );
  }
}

class ClientInfo {
  final int id;
  final String name;
  final String email;
  final String? phone;

  ClientInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class ContractorInfo {
  final int id;
  final String name;
  final String email;
  final String? phone;

  ContractorInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory ContractorInfo.fromJson(Map<String, dynamic> json) {
    return ContractorInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class CreateServiceRequestModel {
  final int contractorId;
  final String message;

  CreateServiceRequestModel({
    required this.contractorId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'contractor_id': contractorId,
      'message': message,
    };
  }
}

class ServiceRequestsResponse {
  final List<ServiceRequestModel> data;
  final int currentPage;
  final int lastPage;
  final int total;

  ServiceRequestsResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ServiceRequestsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRequestsResponse(
      data: (json['data'] as List)
          .map((item) => ServiceRequestModel.fromJson(item))
          .toList(),
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
    );
  }
}
