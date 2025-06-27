import 'service_model.dart';

class ServicesResponseModel {
  final String message;
  final List<ServiceModel> services;

  ServicesResponseModel({
    required this.message,
    required this.services,
  });

  factory ServicesResponseModel.fromJson(Map<String, dynamic> json) {
    return ServicesResponseModel(
      message: json['message'] ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceModel.fromJson(service))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}
