
import 'package:flutter/material.dart';

import '../api_service.dart';
import 'auth_screen.dart';
import 'task_list_screen.dart';

class AuthGate extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const AuthGate({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    restoreSession();
  }

  Future<void> restoreSession() async {
    try {
      await ApiService.loadToken();

      if (ApiService.token != null) {
        user = await ApiService.getProfile();
      }
    } catch (_) {
      await ApiService.logout();
      user = null;
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void onAuthenticated(Map<String, dynamic> data) {
    setState(() {
      user = Map<String, dynamic>.from(data['user'] as Map);
    });
  }

  Future<void> logout() async {
    await ApiService.logout();

    if (!mounted) return;

    setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return AuthScreen(
        onAuthenticated: onAuthenticated,
      );
    }

    return TaskListScreen(
      onToggleTheme: widget.onToggleTheme,
      user: user!,
      onLogout: logout,
    );
  }
}
