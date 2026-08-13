import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';

class FolderPopoverButton extends StatefulWidget {
  final Widget child;
  final List<Folder> folders;
  final Set<int> selectedFolderIds;
  final ValueChanged<int> onToggleFolder;

  const FolderPopoverButton({
    super.key,
    required this.child,
    required this.folders,
    required this.selectedFolderIds,
    required this.onToggleFolder,
  });

  @override
  State<FolderPopoverButton> createState() => _FolderPopoverButtonState();
}

class _FolderPopoverButtonState extends State<FolderPopoverButton>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();

  OverlayEntry? _entry;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  void _toggle() {
    if (_entry == null) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(builder: (_) => _buildOverlay());
    overlay.insert(_entry!);
    _controller.forward(from: 0);
  }

  Future<void> _close() async {
    await _controller.reverse();
    _entry?.remove();
    _entry = null;
  }

  @override
  void didUpdateWidget(covariant FolderPopoverButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_entry != null &&
        (oldWidget.folders != widget.folders ||
            oldWidget.selectedFolderIds != widget.selectedFolderIds)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _entry != null) {
          _entry!.markNeedsBuild();
        }
      });
    }
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            child: const SizedBox.shrink(),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _controller,
                child: _PopoverCard(
                  folders: widget.folders,
                  selectedFolderIds: widget.selectedFolderIds,
                  onToggleFolder: widget.onToggleFolder,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: widget.child,
      ),
    );
  }
}

class _PopoverCard extends StatelessWidget {
  final List<Folder> folders;
  final Set<int> selectedFolderIds;
  final ValueChanged<int> onToggleFolder;

  const _PopoverCard({
    required this.folders,
    required this.selectedFolderIds,
    required this.onToggleFolder,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: folders.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No folders yet', style: TextStyle(fontSize: 13)),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: folders.map((folder) {
            final isSelected = selectedFolderIds.contains(folder.id);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onToggleFolder(folder.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? scheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? scheme.primary : scheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, size: 13, color: scheme.onPrimary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        folder.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}