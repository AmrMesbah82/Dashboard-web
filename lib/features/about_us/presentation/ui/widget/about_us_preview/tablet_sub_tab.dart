part of '../../pages/about_us_preview.dart';

class _TabletSubTab extends StatefulWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primary, secondary;
  final VoidCallback onTap;
  const _TabletSubTab({
    required this.label, required this.iconUrl, required this.isSelected,
    required this.primary, required this.secondary, required this.onTap,
  });
  @override State<_TabletSubTab> createState() => _TabletSubTabState();
}
class _TabletSubTabState extends State<_TabletSubTab> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primary
                : (_hov ? _hoverTint(widget.primary) : _kSurface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? widget.primary
                  : (_hov ? widget.primary.withOpacity(0.3) : _kDivider),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.iconUrl.isNotEmpty)
              _netImg(url: widget.iconUrl, width: 16, height: 16,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      widget.isSelected ? Colors.white : widget.primary,
                      BlendMode.srcIn))
            else
              Icon(Icons.image_outlined, size: 16,
                  color: widget.isSelected ? Colors.white : widget.primary),
            const SizedBox(width: 6),
            Flexible(child: Text(widget.label,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? Colors.white : widget.primary))),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE ACCORDION  (mirrors _MobileAccordionItem in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
