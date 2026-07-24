import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../domain/user.dart';

class UserMapper {
  /// Converts Supabase authentication user + profile table
  /// into our application's User entity.
  static User fromSupabase({
    required supabase.User authUser,
    required Map<String, dynamic> profile,
  }) {
    return User(
      id: authUser.id,
      firstName: profile['first_name'] as String,
      lastName: profile['last_name'] as String,
      email: authUser.email ?? '',
      emailVerified: authUser.emailConfirmedAt != null,
    );
  }

  /// Converts our User entity into a row for the profiles table.
  static Map<String, dynamic> toProfile(User user) {
    return {
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'email': user.email,
    };
  }
}
