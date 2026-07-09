// ******************* FILE INFO *******************
// File Name: custom_dropdown_new.dart
// Description: Project-adapted CustomDropdown.
//   Border rule: NO border by default; red only on error.
//   Default height 36 / radius 4. Adapted to web_app_admin theme + assets.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

/// A dropdown item model
class DropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const DropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

/// Custom dropdown widget
class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool required;
  final Color? fillColor;
  final double? maxOverlayHeight;
  final EdgeInsetsGeometry? triggerPadding;
  final BorderRadius? borderRadius;
  final TextStyle? valueStyle;
  final TextStyle? hintStyle;
  final TextStyle? itemStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final double? itemHeight;
  final double overlayElevation;
  final double? overlayOffset;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.required = false,
    this.fillColor,
    this.maxOverlayHeight,
    this.triggerPadding,
    this.borderRadius,
    this.valueStyle,
    this.hintStyle,
    this.itemStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.itemHeight,
    this.overlayElevation = 4,
    this.overlayOffset,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
    this.onOpen,
    this.onClose,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _triggerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _closeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _isOpen ? _closeOverlay() : _openOverlay();
  }

  void _openOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final verticalOffset = widget.overlayOffset ?? 2.h;

    final globalOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - globalOffset.dy - triggerSize.height;
    final spaceAbove = globalOffset.dy;
    final openUpward = spaceBelow < 150.h && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(
        layerLink: _layerLink,
        triggerSize: triggerSize,
        verticalOffset: verticalOffset,
        openUpward: openUpward,
        items: widget.items,
        maxHeight: widget.maxOverlayHeight ?? 240.h,
        itemHeight: widget.itemHeight ?? 36.sp,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4.r),
        elevation: widget.overlayElevation,
        itemStyle: widget.itemStyle,
        showDivider: widget.showDivider,
        dividerColor: widget.dividerColor,
        emptyWidget: widget.emptyWidget,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        selectedValue: widget.value,
        onSelected: (item) {
          _closeOverlay();
          widget.onChanged?.call(item.value);
        },
        onDismiss: _closeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() => _isOpen = true);
    widget.onOpen?.call();
  }

  void _closeOverlay() {
    if (_overlayEntry == null) return;
    _animController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    if (mounted) setState(() => _isOpen = false);
    widget.onClose?.call();
  }

  DropdownItem<T>? get _selectedItem {
    try {
      return widget.items.firstWhere((e) => e.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: widget.labelStyle ??
                  StyleText.fontSize12Weight500.copyWith(
                    color: hasError
                        ? AppColors.red
                        : widget.enabled
                            ? AppColors.text
                            : AppColors.text.withValues(alpha: 0.4),
                  ),
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.red),
                      )
                    ]
                  : [],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: InputDecorator(
              key: _triggerKey,
              isFocused: false,
              isEmpty: _selectedItem == null,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: widget.triggerPadding ??
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                filled: true,
                fillColor: widget.enabled
                    ? (widget.fillColor ?? AppColors.card)
                    : AppColors.card.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: hasError
                      ? BorderSide(color: AppColors.red, width: 1.5.w)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: hasError
                      ? BorderSide(color: AppColors.red, width: 1.5.w)
                      : BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(left: 12.w, right: 8.w),
                        child: widget.prefixIcon,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 12.w),
                  child: widget.suffixIcon ??
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: SvgPicture.asset(
                          'assets/arrowdown.svg',
                          width: 20.sp,
                          height: 20.sp,
                          colorFilter: ColorFilter.mode(
                            hasError
                                ? AppColors.red
                                : widget.enabled
                                    ? AppColors.text.withValues(alpha: 0.6)
                                    : AppColors.text.withValues(alpha: 0.3),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                ),
                suffixIconConstraints: const BoxConstraints(),
                hintText: _selectedItem == null ? (widget.hint ?? '') : null,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text.withValues(alpha: 0.4),
                    ),
                errorText: null,
              ),
              child: _selectedItem != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedItem!.leading != null) ...[
                          _selectedItem!.leading!,
                          SizedBox(width: 8.w),
                        ],
                        Expanded(
                          child: Text(
                            _selectedItem!.label,
                            style: widget.valueStyle ??
                                StyleText.fontSize12Weight400.copyWith(
                                  color: widget.enabled
                                      ? AppColors.text
                                      : AppColors.text.withValues(alpha: 0.4),
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: widget.errorStyle ??
                StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.helperText!,
            style: widget.helperStyle ??
                StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5)),
          ),
        ],
      ],
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final Size triggerSize;
  final double verticalOffset;
  final bool openUpward;
  final List<DropdownItem<T>> items;
  final double maxHeight;
  final double itemHeight;
  final BorderRadius borderRadius;
  final double elevation;
  final TextStyle? itemStyle;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final T? selectedValue;
  final ValueChanged<DropdownItem<T>> onSelected;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.layerLink,
    required this.triggerSize,
    required this.verticalOffset,
    required this.openUpward,
    required this.items,
    required this.maxHeight,
    required this.itemHeight,
    required this.borderRadius,
    required this.elevation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onSelected,
    required this.onDismiss,
    this.itemStyle,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onDismiss,
            ),
          ),
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor:
                openUpward ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            offset: Offset(
              0,
              openUpward ? -verticalOffset : verticalOffset,
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                alignment: openUpward
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                child: Material(
                  elevation: elevation,
                  borderRadius: borderRadius,
                  color: AppColors.card,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      minWidth: triggerSize.width,
                      maxWidth: triggerSize.width,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: items.isEmpty
                          ? SizedBox(
                              height: itemHeight,
                              child: emptyWidget ??
                                  Center(
                                    child: Text(
                                      'No options',
                                      style: StyleText.fontSize13Weight400
                                          .copyWith(
                                        color: AppColors.text
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: items.length,
                              separatorBuilder: (_, __) => showDivider
                                  ? Divider(
                                      height: 1.h,
                                      thickness: 1.h,
                                      color: dividerColor ??
                                          AppColors.text.withValues(alpha: 0.08),
                                    )
                                  : const SizedBox.shrink(),
                              itemBuilder: (_, i) {
                                final item = items[i];
                                final isSelected = item.value == selectedValue;
                                return _DropdownItemTile<T>(
                                  item: item,
                                  isSelected: isSelected,
                                  height: itemHeight,
                                  style: itemStyle,
                                  onTap: item.enabled
                                      ? () => onSelected(item)
                                      : null,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItemTile<T> extends StatefulWidget {
  final DropdownItem<T> item;
  final bool isSelected;
  final double height;
  final TextStyle? style;
  final VoidCallback? onTap;

  const _DropdownItemTile({
    required this.item,
    required this.isSelected,
    required this.height,
    this.style,
    this.onTap,
  });

  @override
  State<_DropdownItemTile<T>> createState() => _DropdownItemTileState<T>();
}

class _DropdownItemTileState<T> extends State<_DropdownItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          color: widget.isSelected
              ? AppColors.primary
              : (_hovered && !isDisabled)
                  ? AppColors.primary
                  : Colors.transparent,
          child: Row(
            children: [
              if (widget.item.leading != null) ...[
                widget.item.leading!,
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: (widget.style ??
                          (widget.isSelected
                              ? StyleText.fontSize12Weight500
                              : StyleText.fontSize12Weight400))
                      .copyWith(
                    color: isDisabled
                        ? AppColors.text.withValues(alpha: 0.3)
                        : (widget.isSelected || _hovered)
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.item.trailing != null) ...[
                SizedBox(width: 8.w),
                widget.item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
