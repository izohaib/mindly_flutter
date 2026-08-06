import 'dart:async';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/cupertino.dart';

// class MetadataService {
//   Future<({String? title, String? imageUrl})> fetch(String url) async {
//     try {
//       final metadata = await AnyLinkPreview.getMetadata(link: url);
//       final youtubeId = _extractYoutubeId(url);
//
//       final imageUrl = youtubeId != null
//           ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
//           : metadata?.image;
//
//       return (title: metadata?.title, imageUrl: imageUrl);
//     } catch (_) {
//       return (title: null, imageUrl: null);
//     }
//   }
//
//   String? _extractYoutubeId(String url) {
//     final regExp = RegExp(
//       r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
//     );
//     return regExp.firstMatch(url)?.group(1);
//   }
// }


class MetadataService {
  Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
    try {
      final metadata = await AnyLinkPreview.getMetadata(link: url);
      final youtubeId = _extractYoutubeId(url);

      final imageUrl = youtubeId != null
          ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
          : metadata?.image;

      // Get image dimensions (ONE load only)
      double? imageWidth;
      double? imageHeight;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final dimensions = await _getImageDimensions(imageUrl);
          imageWidth = dimensions.$1;
          imageHeight = dimensions.$2;

          print('📐 [MetadataService] Width: $imageWidth, Height: $imageHeight');
        } catch (e) {
          print('Error fetching image dimensions: $e');
        }
      }

      return (
      title: metadata?.title,
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      );
    } catch (e) {
      print('MetadataService error: $e');
      return (title: null, imageUrl: null, imageWidth: null, imageHeight: null);
    }
  }

  // Load image ONCE, get both width AND height
  Future<(double?, double?)> _getImageDimensions(String imageUrl) async {
    final Completer<(double?, double?)> completer = Completer();

    final imageProvider = NetworkImage(imageUrl);
    final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);

    late ImageStreamListener listener;
    listener = ImageStreamListener(
          (image, synchronousCall) {
        if (!completer.isCompleted) {
          final width = image.image.width.toDouble();
          final height = image.image.height.toDouble();
          completer.complete((width, height)); // ← return both
        }
        imageStream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete((null, null));
        }
      },
    );

    imageStream.addListener(listener);

    return completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => (null, null),
    );
  }

  String? _extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
    );
    return regExp.firstMatch(url)?.group(1);
  }
}
// class MetaData{
//   String? title;
//   String? imageUrl;
//   MetaData(this.title, this.imageUrl)
// }