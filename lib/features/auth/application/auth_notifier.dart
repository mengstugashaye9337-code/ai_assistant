import 'package:ai_assistant/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_auth_repository.dart';
import 'package:ai_assistant/features/auth/domain/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

final class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;
  @override
  Future<AuthState> build() async {
    _repository = ref.read(authRepositoryProvider);

    final user = await _repository.getCurrentUser();

    if (user != null) {
      return Authenticated(user);
    }

    return Unauthenticated();
  }

  Future<void> signIn(String email, String password) async {
    //final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.signIn(email, password);
      return Authenticated(user);
    });
  }

  Future<void> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    //final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.signUp(
        firstName,
        lastName,
        email,
        password,
      );
      return Authenticated(user);
    });
  }

  Future<void> signOut() async {
    //final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    await _repository.signOut();
    state = AsyncData(Unauthenticated());
  }
}
