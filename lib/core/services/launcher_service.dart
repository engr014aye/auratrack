import 'package:flutter/services.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('com.palawshaapps.auratrack/launcher');

  /// Opens an external URL in the default browser / system handler.
  static Future<bool> openUrl(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('launchUrl', {'url': url});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Redirects user to rate AuraTrack on Google Play Store.
  static Future<bool> openPlayStoreRating() async {
    const marketUrl = 'market://details?id=com.palawshaapps.auratrack';
    final success = await openUrl(marketUrl);
    if (!success) {
      return await openUrl('https://play.google.com/store/apps/details?id=com.palawshaapps.auratrack');
    }
    return true;
  }
}
