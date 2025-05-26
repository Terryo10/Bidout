class ProjectRequestModel {
  final String title;
  final String description;
  final double budget;
  final String frequency;
  final String keyFactor;
  final DateTime startDate;
  final DateTime endDate;
  final int serviceId;
  final bool isDrafted;
  final String? additionalRequirements;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final List<String> images;

  ProjectRequestModel({
    required this.title,
    required this.description,
    required this.budget,
    required this.frequency,
    required this.keyFactor,
    required this.startDate,
    required this.endDate,
    required this.serviceId,
    required this.isDrafted,
    this.additionalRequirements,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    required this.images,
  });
}
