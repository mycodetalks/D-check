import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RemoteAiService {
  RemoteAiService._();
  static final RemoteAiService instance = RemoteAiService._();

  // Read the key dynamically from the flutter_dotenv file
  static final String _apiKey = dotenv.env['HUGGING_FACE_TOKEN'] ?? '';
  
  static const String _model = 'mistralai/Mistral-7B-Instruct-v0.3';
  static const String _endpoint =
      'https://api-inference.huggingface.co/models/$_model';

  Future<String> answerWithContext(String question, String context) async {
    if (_apiKey.isEmpty) {
      return 'Remote AI not configured. Please add a Hugging Face API key in your local .env file.';
    }

    final prompt = '''Use the following legal context to answer the user query.
If the context does not contain a clear answer, say you could not find a direct answer.

Legal context:
$context

Question: $question
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'inputs': prompt,
        'parameters': {
          'max_new_tokens': 512,
          'temperature': 0.3,
        },
      }),
    );

    if (response.statusCode != 200) {
      return 'Remote AI request failed: ${response.statusCode}. Falling back to local legal search.';
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('generated_text')) {
      return decoded['generated_text'] as String;
    }

    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic> &&
          first.containsKey('generated_text')) {
        return first['generated_text'] as String;
      }
    }

    return response.body;
  }
}
