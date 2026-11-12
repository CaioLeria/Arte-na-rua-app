import 'package:flutter/material.dart';

class GoogleAttribution extends StatelessWidget {
  const GoogleAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          'Google Maps',
          semanticsLabel: 'Dados fornecidos pelo Google Maps',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
