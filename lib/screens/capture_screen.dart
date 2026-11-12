import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'recognition_result_screen.dart';

class CaptureScreen extends StatefulWidget {
  final ImagePicker? picker;

  const CaptureScreen({super.key, this.picker});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final ImagePicker picker = widget.picker ?? ImagePicker();

  bool cameraDenied = false;
  String? errorMessage;

  Future<void> pick(ImageSource source) async {
    setState(() => errorMessage = null);
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RecognitionResultScreen(photo: picked),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        if (source == ImageSource.camera) cameraDenied = true;
        errorMessage = e.code.contains('denied')
            ? 'Sem permissão para usar a câmera.'
            : 'Não foi possível abrir a câmera agora.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconhecer por foto')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.photo_camera, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Tire uma foto da obra e a gente tenta descobrir qual é. '
              'Precisamos da câmera só para isso.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Privacidade: a foto é enviada ao Gemini, do Google, para a '
              'comparação e não fica guardada no seu aparelho.',
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Tirar foto'),
            ),
            if (cameraDenied) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => pick(ImageSource.gallery),
                child: const Text('Escolher da galeria'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
