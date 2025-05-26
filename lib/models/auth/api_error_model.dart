class ApiErrorModel {
  final String message;
  final Map<String, List<String>>? errors;

  ApiErrorModel({
    required this.message,
    this.errors,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              ),
            )
          : null,
    );
  }

  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first;
    }
    return message;
  }
}
