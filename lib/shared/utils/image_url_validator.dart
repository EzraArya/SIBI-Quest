/// Shared helpers for validating remote image URLs before attempting to load
/// them via `Image.network` or `NetworkImage`.
bool isValidNetworkImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) {
    return false;
  }

  final uri = Uri.tryParse(url.trim());
  if (uri == null) {
    return false;
  }

  final scheme = uri.scheme.toLowerCase();
  final hasAllowedScheme = scheme == 'http' || scheme == 'https';
  return hasAllowedScheme && uri.host.isNotEmpty;
}
