import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

//import 'package:ai_assistant/features/auth/presentation/home_page.dart';
import 'package:ai_assistant/features/auth/presentation/settings.dart';

import 'package:ai_assistant/features/auth/presentation/profile.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_assistant/core/router/app_router.dart';

//import 'package:ai_assistant/features/auth/presentation/validator.dart';
//import 'package:ai_assistant/features/auth/presentation/auth_gate.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('homepage'),
        actions: [
          
          IconButton(
            onPressed: ()=>AppRoutes.profile, 
            icon: Icon(Icons.person))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text('Welcome to the Home Page!')],
        ),
      ),
    );
  }
}
