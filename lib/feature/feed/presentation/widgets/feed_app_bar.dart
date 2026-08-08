import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';


class CustomAppBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSearchFocusChanged;
  final VoidCallback onAddButtonTap;
  final VoidCallback onClearFilter;
  final bool hasActiveFilter;
  final bool isSearchingState;

  const CustomAppBar({
    super.key,
    required this.onSearchChanged,
    required this.onSearchFocusChanged,
    required this.onAddButtonTap,
    required this.onClearFilter,
    required this.hasActiveFilter,
    required this.isSearchingState
  });
  @override
  State<CustomAppBar> createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      widget.onSearchFocusChanged(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 12, 3),
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.only(left: 4, right: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.onBackground,
                        size: 20,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: (value) {
                          widget.onSearchChanged(value);
                          setState(() {});
                        },
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 15,
                        ),
                        cursorColor: AppColors.primaryLight,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search links...',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty || widget.isSearchingState == true)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                          widget.onClearFilter(); // reset platform filter
                          _focusNode.unfocus();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.onBackground,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            if(widget.isSearchingState != true)
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: widget.onAddButtonTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  elevation: 0,
                ),
                child: const Icon(
                  Icons.add,
                  size: 26,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}