import 'dart:convert';

import 'package:http/http.dart' as http;

/// Lightweight gateway for retrieving runtime secrets from Doppler.
///
/// Mirrors the Swift `SecretManager`, caching Cloudinary credentials and
/// refreshing them once the cache window expires. The Doppler service token is
/// resolved from a constructor argument or the `DOPPLER_SERVICE_TOKEN` compile
/// time environment variable.
class SecretManager {
  SecretManager({
    http.Client? httpClient,
    Duration cacheTtl = const Duration(hours: 1),
    String? serviceToken,
  }) : _client = httpClient ?? http.Client(),
       _cacheTtl = cacheTtl,
       _serviceToken = _resolveToken(serviceToken);

  final http.Client _client;
  final Duration _cacheTtl;
  final String _serviceToken;

  CloudinaryConfig? _cachedConfig;
  DateTime? _lastFetch;
  Future<CloudinaryConfig>? _pendingFetch;

  /// Fetches a Cloudinary configuration, returning a cached copy when valid.
  Future<CloudinaryConfig> getCloudinaryConfig() {
    final now = DateTime.now();
    final cached = _cachedConfig;
    final lastFetch = _lastFetch;

    if (cached != null &&
        lastFetch != null &&
        now.difference(lastFetch) < _cacheTtl) {
      return Future.value(cached);
    }

    return _pendingFetch ??= _fetchAndCache().whenComplete(() {
      _pendingFetch = null;
    });
  }

  /// Clears the cached credentials forcing the next call to hit the network.
  void clearCache() {
    _cachedConfig = null;
    _lastFetch = null;
  }

  Future<CloudinaryConfig> _fetchAndCache() async {
    if (_serviceToken.isEmpty) {
      throw const SecretManagerException.missingToken();
    }

    final uri = Uri.parse('https://api.doppler.com/v3/configs/config/secrets');
    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_serviceToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw SecretManagerException.network(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const SecretManagerException.invalidPayload();
    }

    final secrets = json['secrets'];
    if (secrets is! Map<String, dynamic>) {
      throw const SecretManagerException.invalidPayload();
    }

    String? readSecret(String key) {
      final entry = secrets[key];
      if (entry is Map<String, dynamic>) {
        final value = entry['computed'];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      } else if (entry is String && entry.trim().isNotEmpty) {
        return entry.trim();
      }
      return null;
    }

    final cloudName = readSecret('CLOUDINARY_CLOUD_NAME');
    final apiKey = readSecret('CLOUDINARY_API_KEY');
    final apiSecret = readSecret('CLOUDINARY_API_SECRET');
    final uploadPreset = readSecret('CLOUDINARY_UPLOAD_PRESET');

    if ([cloudName, apiKey].any((value) => value == null)) {
      throw const SecretManagerException.missingSecrets();
    }

    final config = CloudinaryConfig(
      cloudName: cloudName!,
      apiKey: apiKey!,
      apiSecret: apiSecret,
      uploadPreset: uploadPreset ?? 'profile_picture', // Default to match Swift
    );

    _cachedConfig = config;
    _lastFetch = DateTime.now();
    return config;
  }
}

// Temporary hardcoded Doppler token used while backend secret injection is
// being wired up. Replace this with environment-driven configuration before
// shipping to production.
const String _fallbackDopplerServiceToken =
    'dp.st.prd.F6bgWVWoAushUGhpPsJJCpUrj3XDRKLl9FRY2iP5XfP';

String _resolveToken(String? override) {
  final overrideToken = override?.trim();
  if (overrideToken != null && overrideToken.isNotEmpty) {
    return overrideToken;
  }

  final envToken = const String.fromEnvironment('DOPPLER_SERVICE_TOKEN').trim();
  if (envToken.isNotEmpty) {
    return envToken;
  }

  return _fallbackDopplerServiceToken;
}

/// Immutable representation of the Cloudinary credentials retrieved from
/// Doppler.
class CloudinaryConfig {
  const CloudinaryConfig({
    required this.cloudName,
    required this.apiKey,
    this.apiSecret,
    required this.uploadPreset,
  });

  final String cloudName;
  final String apiKey;
  final String? apiSecret;
  final String uploadPreset;
}

/// Domain-specific failures thrown by [SecretManager].
class SecretManagerException implements Exception {
  const SecretManagerException._(this.message);

  const SecretManagerException.missingToken()
    : this._(
        'Doppler service token is missing. '
        'Provide it via the constructor or the DOPPLER_SERVICE_TOKEN environment variable.',
      );

  const SecretManagerException.missingSecrets()
    : this._(
        'Required Cloudinary secrets were not present in the Doppler response.',
      );

  const SecretManagerException.invalidPayload()
    : this._('Doppler returned an unexpected payload.');

  const SecretManagerException.network({required int statusCode, String? body})
    : this._(
        'Failed to fetch secrets from Doppler. Status code: $statusCode. Body: ${body ?? '<empty>'}.',
      );

  final String message;

  @override
  String toString() => 'SecretManagerException: $message';
}
