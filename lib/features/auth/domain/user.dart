class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool emailVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.emailVerified = false,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}

//   bool get isVerified => emailVerified;

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'firstName': firstName,
//     'lastName': lastName,
//     'email': email,
//     'emailVerified': emailVerified,
//   };

//   factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
//     id: json['id'] as String? ?? '',
//     firstName: json['firstName'] as String? ?? '',
//     lastName: json['lastName'] as String? ?? '',
//     email: json['email'] as String? ?? '',
//     emailVerified: json['emailVerified'] as bool? ?? false,
//   );

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is AuthModel &&
//           runtimeType == other.runtimeType &&
//           id == other.id &&
//           firstName == other.firstName &&
//           lastName == other.lastName &&
//           email == other.email &&
//           emailVerified == other.emailVerified;

//   @override
//   int get hashCode =>
//       id.hashCode ^
//       firstName.hashCode ^
//       lastName.hashCode ^
//       email.hashCode ^
//       emailVerified.hashCode;
// }
