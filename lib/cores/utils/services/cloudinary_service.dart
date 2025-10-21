import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../manager/secret_manager.dart';

/// Provides Cloudinary upload helpers backed by the shared [SecretManager].
///
/// Mirrors the Swift implementation by ensuring the Cloudinary client is
/// configured lazily and re-using the Doppler-backed credentials on demand.
class CloudinaryService {
  CloudinaryService({SecretManager? secretManager, http.Client? httpClient})
    : _secretManager = secretManager ?? SecretManager(),
      _client = httpClient ?? http.Client();

  final SecretManager _secretManager;
  final http.Client _client;

  static const String _cloudinaryHost = 'https://api.cloudinary.com/v1_1';
  static const String _defaultFolder = 'profiles';

  /// Uploads a profile image to Cloudinary and returns the secure URL.
  ///
  /// The upload leverages credentials fetched from Doppler. The image [bytes]
  /// must represent a valid JPEG/PNG payload.
  Future<String> uploadProfileImage({
    required Uint8List bytes,
    required String userId,
    String? fileName,
    Map<String, String>? metadata,
  }) async {
    if (bytes.isEmpty) {
      throw const CloudinaryException.invalidImage();
    }

    final config = await _secretManager.getCloudinaryConfig();

    final uri = Uri.parse('$_cloudinaryHost/${config.cloudName}/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['folder'] = '$_defaultFolder/$userId'
      ..fields['public_id'] = userId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName ?? 'profile-$userId.jpg',
        ),
      );

    final contextValue = _encodeContext(metadata);
    if (contextValue.isNotEmpty) {
      request.fields['context'] = contextValue;
    }

    if (config.apiKey.isNotEmpty) {
      request.fields['api_key'] = config.apiKey;
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudinaryException.uploadFailed(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const CloudinaryException.invalidResponse();
    }

    final secureUrl = decoded['secure_url'] ?? decoded['url'];
    if (secureUrl is String && secureUrl.isNotEmpty) {
      return secureUrl;
    }

    throw const CloudinaryException.invalidResponse();
  }

  /// Releases the underlying HTTP client.
  void dispose() => _client.close();

  String _encodeContext(Map<String, String>? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    metadata.forEach((key, value) {
      if (key.isEmpty || value.isEmpty) {
        return;
      }
      if (buffer.isNotEmpty) {
        buffer.write('|');
      }
      buffer.write('$key=${value.trim()}');
    });
    return buffer.toString();
  }
}

/// Errors thrown by [CloudinaryService].
class CloudinaryException implements Exception {
  const CloudinaryException._(this.message);

  const CloudinaryException.invalidImage()
    : this._('Provided image bytes are empty.');

  const CloudinaryException.invalidResponse()
    : this._('Cloudinary returned an unexpected response payload.');

  const CloudinaryException.uploadFailed({int? statusCode, String? body})
    : this._(
        'Cloudinary upload failed. Status code: ${statusCode ?? 'unknown'}. Body: ${body ?? '<empty>'}.',
      );

  final String message;

  @override
  String toString() => 'CloudinaryException: $message';
}
