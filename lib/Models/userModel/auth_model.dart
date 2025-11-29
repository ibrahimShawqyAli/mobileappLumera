import 'package:smart_home_iotz/Models/homeModel/home_overview.dart';
import 'package:smart_home_iotz/Models/userModel/userModel.dart';

class AuthResponse {
  final UserModel user;
  final String access;
  final String refresh;
  final List<HomeOverview> overview;

  const AuthResponse({
    required this.user,
    required this.access,
    required this.refresh,
    required this.overview,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    access: (json['access'] ?? '').toString(),
    refresh: (json['refresh'] ?? '').toString(),
    overview:
        (json['overview'] as List<dynamic>? ?? const [])
            .map((e) => HomeOverview.fromJson(e as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'access': access,
    'refresh': refresh,
    'overview': overview.map((e) => e.toJson()).toList(),
  };
}
