import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/ui/auth_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/models/auth_state.dart';
import 'features/home/ui/home_screen.dart';
import 'features/auth/ui/verification/verification_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Animated Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState state) {
    if (state is AuthAuthenticated) {
      return const HomeScreen();
    } else if (state is AuthVerificationRequired) {
      return VerificationScreen(email: state.email);
    } else if (state is AuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return const AuthScreen();
    }
  }
}
