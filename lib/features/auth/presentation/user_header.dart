import 'package:flutter/material.dart';
import 'package:ai_assistant/features/auth/domain/user.dart';

class UserHeader extends StatelessWidget {
  final User user;

  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          child: const Icon(Icons.person, size: 50),
          // Later:
          // backgroundImage: NetworkImage(user.profileImage),
        ),

        const SizedBox(height: 20),

        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        Text(user.email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
