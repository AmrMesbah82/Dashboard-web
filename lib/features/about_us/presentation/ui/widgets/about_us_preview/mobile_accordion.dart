part of '../../pages/about_us_preview.dart';

class _MobileAccordion extends StatefulWidget {
  final String label, iconUrl;
  final bool isExpanded;
  final Color primary, secondary;
  final VoidCallback onTap;
  final Widget child;
  const _MobileAccordion({
    required this.label, required this.iconUrl, required this.isExpanded,
    required this.primary, required this.secondary,
    required this.onTap, required this.child,
  });
  @override State<_MobileAccordion> createState() => _MobileAccordionState();
}
class _MobileAccordionState extends State<_MobileAccordion> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? _kSurface : (_hov ? _hoverTint(widget.primary) : _kSurface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _hov && !widget.isExpanded
                ? widget.primary.withValues(alpha: 0.25) : Colors.transparent),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hov = true),
          onExit:  (_) => setState(() => _hov = false),
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: widget.isExpanded ? widget.primary : widget.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: widget.iconUrl.isNotEmpty
                        ? _netImg(url: widget.iconUrl, width: 18, height: 18,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                            widget.isExpanded ? Colors.white : widget.primary,
                            BlendMode.srcIn))
                        : Icon(Icons.image_outlined, size: 16,
                        color: widget.isExpanded
                            ? Colors.white : widget.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.label,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                        fontWeight: FontWeight.w600, color: widget.primary))),
                if (widget.isExpanded)
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                        color: widget.primary,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.keyboard_arrow_up_rounded,
                        color: Colors.white, size: 16),
                  ),
              ]),
            ),
          ),
        ),
        if (widget.isExpanded)
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: widget.child),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID  (mirrors _ValuesGridDesktop / Tablet / Mobile in about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════
