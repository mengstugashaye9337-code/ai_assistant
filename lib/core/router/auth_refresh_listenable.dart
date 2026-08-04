import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_notifier.dart';

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }
}

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  return AuthRefreshListenable(ref);
});
