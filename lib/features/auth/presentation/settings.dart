import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_assistant/features/auth/presentation/user_header.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: authState.when(
        error: error,
        loading: loading,
        data: (state) {
          switch (state) {
            case Authenticated():
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  UserHeader(
                    firstName: state.user.firstName,
                    lastName: state.user.lastName,
                    email:state.user.lastName
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.light),
                          title: const Text('theme'),
                          onTap: () => context.go(),
                        ),
                        ListTile(
                        leading: Icon(Icons.notification_important),
                        title: const Text('Notification'),
                        onTap: () => context.go(),
                        ),
                        ListTile(
                        leading: Icon(Icons.notification_important),
                        title: const Text('Notification'),
                        onTap: () => context.go(),),

                        ElevatedButton(onPressed:()async{await ref.read(authNotifierProvider.notifier).signOut()} , 
                        child: Text('SignOut'))
                      ],
                      ),
                      )
                ],
              );
            case Unauthenticated():
             return const SizedBox();
          }
        },
      ),
    );
  }
}
