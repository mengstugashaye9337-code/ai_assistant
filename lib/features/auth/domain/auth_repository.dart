import '../domain/user.dart';

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<User> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  );
  Future<void> signOut();
  Future<User?> getCurrentUser();
}
