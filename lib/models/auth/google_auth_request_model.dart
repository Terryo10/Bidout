import 'package:equatable/equatable.dart';

class GoogleAuthRequestModel extends Equatable {
  final String idToken;
  final String userType;

  const GoogleAuthRequestModel({
    required this.idToken,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      'user_type': userType,
    };
  }

  @override
  List<Object> get props => [idToken, userType];
}
