import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/signin_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/auth/presentation/home_page.dart';

class AuthRefreshlistenable extends ChangeNotifier {
  AuthRefreshlistenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}

final refreshlistenableProcide = Provider<AuthRefreshlistenable>((ref) {
  return AuthRefreshlistenable(ref);
});

final routerrr = Provider<GoRouter>((ref) {
  final listener = ref.watch(refreshlistenableProcide);

  return GoRouter(
    refreshListenable: listener,
    redirect: (context, state) {
      final authstate = ref.read(authNotifierProvider);
      return authstate.when(
        data: (state){
          switch(state){
            case Authenticated():
             return '/home';
            case Unauthenticated():
             return '/signin';
        }
        }, 
        error: (error, stack){
          return '/signin';
        } ,
        loading: (){return '/splash';}
        );
    },
    routes: [GoRoute(path: '/', builder: (context, state) => HomePage())],
  );
});
