import 'dart:async';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';


// class MetadataService {
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
//     try {
//       final metadata = await AnyLinkPreview.getMetadata(link: url);
//       final youtubeId = _extractYoutubeId(url);
//
//       final imageUrl = youtubeId != null
//           ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
//           : metadata?.image;
//
//       // Get image dimensions (ONE load only)
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//
//           print('📐 [MetadataService] Width: $imageWidth, Height: $imageHeight');
//         } catch (e) {
//           print('Error fetching image dimensions: $e');
//         }
//       }
//
//       return (
//       title: metadata?.title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('MetadataService error: $e');
//       return (title: null, imageUrl: null, imageWidth: null, imageHeight: null);
//     }
//   }
//
//   // Load image ONCE, get both width AND height
//   Future<(double?, double?)> _getImageDimensions(String imageUrl) async {
//     final Completer<(double?, double?)> completer = Completer();
//
//     final imageProvider = NetworkImage(imageUrl);
//     final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
//
//     late ImageStreamListener listener;
//     listener = ImageStreamListener(
//           (image, synchronousCall) {
//         if (!completer.isCompleted) {
//           final width = image.image.width.toDouble();
//           final height = image.image.height.toDouble();
//           completer.complete((width, height)); // ← return both
//         }
//         imageStream.removeListener(listener);
//       },
//       onError: (exception, stackTrace) {
//         if (!completer.isCompleted) {
//           completer.complete((null, null));
//         }
//       },
//     );
//
//     imageStream.addListener(listener);
//
//     return completer.future.timeout(
//       const Duration(seconds: 3),
//       onTimeout: () => (null, null),
//     );
//   }
//
//   String? _extractYoutubeId(String url) {
//     final regExp = RegExp(
//       r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
//     );
//     return regExp.firstMatch(url)?.group(1);
//   }
// }
// class MetaData{
//   String? title;
//   String? imageUrl;
//   MetaData(this.title, this.imageUrl)
// }


import 'dart:async';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';


// class MetadataService {
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
//     try {
//       final metadata = await AnyLinkPreview.getMetadata(link: url);
//       final youtubeId = _extractYoutubeId(url);
//
//       final imageUrl = youtubeId != null
//           ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
//           : metadata?.image;
//
//       // Get image dimensions (ONE load only)
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//
//           print('📐 [MetadataService] Width: $imageWidth, Height: $imageHeight');
//         } catch (e) {
//           print('Error fetching image dimensions: $e');
//         }
//       }
//
//       return (
//       title: metadata?.title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('MetadataService error: $e');
//       return (title: null, imageUrl: null, imageWidth: null, imageHeight: null);
//     }
//   }
//
//   // Load image ONCE, get both width AND height
//   Future<(double?, double?)> _getImageDimensions(String imageUrl) async {
//     final Completer<(double?, double?)> completer = Completer();
//
//     final imageProvider = NetworkImage(imageUrl);
//     final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
//
//     late ImageStreamListener listener;
//     listener = ImageStreamListener(
//           (image, synchronousCall) {
//         if (!completer.isCompleted) {
//           final width = image.image.width.toDouble();
//           final height = image.image.height.toDouble();
//           completer.complete((width, height)); // ← return both
//         }
//         imageStream.removeListener(listener);
//       },
//       onError: (exception, stackTrace) {
//         if (!completer.isCompleted) {
//           completer.complete((null, null));
//         }
//       },
//     );
//
//     imageStream.addListener(listener);
//
//     return completer.future.timeout(
//       const Duration(seconds: 3),
//       onTimeout: () => (null, null),
//     );
//   }
//
//   String? _extractYoutubeId(String url) {
//     final regExp = RegExp(
//       r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
//     );
//     return regExp.firstMatch(url)?.group(1);
//   }
// }
// class MetaData{
//   String? title;
//   String? imageUrl;
//   MetaData(this.title, this.imageUrl)
// }


class MetadataService {
  // Remove platform detection from here - do it once in ShareIntentListener instead
  Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
    try {
      final metadata = await AnyLinkPreview.getMetadata(link: url);
      final youtubeId = _extractYoutubeId(url);

      final imageUrl = youtubeId != null
          ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
          : metadata?.image;

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

      print('metadata: title=${metadata?.title}, image=${metadata?.image}, desc=${metadata?.desc}');

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
          completer.complete((width, height));
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



// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:any_link_preview/any_link_preview.dart';
// import 'package:http/http.dart' as http;
// import 'package:mindly/core/utils/platform_detector.dart';
//
// class MetadataService {
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
//     final platform = PlatformDetector.detect(url);
//
//     // Try platform specific fetcher first
//     if (platform == 'reddit') {
//       final result = await _fetchReddit(url);
//       if (result != null) return result;
//       // falls through to generic fetch below if reddit fetch failed
//     }
//
//     // Generic fallback, used for platform == 'other' and as safety net
//     return _fetchGeneric(url);
//   }
//
//   /// Reddit specific fetcher using their public json endpoint.
//   /// Returns null if it fails, so caller can fall back to generic fetch.
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})?> _fetchReddit(String url) async {
//     try {
//       final jsonUrl = await _toRedditJsonUrl(url);
//       print("metadataservice: ${jsonUrl}");
//       if (jsonUrl == null) return null;
//
//       final response = await http.get(
//         Uri.parse(jsonUrl),
//         headers: {'User-Agent': 'Mozilla/5.0 (Android) mindly-app'},
//       ).timeout(const Duration(seconds: 8));
//
//       if (response.statusCode != 200) {
//         print('Reddit fetch failed with status: ${response.statusCode}');
//         return null;
//       }
//
//       final decoded = jsonDecode(response.body);
//       final postData = decoded is List
//           ? decoded[0]['data']['children'][0]['data']
//           : null;
//
//       if (postData == null) return null;
//
//       final title = postData['title'] as String?;
//       final imageUrl = _extractRedditImage(postData);
//
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//         } catch (e) {
//           print('Error fetching reddit image dimensions: $e');
//         }
//       }
//
//       return (
//       title: title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('Reddit fetch error: $e');
//       return null;
//     }
//   }
//
//   /// Converts any reddit post url (including short share urls) to its json endpoint.
//   /// Reddit share links redirect properly when .json is appended, even the /s/ short ones.
//   Future<String?> _toRedditJsonUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       if (!uri.host.contains('reddit')) return null;
//
//       String resolvedUrl = url;
//
//       if (uri.path.contains('/s/')) {
//         final request = http.Request('GET', uri)..followRedirects = false;
//         final streamedResponse = await http.Client()
//             .send(request)
//             .timeout(const Duration(seconds: 8));
//
//         final location = streamedResponse.headers['location'];
//         print('reddit redirect location: $location');
//
//         if (location == null) return null;
//
//         resolvedUrl = location.startsWith('http')
//             ? location
//             : Uri.parse(url).resolve(location).toString();
//       }
//
//       final resolvedUri = Uri.parse(resolvedUrl);
//       var path = resolvedUri.path;
//       if (path.endsWith('/')) {
//         path = path.substring(0, path.length - 1);
//       }
//       return '${resolvedUri.scheme}://${resolvedUri.host}$path.json';
//     } catch (e) {
//       print('Reddit url resolve error: $e');
//       return null;
//     }
//   }
//   /// Reddit json responses store images in different places depending on post type
//   /// (single image post, gallery post, or link post with a preview).
//   String? _extractRedditImage(Map<String, dynamic> postData) {
//     // Gallery post, pick first image only, as agreed
//     if (postData['is_gallery'] == true && postData['media_metadata'] != null) {
//       final mediaMetadata = postData['media_metadata'] as Map<String, dynamic>;
//       if (mediaMetadata.isNotEmpty) {
//         final firstItem = mediaMetadata.values.first;
//         final sourceUrl = firstItem['s']?['u'] as String?;
//         if (sourceUrl != null) {
//           return sourceUrl.replaceAll('&amp;', '&');
//         }
//       }
//     }
//
//     // Direct single image post
//     final postHint = postData['post_hint'] as String?;
//     if (postHint == 'image' && postData['url'] != null) {
//       return postData['url'] as String;
//     }
//
//     // Link post with a preview image
//     final preview = postData['preview'];
//     if (preview != null) {
//       final images = preview['images'] as List?;
//       if (images != null && images.isNotEmpty) {
//         final sourceUrl = images[0]['source']?['url'] as String?;
//         if (sourceUrl != null) {
//           return sourceUrl.replaceAll('&amp;', '&');
//         }
//       }
//     }
//
//     // Fallback to thumbnail if it's a real image url, not reddit's placeholder icons
//     final thumbnail = postData['thumbnail'] as String?;
//     if (thumbnail != null && thumbnail.startsWith('http')) {
//       return thumbnail;
//     }
//
//     return null;
//   }
//
//   /// Generic fetcher for youtube, and everything else not specially handled yet.
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> _fetchGeneric(String url) async {
//     try {
//       final metadata = await AnyLinkPreview.getMetadata(link: url);
//       final youtubeId = _extractYoutubeId(url);
//
//       final imageUrl = youtubeId != null
//           ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
//           : metadata?.image;
//
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//         } catch (e) {
//           print('Error fetching image dimensions: $e');
//         }
//       }
//
//       return (
//       title: metadata?.title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('MetadataService error: $e');
//       return (title: null, imageUrl: null, imageWidth: null, imageHeight: null);
//     }
//   }
//
//   Future<(double?, double?)> _getImageDimensions(String imageUrl) async {
//     final Completer<(double?, double?)> completer = Completer();
//
//     final imageProvider = NetworkImage(imageUrl);
//     final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
//
//     late ImageStreamListener listener;
//     listener = ImageStreamListener(
//           (image, synchronousCall) {
//         if (!completer.isCompleted) {
//           final width = image.image.width.toDouble();
//           final height = image.image.height.toDouble();
//           completer.complete((width, height));
//         }
//         imageStream.removeListener(listener);
//       },
//       onError: (exception, stackTrace) {
//         if (!completer.isCompleted) {
//           completer.complete((null, null));
//         }
//       },
//     );
//
//     imageStream.addListener(listener);
//
//     return completer.future.timeout(
//       const Duration(seconds: 3),
//       onTimeout: () => (null, null),
//     );
//   }
//
//   String? _extractYoutubeId(String url) {
//     final regExp = RegExp(
//       r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
//     );
//     return regExp.firstMatch(url)?.group(1);
//   }
// }



// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:any_link_preview/any_link_preview.dart';
// import 'package:http/http.dart' as http;
// import 'package:mindly/core/utils/platform_detector.dart';
//
// class MetadataService {
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> fetch(String url) async {
//     final platform = PlatformDetector.detect(url);
//
//     // Try platform specific fetcher first
//     if (platform == 'reddit') {
//       final result = await _fetchReddit(url);
//       if (result != null) return result;
//       // falls through to generic fetch below if reddit fetch failed
//     }
//
//     // Generic fallback, used for platform == 'other' and as safety net
//     return _fetchGeneric(url);
//   }
//
//   /// Reddit specific fetcher using their public json endpoint.
//   /// Returns null if it fails, so caller can fall back to generic fetch.
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})?> _fetchReddit(String url) async {
//     try {
//       final jsonUrl = await _toRedditJsonUrl(url);
//       print("metadataservice: ${jsonUrl}");
//       if (jsonUrl == null) return null;
//
//       final response = await http.get(
//         Uri.parse(jsonUrl),
//         headers: {'User-Agent': 'Mozilla/5.0 (Android) mindly-app'},
//       ).timeout(const Duration(seconds: 8));
//
//       if (response.statusCode != 200) {
//         print('Reddit fetch failed with status: ${response.statusCode}');
//         return null;
//       }
//
//       final decoded = jsonDecode(response.body);
//       final postData = decoded is List
//           ? decoded[0]['data']['children'][0]['data']
//           : null;
//
//       if (postData == null) return null;
//
//       final title = postData['title'] as String?;
//       final imageUrl = _extractRedditImage(postData);
//
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//         } catch (e) {
//           print('Error fetching reddit image dimensions: $e');
//         }
//       }
//
//       return (
//       title: title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('Reddit fetch error: $e');
//       return null;
//     }
//   }
//
//   /// Converts any reddit post url (including short share urls) to its json endpoint.
//   /// Reddit share links redirect properly when .json is appended, even the /s/ short ones.
//   Future<String?> _toRedditJsonUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       if (!uri.host.contains('reddit')) return null;
//
//       String resolvedUrl = url;
//
//       if (uri.path.contains('/s/')) {
//         final request = http.Request('GET', uri)..followRedirects = false;
//         final streamedResponse = await http.Client()
//             .send(request)
//             .timeout(const Duration(seconds: 8));
//
//         final location = streamedResponse.headers['location'];
//         print('reddit redirect location: $location');
//
//         if (location == null) return null;
//
//         resolvedUrl = location.startsWith('http')
//             ? location
//             : Uri.parse(url).resolve(location).toString();
//       }
//
//       final resolvedUri = Uri.parse(resolvedUrl);
//       var path = resolvedUri.path;
//       if (path.endsWith('/')) {
//         path = path.substring(0, path.length - 1);
//       }
//       return '${resolvedUri.scheme}://${resolvedUri.host}$path.json';
//     } catch (e) {
//       print('Reddit url resolve error: $e');
//       return null;
//     }
//   }
//   /// Reddit json responses store images in different places depending on post type
//   /// (single image post, gallery post, or link post with a preview).
//   String? _extractRedditImage(Map<String, dynamic> postData) {
//     // Gallery post, pick first image only, as agreed
//     if (postData['is_gallery'] == true && postData['media_metadata'] != null) {
//       final mediaMetadata = postData['media_metadata'] as Map<String, dynamic>;
//       if (mediaMetadata.isNotEmpty) {
//         final firstItem = mediaMetadata.values.first;
//         final sourceUrl = firstItem['s']?['u'] as String?;
//         if (sourceUrl != null) {
//           return sourceUrl.replaceAll('&amp;', '&');
//         }
//       }
//     }
//
//     // Direct single image post
//     final postHint = postData['post_hint'] as String?;
//     if (postHint == 'image' && postData['url'] != null) {
//       return postData['url'] as String;
//     }
//
//     // Link post with a preview image
//     final preview = postData['preview'];
//     if (preview != null) {
//       final images = preview['images'] as List?;
//       if (images != null && images.isNotEmpty) {
//         final sourceUrl = images[0]['source']?['url'] as String?;
//         if (sourceUrl != null) {
//           return sourceUrl.replaceAll('&amp;', '&');
//         }
//       }
//     }
//
//     // Fallback to thumbnail if it's a real image url, not reddit's placeholder icons
//     final thumbnail = postData['thumbnail'] as String?;
//     if (thumbnail != null && thumbnail.startsWith('http')) {
//       return thumbnail;
//     }
//
//     return null;
//   }
//
//   /// Generic fetcher for youtube, and everything else not specially handled yet.
//   Future<({String? title, String? imageUrl, double? imageWidth, double? imageHeight})> _fetchGeneric(String url) async {
//     try {
//       final metadata = await AnyLinkPreview.getMetadata(link: url);
//       final youtubeId = _extractYoutubeId(url);
//
//       final imageUrl = youtubeId != null
//           ? 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg'
//           : metadata?.image;
//
//       double? imageWidth;
//       double? imageHeight;
//
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         try {
//           final dimensions = await _getImageDimensions(imageUrl);
//           imageWidth = dimensions.$1;
//           imageHeight = dimensions.$2;
//         } catch (e) {
//           print('Error fetching image dimensions: $e');
//         }
//       }
//
//       return (
//       title: metadata?.title,
//       imageUrl: imageUrl,
//       imageWidth: imageWidth,
//       imageHeight: imageHeight,
//       );
//     } catch (e) {
//       print('MetadataService error: $e');
//       return (title: null, imageUrl: null, imageWidth: null, imageHeight: null);
//     }
//   }
//
//   Future<(double?, double?)> _getImageDimensions(String imageUrl) async {
//     final Completer<(double?, double?)> completer = Completer();
//
//     final imageProvider = NetworkImage(imageUrl);
//     final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
//
//     late ImageStreamListener listener;
//     listener = ImageStreamListener(
//           (image, synchronousCall) {
//         if (!completer.isCompleted) {
//           final width = image.image.width.toDouble();
//           final height = image.image.height.toDouble();
//           completer.complete((width, height));
//         }
//         imageStream.removeListener(listener);
//       },
//       onError: (exception, stackTrace) {
//         if (!completer.isCompleted) {
//           completer.complete((null, null));
//         }
//       },
//     );
//
//     imageStream.addListener(listener);
//
//     return completer.future.timeout(
//       const Duration(seconds: 3),
//       onTimeout: () => (null, null),
//     );
//   }
//
//   String? _extractYoutubeId(String url) {
//     final regExp = RegExp(
//       r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
//     );
//     return regExp.firstMatch(url)?.group(1);
//   }
// }