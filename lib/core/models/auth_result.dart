import 'tenant_user.dart';

class AuthResult {
  final bool isSuccess;
  final TenantUser? user;
  final String? errorMessage;
  final int? statusCode;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.statusCode,
  });

  factory AuthResult.success({required TenantUser user}) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure({
    required String message,
    int? statusCode,
  }) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}
