import 'package:flutter/material.dart';

class ListenButton extends StatelessWidget {
  final bool speaking;
  final VoidCallback onPressed;

  const ListenButton({
    super.key,
    required this.speaking,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(speaking ? Icons.stop : Icons.volume_up),
      label: Text(speaking ? 'Parar' : 'Ouvir descrição'),
    );
  }
}
