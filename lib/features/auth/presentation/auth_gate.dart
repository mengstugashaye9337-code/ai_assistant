import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:ai_assistant/features/auth/presentation/home_page.dart';
import 'package:ai_assistant/features/auth/presentation/signup_page.dart';
import 'package:ai_assistant/features/auth/presentation/signin_page.dart';
//import 'package:ai_assistant/features/auth/presentation/login_screen.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (state) {
        switch (state) {
          case Authenticated():
            return const HomePage();
          case Unauthenticated():
            return const SignInPage();
        }
      },
      loading: () =>
          const SplashPage();
      error: (error, stackTrace) =>
          const ErrorPage(),
    );
  }
}
