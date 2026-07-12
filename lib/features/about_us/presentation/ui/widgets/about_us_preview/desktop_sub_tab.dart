part of '../../pages/about_us_preview.dart';

class _DesktopSubTab extends StatefulWidget {
  final String label, iconUrl, description;
  final bool isSelected;
  final Color primary, secondary;
  final VoidCallback onTap;
  const _DesktopSubTab({
    required this.label, required this.iconUrl, required this.description,
    required this.isSelected, required this.primary, required this.secondary,
    required this.onTap,
  });
  @override State<_DesktopSubTab> createState() => _DesktopSubTabState();
}
class _DesktopSubTabState extends State<_DesktopSubTab> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final Color ico = widget.isSelected ? Colors.white : widget.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _kSurface
                : (_hov ? _hoverTint(widget.primary) : _kSurface),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: widget.isSelected ? widget.primary : widget.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: widget.iconUrl.isNotEmpty
                        ? _netImg(url: widget.iconUrl, width: 20, height: 20,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(ico, BlendMode.srcIn))
                        : Icon(Icons.image_outlined, size: 20, color: ico),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(child: Text(widget.label,
                    style: StyleText.fontSize14Weight600.copyWith(
                        fontSize: 14, color: widget.primary))),
              ]),
              if (widget.isSelected && widget.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(widget.description,
                    maxLines: 5, overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize11Weight400.copyWith(
                        fontSize: 11,
                        height: 1.65,
                        color: AppColors.secondaryBlack)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET SUB-TAB ITEM  (mirrors _TabletTabItem in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
