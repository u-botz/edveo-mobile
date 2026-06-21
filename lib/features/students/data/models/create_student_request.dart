class CreateStudentRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;

  const CreateStudentRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        // role_slug intentionally omitted — backend always injects 'student'
      };
}
