import '../bids/bid_model.dart';
import 'project_model.dart';

class ProjectDetailResponseModel {
  final ProjectModel project;
  final bool? userHasBid;
  final BidModel? userBid;

  ProjectDetailResponseModel({
    required this.project,
    this.userHasBid,
    this.userBid,
  });

  factory ProjectDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponseModel(
      project: ProjectModel.fromJson(json['project']),
      userHasBid: json['user_has_bid'],
      userBid:
          json['user_bid'] != null ? BidModel.fromJson(json['user_bid']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project': project.toJson(),
      'user_has_bid': userHasBid,
      'user_bid': userBid?.toJson(),
    };
  }
}
