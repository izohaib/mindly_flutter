import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';
import '../../../../core/theme/colors.dart';

// class LinkFeed extends StatefulWidget {
//   final Link link;
//
//   const LinkFeed({super.key, required this.link});
//
//   @override
//   State<LinkFeed> createState() => _LinkFeedState();
// }
//
// class _LinkFeedState extends State<LinkFeed> {
//   double _imageHeight = 200; // Default height
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.link.imageUrl != null && widget.link.imageUrl!.isNotEmpty) {
//       _loadImageHeight();
//     }
//   }
//
//   Future<void> _loadImageHeight() async {
//     try {
//       final imageProvider = NetworkImage(widget.link.imageUrl!);
//       final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
//
//       imageStream.addListener(
//         ImageStreamListener((image, synchronousCall) {
//           final width = image.image.width.toDouble();
//           final height = image.image.height.toDouble();
//           final aspectRatio = width / height;
//
//           // Calculate height based on actual card width (roughly half screen)
//           double cardWidth = (MediaQuery.of(context).size.width - 28) / 2; // 2 columns, padding
//           double calculatedHeight = cardWidth / aspectRatio;
//
//           if (mounted) {
//             setState(() {
//               _imageHeight = calculatedHeight;
//             });
//           }
//         }),
//       );
//     } catch (e) {
//       print('Error loading image: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // TODO: navigate to link detail screen
//       },
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           color: AppColors.surface,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // IMAGE
//               (widget.link.imageUrl != null && widget.link.imageUrl!.isNotEmpty)
//                   ? SizedBox(
//                 height: _imageHeight, // DYNAMIC height based on aspect ratio
//                 width: double.infinity,
//                 child: Image.network(
//                   widget.link.imageUrl!,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 180,
//                     color: AppColors.surfaceElevated,
//                     child: const Center(
//                       child: Icon(
//                         Icons.image_not_supported,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//                   : Container(
//                 height: 180,
//                 color: AppColors.surfaceElevated,
//                 child: const Center(
//                   child: Icon(
//                     Icons.link,
//                     color: AppColors.textSecondary,
//                     size: 32,
//                   ),
//                 ),
//               ),
//
//               // TITLE
//               if (widget.link.title != null && widget.link.title!.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     widget.link.title!,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary,
//                       height: 1.3,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class LinkFeed extends StatelessWidget {
  final Link link;

  const LinkFeed({super.key, required this.link});

  double _getImageHeight(BuildContext context) {
    if (link.imageWidth == null || link.imageHeight == null) {
      return 180;
    }
    final cardWidth = (MediaQuery.of(context).size.width - 28) / 2;
    final aspectRatio = link.imageWidth! / link.imageHeight!;
    return cardWidth / aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = _getImageHeight(context); // ← pass context

    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (link.imageUrl != null && link.imageUrl!.isNotEmpty)
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    link.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 180,
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Icon(Icons.link, size: 32),
                  ),
                ),
              if (link.title != null && link.title!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    link.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}