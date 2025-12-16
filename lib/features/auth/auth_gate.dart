
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_screen.dart';
import '../home_screen.dart';
import 'auth_service.dart';

// TestMode is imported from auth_service.dart

import '../social/services/presence_service.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Initialize presence system (idempotent listener)
    ref.read(presenceServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: TestMode.notifier,
      builder: (context, isTestMode, child) {
        // If test mode is enabled, show HomeScreen directly
        if (isTestMode) {
          return const HomeScreen();
        }

        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (snapshot.hasData) {
              return const HomeScreen();
            }

            return const AuthScreen();
          },
        );
      },
    );
  }
}
