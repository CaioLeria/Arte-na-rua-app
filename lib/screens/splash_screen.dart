import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration delay;

  const SplashScreen({
    super.key,
    this.delay = const Duration(seconds: 2),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PreferencesService preferences = PreferencesService();

  @override
  void initState() {
    super.initState();
    checkOnboarding();
  }

  Future<void> checkOnboarding() async {
    await Future.delayed(widget.delay);
    if (!mounted) return;
    final hide = await preferences.getHideOnboarding();
    if (!mounted) return;

    final next = hide
        ? const HomeScreen()
        : const OnboardingScreen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette,
                size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('ArteNaRua',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
