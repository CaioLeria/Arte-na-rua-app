import 'package:flutter/material.dart';

import '../services/location_service.dart';

class LocationNotice extends StatelessWidget {
  final LocationStatus status;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final String? message;

  const LocationNotice({
    super.key,
    required this.status,
    required this.onRetry,
    required this.onOpenSettings,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? action;
    final String text;
    switch (status) {
      case LocationStatus.denied:
        text = 'Sem a sua localização, mostramos as obras por região.';
        action = TextButton(onPressed: onRetry, child: const Text('Permitir'));
      case LocationStatus.deniedForever:
        text = 'Sem a sua localização, mostramos as obras por região.';
        action = TextButton(
            onPressed: onOpenSettings, child: const Text('Abrir configurações'));
      case LocationStatus.serviceDisabled:
        text = 'Ative a localização do aparelho.';
        action = null;
      case LocationStatus.error:
        text = message ?? 'Não conseguimos achar sua posição.';
        action = ElevatedButton(
            onPressed: onRetry, child: const Text('Tentar novamente'));
      default:
        return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_off),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
            ?action,
          ],
        ),
      ),
    );
  }
}
