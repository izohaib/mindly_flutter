import 'package:url_launcher/url_launcher.dart';

class Utils {

  static Future<bool> openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }


}