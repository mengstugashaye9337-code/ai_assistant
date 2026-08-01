import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:ai_assistant/features/auth/infrastructure/mapper.dart';
import 'package:ai_assistant/features/auth/domain/user.dart' as domain;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client: client);
});

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required this._client});

  final SupabaseClient _client;

  @override
  Future<domain.User> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final authUser = response.user;
    if (authUser == null) {
      throw Exception('Failed to sign in');
    }
    final profile = await _fetchProfile(authUser.id);
    return UserMapper.fromSupabase(authUser: authUser, profile: profile);
  }

  @override
  Future<domain.User> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final authUser = response.user;
    if (authUser == null) {
      throw Exception('Failed to sign up');
    }

    final profile = await _client
        .from('profiles')
        .insert({
          'id': authUser.id,
          'first_name': firstName,
          'last_name': lastName,
        })
        .select()
        .single();

    return UserMapper.fromSupabase(authUser: authUser, profile: profile);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    final profile = await _fetchProfile(currentUser.id);

    return UserMapper.fromSupabase(authUser: currentUser, profile: profile);
  }

  Future<Map<String, dynamic>> _fetchProfile(String id) async {
    return await _client.from('profiles').select().eq('id', id).single();
  }
}
