import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/core/database/app_database.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/colors.dart';

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
    final imageHeight = _getImageHeight(context);

    return GestureDetector(
      onTap: () {
        context.push(RouteConstants.linkDetail, extra: link);
      },
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