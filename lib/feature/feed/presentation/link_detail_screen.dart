import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/feature/feed/presentation/bloc/feed_cubit.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/feature/feed/presentation/widgets/action_pill.dart';
import 'package:mindly/feature/feed/presentation/widgets/folder_popover_button.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'dart:async';
import '../../shelves/presentation/bloc/folders_cubit.dart';
import '../../shelves/presentation/bloc/folders_state.dart';

class LinkDetailScreen extends StatefulWidget {
  final Link link;

  const LinkDetailScreen({super.key, required this.link});

  @override
  State<LinkDetailScreen> createState() => _LinkDetailScreenState();
}

class _LinkDetailScreenState extends State<LinkDetailScreen> {
  Link get link => widget.link;

  @override
  void initState() {
    super.initState();
    context.read<FoldersCubit>().loadFoldersForLink(link.id);
  }

  Future<void> _deleteLink(BuildContext context) async {
    final cubit = context.read<FeedCubit>();
    await cubit.deleteLink(link.id);

    if (!context.mounted) return;

    context.pop();

    AppSnackbar.show(
      message: 'Link deleted',
      type: AppSnackbarType.success,
      onUndo: () => cubit.undoDelete(),
    );
  }

  Future<void> _openOnPlatform(BuildContext context) async {
    final launched = await Utils.openExternalUrl(link.url);
    if (!launched && context.mounted) {
      AppSnackbar.show(
        message: 'Could not open link',
        type: AppSnackbarType.error,
      );
    }
  }

  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: link.url));
    AppSnackbar.show(message: 'Link copied', type: AppSnackbarType.success);
    debugPrint('LinkDetailScreen: link is copied');
  }

  double _getImageHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40; // side margins
    if (link.imageWidth == null || link.imageHeight == null) {
      return screenWidth * 0.75;
    }
    final aspectRatio = link.imageWidth! / link.imageHeight!;
    final calculatedHeight = screenWidth / aspectRatio;
    final maxHeight = MediaQuery.of(context).size.height * 0.4;
    return calculatedHeight.clamp(180, maxHeight);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Added today';
    if (diff == 1) return 'Added yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Added on ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = _getImageHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar, separate from image
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  if (link.platform != null && link.platform!.isNotEmpty)
                    _PlatformBadge(platform: link.platform!),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title first
                    Text(
                      link.title ?? link.url,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    // const SizedBox(height: 6),
                    // Row(
                    //   children: [
                    //     Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                    //     const SizedBox(width: 6),
                    //     Text(
                    //       _formatDate(link.createdAt),
                    //       style: const TextStyle(
                    //         fontSize: 12.5,
                    //         color: AppColors.textSecondary,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 18),

                    // Image, with margin, not touching top
                    GestureDetector(
                      onTap: () => _openOnPlatform(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child:
                            (link.imageUrl != null && link.imageUrl!.isNotEmpty)
                            ? Image.network(
                                link.imageUrl!,
                                width: double.infinity,
                                height: imageHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: imageHeight,
                                  color: AppColors.surfaceElevated,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              )
                            : Container(
                                height: imageHeight,
                                color: AppColors.surfaceElevated,
                                child: const Center(
                                  child: Icon(Icons.link, size: 40),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // URL info card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outline, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              link.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyUrl(context),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 17,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom actions, icon + label in a row, each as a pill
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionPill(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      color: const Color(0xFFE05252),
                      onTap: () => _deleteLink(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionPill(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      color: AppColors.textPrimary,
                      onTap: () {
                        // share_plus implementation
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<FoldersCubit, FoldersState>(
                    builder: (context, state) {
                      final allFolders = state is FoldersSuccess
                          ? state.folders.map((folder) {
                              return folder.folder;
                            }).toList()
                          : <Folder>[];

                      final selectedIds = state is FoldersSuccess
                          ? state.linkFolderIds
                          : <int>{};

                      return Expanded(
                        child: FolderPopoverButton(
                          folders: allFolders,
                          selectedFolderIds: selectedIds,
                          onToggleFolder: (folderId) {
                            context.read<FoldersCubit>().toggleLinkFolder(
                              link.id,
                              folderId,
                            );
                          },
                          child: ActionPill(
                            icon: Icons.folder_outlined,
                            label: 'Folder',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(link.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String platform;

  const _PlatformBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        platform,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
