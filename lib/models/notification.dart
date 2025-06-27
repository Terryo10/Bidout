import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int id;
  final int userId;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, type, data, readAt, createdAt, updatedAt];

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'data': data,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isRead => readAt != null;

  String get title {
    switch (type) {
      case 'new_bid':
        return 'New Bid Received';
      case 'bid_accepted':
        return 'Bid Accepted';
      case 'bid_rejected':
        return 'Bid Rejected';
      case 'project_completed':
        return 'Project Completed';
      case 'new_message':
        return 'New Message';
      case 'new_review':
        return 'New Review';
      default:
        return 'Notification';
    }
  }

  String get message {
    return data['message'] ?? 'No message';
  }

  Notification copyWith({
    int? id,
    int? userId,
    String? type,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
