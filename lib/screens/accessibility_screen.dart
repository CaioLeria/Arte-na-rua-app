import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  final PreferencesService preferences = PreferencesService();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.accessibility_new, size: 64),
        const SizedBox(height: 16),
        Text(
          'Acessibilidade',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Use o botão "Ouvir descrição" na ficha de cada obra para ouvir '
          'a audiodescrição em voz alta. O tamanho do texto segue as '
          'configurações de acessibilidade do próprio aparelho.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
