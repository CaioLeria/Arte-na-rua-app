import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' show XFile;

import '../models/curation.dart';
import '../models/recognition_result.dart';
import 'recognition_service.dart';

class GeminiRecognitionService implements RecognitionService {
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1';
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String model = 'gemini-3.8-flash';

  final http.Client client;
  final Duration timeout;

  GeminiRecognitionService({
    http.Client? client,
    this.timeout = const Duration(seconds: 60),
  }) : client = client ?? http.Client();

  @override
  Future<RecognitionResult> recognize(
    XFile photo,
    List<Curation> candidates,
  ) async {
    final body = await buildBody(photo, candidates);

    final response = await client
        .post(
          Uri.parse('$baseUrl/models/$model:generateContent'),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro na API do Gemini (${response.statusCode}): ${response.body}');
    }

    return parseResponse(utf8.decode(response.bodyBytes), candidates);
  }

  Future<Map<String, dynamic>> buildBody(
    XFile photo,
    List<Curation> candidates,
  ) async {
    final candidateDescriptions = candidates
        .map((c) =>
            '- placeId: "${c.placeId}", título: "${c.title}"${c.artistName != null ? ", artista: ${c.artistName}" : ""}')
        .join('\n');

    final prompt =
        'Você é um assistente especialista em arte urbana de São Paulo.\n'
        'A imagem enviada é a foto de uma obra tirada por um usuário.\n\n'
        'Aqui está a lista de obras conhecidas no aplicativo:\n'
        '$candidateDescriptions\n\n'
        'Instruções:\n'
        '1. Se a imagem corresponder claramente a uma das obras conhecidas listadas acima, retorne o correspondente "placeId". Se não corresponder ou não tiver certeza, defina "placeId" como null.\n'
        '2. No campo "aiDescription", escreva uma descrição curta (2 a 4 frases) em português do Brasil sobre o que a obra mostra, seu estilo visual e cores.\n'
        'Devolva APENAS o JSON no formato solicitado.';

    return {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            _image(await photo.readAsBytes()),
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'placeId': {'type': 'STRING'},
            'aiDescription': {'type': 'STRING'},
          },
        },
      },
    };
  }

  RecognitionResult parseResponse(
      String responseBody, List<Curation> candidates) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final list = json['candidates'] as List?;
    if (list == null || list.isEmpty) {
      throw const FormatException('Resposta sem candidatos');
    }
    final text = list[0]['content']['parts'][0]['text'] as String;
    final parsed = jsonDecode(text) as Map<String, dynamic>;

    final matchedPlaceId = parsed['placeId'] as String?;
    final validIds = candidates.map((c) => c.placeId).toSet();
    final finalPlaceId =
        (matchedPlaceId != null && validIds.contains(matchedPlaceId))
            ? matchedPlaceId
            : null;

    return RecognitionResult(
      placeId: finalPlaceId,
      aiDescription: parsed['aiDescription'] as String?,
    );
  }

  Map<String, dynamic> _image(List<int> bytes) => {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(bytes),
        },
      };
}
