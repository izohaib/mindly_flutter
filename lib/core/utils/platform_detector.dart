/// Extracts a normalized platform identifier from a URL's host,
/// used for feed filtering (youtube, instagram, tiktok, etc.)
class PlatformDetector {
  PlatformDetector._();

  static const Map<String, String> _hostMap = {
    'youtube.com': 'youtube',
    'youtu.be': 'youtube',
    'instagram.com': 'instagram',
    'tiktok.com': 'tiktok',
    'twitter.com': 'twitter',
    'x.com': 'twitter',
    'reddit.com': 'reddit',
    'reddit.it': 'reddit',
    'pinterest.com': 'pinterest',
    'pin.it': 'pinterest',
    'facebook.com': 'facebook',
    'fb.watch': 'facebook',
    'linkedin.com': 'linkedin',
    'threads.net': 'threads',
    'snapchat.com': 'snapchat',
    'spotify.com': 'spotify',
    'vimeo.com': 'vimeo',
    'twitch.tv': 'twitch',
  };

  static const String other = 'other';

  static String detect(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      if (host.isEmpty) return other;

      String cleanHost = host;
      if (cleanHost.startsWith('www.')) {
        cleanHost = cleanHost.substring(4);
      } else if (cleanHost.startsWith('m.')) {
        cleanHost = cleanHost.substring(2);
      }

      if (_hostMap.containsKey(cleanHost)) {
        return _hostMap[cleanHost]!;
      }
      for (final entry in _hostMap.entries) {
        if (cleanHost.endsWith('.${entry.key}')) {
          return entry.value;
        }
      }
      return other;
    } catch (e) {
      print('PlatformDetector error: $e');
      return other;
    }
  }

  static String displayName(String platform) {
    const displayNames = {
      'youtube': 'YouTube',
      'instagram': 'Instagram',
      'tiktok': 'TikTok',
      'twitter': 'Twitter / X',
      'reddit': 'Reddit',
      'pinterest': 'Pinterest',
      'facebook': 'Facebook',
      'linkedin': 'LinkedIn',
      'threads': 'Threads',
      'snapchat': 'Snapchat',
      'spotify': 'Spotify',
      'vimeo': 'Vimeo',
      'twitch': 'Twitch',
      'other': 'Other',
    };
    return displayNames[platform] ?? platform;
  }

  /// Raw platform keys (e.g. 'youtube'), used as filter values.
  /// Use displayName() when rendering chip labels.
  static List<String> get allPlatforms {
    final unique = _hostMap.values.toSet().toList()..sort();
    return unique;
  }
}