
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final String email;

  const ProfileDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Профиль пользователя'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              email,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Ты вошла в аккаунт TaskTracker.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Закрыть'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Выйти из аккаунта'),
        ),
      ],
    );
  }
}
