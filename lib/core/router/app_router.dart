import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/home_page.dart';

import 'auth_refresh_listenable.dart';
import '../../features/auth/presentation/settings.dart';
import '../../features/auth/presentation/profile.dart';
import 'package:ai_assistant/features/chat/presentations/chat_page.dart';
import 'package:ai_assistant/features/auth/presentation/signin_page.dart';
import 'package:ai_assistant/features/auth/presentation/signup_page.dart';
import 'package:ai_assistant/features/auth/presentation/splash_page.dart';
import 'package:ai_assistant/features/service/presentation/service_page.dart';
import 'package:ai_assistant/features/service/presentation/service_detail_page.dart';
import 'package:ai_assistant/features/service/domain/service.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const services = '/services';
  static const serviceDetail = '/services/:serviceId';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const home = '/home';
  static const settings = '/settings';
  static const profile = '/profile';
  static const chatpage = '/chatpage';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,

    refreshListenable: refresh,

    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);

      final isAuthPage =
          state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp;
      final isSplashPage = state.matchedLocation == AppRoutes.splash;

      return auth.when(
        loading: () => AppRoutes.splash,

        error: (_, _) => AppRoutes.signIn,

        data: (authState) {
          switch (authState) {
            case Authenticated():
              if (isAuthPage || isSplashPage) {
                return AppRoutes.home;
              }

              return null;

            case Unauthenticated():
              if (isAuthPage) {
                return null;
              }

              return AppRoutes.signIn;
          }
        },
      );
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),

      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.chatpage,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServicePage(),
        routes: [
          GoRoute(
            path: ':serviceId',
            builder: (context, state) {
              final service = state.extra;
              if (service is! Service) {
                return const ServicePage();
              }

              return ServiceDetailPage(service: service);
            },
          ),
        ],
      ),
    ],
  );
});
