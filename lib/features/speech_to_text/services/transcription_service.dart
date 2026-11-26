import 'dart:convert';

import 'package:http/http.dart' as http;

class TranscriptionResponse {
  final String rawText;
  final String? correctedText;

  const TranscriptionResponse({required this.rawText, this.correctedText});
}

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const ApiException({required this.message, this.code, this.statusCode});

  @override
  String toString() => message;
}

class TranscriptionService {
  static const String _baseUrl = 'http://192.168.1.77:5632/api';

  static const Duration _timeout = Duration(seconds: 120);

  // ============================================================
  // AUDIO TRANSCRIPTION
  // ============================================================

  Future<TranscriptionResponse> transcribeAudio(String audioPath) async {
    final uri = Uri.parse('$_baseUrl/transcribe');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('audio', audioPath));

    request.headers['Accept'] = 'application/json';

    try {
      final streamedResponse = await request.send().timeout(_timeout);

      final response = await http.Response.fromStream(streamedResponse);

      final data = _decodeResponse(response);

      // Successful transcription and correction.
      if (response.statusCode == 200 && data['success'] == true) {
        return TranscriptionResponse(
          rawText: data['rawText'] as String,
          correctedText: data['correctedText'] as String?,
        );
      }

      // Groq succeeded, but Gemini correction failed.
      // Preserve rawText for a correction-only retry.
      if (data['code'] == 'CORRECTION_FAILED' && data['rawText'] is String) {
        return TranscriptionResponse(rawText: data['rawText'] as String);
      }

      throw ApiException(
        message: data['message'] ?? 'Transcription failed. Please try again.',
        code: data['code'],
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Could not connect to the server.',
        code: 'NETWORK_ERROR',
      );
    }
  }

  // ============================================================
  // RETRY GEMINI CORRECTION
  // ============================================================

  Future<String> retryCorrection(String rawText) async {
    final uri = Uri.parse('$_baseUrl/correct');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'rawText': rawText}),
          )
          .timeout(_timeout);

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final correctedText = data['correctedText'];

        if (correctedText is String && correctedText.isNotEmpty) {
          return correctedText;
        }
      }

      throw ApiException(
        message: data['message'] ?? 'Text correction failed. Please try again.',
        code: data['code'],
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Could not connect to the server.',
        code: 'NETWORK_ERROR',
      );
    }
  }

  // ============================================================
  // RESPONSE PARSING
  // ============================================================

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Handle non-JSON responses below.
    }

    throw ApiException(
      message: 'Invalid response from server.',
      statusCode: response.statusCode,
    );
  }
}
