import 'package:flutter/material.dart';

class AiNotice extends StatelessWidget {
  const AiNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Gerado por IA, pode conter erros.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
