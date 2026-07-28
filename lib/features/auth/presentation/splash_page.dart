import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // An AI/Robot icon for your AI Assistant
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .smart_toy_rounded, // You can change this to your app's actual logo
                size: 80,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 40),

            // The loading spinner that shows while AuthNotifier is running
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),

            const SizedBox(height: 24),

            // Loading text below the spinner
            Text(
              'Initializing Assistant...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
