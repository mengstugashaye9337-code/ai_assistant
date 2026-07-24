import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

//import 'package:ai_assistant/features/auth/presentation/home_page.dart';
//import 'package:ai_assistant/features/auth/presentation/setting.dart';

import 'package:go_router/go_router.dart';

import 'package:ai_assistant/core/router/app_router.dart';

//import 'package:ai_assistant/features/auth/presentation/validator.dart';
//import 'package:ai_assistant/features/auth/presentation/auth_gate.dart';
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('profile')),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (state) {
          switch (state) {
            case Authenticated():
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(Icons.person, size: 50),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${state.user.firstName} ${state.user.lastName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.user.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('setting'),
                    onTap: () => context.go(AppRoutes.settings),
                  ),
                ],
              );
            case Unauthenticated():
              return Center(
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.signIn),
                  child: const Text('go to signin'),
                ),
              );
          }
        },
      ),
    );
  }
}
