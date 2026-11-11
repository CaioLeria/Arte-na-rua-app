import 'package:flutter_tts/flutter_tts.dart';

/// Audiodescrição em voz alta (pt-BR).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  bool _configured = false;

  bool get speaking => _speaking;

  Future<void> _configure() async {
    if (_configured) return;
    await _tts.setLanguage('pt-BR');
    await _tts.awaitSpeakCompletion(true);
    _configured = true;
  }

  /// Completa quando a fala termina ou é interrompida.
  Future<void> speak(String text) async {
    await _configure();
    _speaking = true;
    try {
      await _tts.speak(text);
    } finally {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
  }
}
