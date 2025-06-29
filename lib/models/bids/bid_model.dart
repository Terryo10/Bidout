import '../contractor/contractor_model.dart';
import '../projects/project_model.dart';

class BidModel {
  final int id;
  final int projectId;
  final int contractorId;
  final double amount;
  final String description;
  final int timeline; // Timeline in days
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime? proposedStartDate;
  final DateTime? proposedEndDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectModel? project;
  final ContractorModel? contractor;

  BidModel({
    required this.id,
    required this.projectId,
    required this.contractorId,
    required this.amount,
    required this.description,
    required this.timeline,
    required this.status,
    this.proposedStartDate,
    this.proposedEndDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.project,
    this.contractor,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get canBeEdited => isPending;
  bool get canBeWithdrawn => isPending;

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'],
      projectId: json['project_id'],
      contractorId: json['contractor_id'],
      amount: double.parse(json['amount'].toString()),
      description: json['proposal'] ?? json['description'] ?? '',
      timeline:
          _parseTimeline(json['estimated_duration'] ?? json['timeline'] ?? 0),
      status: json['status'] ?? 'pending',
      proposedStartDate: json['proposed_start_date'] != null
          ? DateTime.parse(json['proposed_start_date'])
          : null,
      proposedEndDate: json['proposed_end_date'] != null
          ? DateTime.parse(json['proposed_end_date'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'])
          : null,
      contractor: json['contractor'] != null
          ? ContractorModel.fromJson(json['contractor'])
          : null,
    );
  }

  static int _parseTimeline(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'contractor_id': contractorId,
      'amount': amount,
      'description': description,
      'timeline': timeline,
      'status': status,
      'proposed_start_date': proposedStartDate?.toIso8601String(),
      'proposed_end_date': proposedEndDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'project': project?.toJson(),
      'contractor': contractor?.toJson(),
    };
  }

  BidModel copyWith({
    int? id,
    int? projectId,
    int? contractorId,
    double? amount,
    String? description,
    int? timeline,
    String? status,
    DateTime? proposedStartDate,
    DateTime? proposedEndDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectModel? project,
    ContractorModel? contractor,
  }) {
    return BidModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      contractorId: contractorId ?? this.contractorId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timeline: timeline ?? this.timeline,
      status: status ?? this.status,
      proposedStartDate: proposedStartDate ?? this.proposedStartDate,
      proposedEndDate: proposedEndDate ?? this.proposedEndDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      project: project ?? this.project,
      contractor: contractor ?? this.contractor,
    );
  }
}

class BidRequestModel {
  final int projectId;
  final double amount;
  final String description;
  final int timeline;
  final DateTime? proposedStartDate;
  final DateTime? proposedEndDate;
  final String? notes;

  BidRequestModel({
    required this.projectId,
    required this.amount,
    required this.description,
    required this.timeline,
    this.proposedStartDate,
    this.proposedEndDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'amount': amount,
      'proposal': description,
      'estimated_duration': timeline.toString(),
      'proposed_start_date': proposedStartDate?.toIso8601String(),
      'proposed_end_date': proposedEndDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
