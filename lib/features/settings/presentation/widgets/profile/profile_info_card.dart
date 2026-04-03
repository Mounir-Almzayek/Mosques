import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/l10n/generated/l10n.dart';

class ProfileInfoCard extends StatelessWidget {
  final User? user;

  const ProfileInfoCard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Card(
      elevation: 0,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person_outline, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? '...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.profile_email,
              style: TextStyle(color: Colors.teal.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
