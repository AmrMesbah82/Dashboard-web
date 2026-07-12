part of '../../pages/about_us_preview.dart';

class _ValueCard extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primary;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  const _ValueCard({
    required this.title, required this.iconUrl, required this.isSelected,
    required this.primary, required this.width, required this.iconSize,
    required this.fontSize, required this.padding, required this.onTap,
  });
  @override State<_ValueCard> createState() => _ValueCardState();
}
class _ValueCardState extends State<_ValueCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Widget ico = widget.iconUrl.isNotEmpty
        ? _netImg(url: widget.iconUrl, width: widget.iconSize,
        height: widget.iconSize, fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
            sel ? Colors.white : widget.primary, BlendMode.srcIn))
        : Icon(Icons.star_outline, size: widget.iconSize,
        color: sel ? Colors.white : widget.primary);

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hov = true),
        onExit:  (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width, padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel ? widget.primary
                : (_hov ? _hoverTint(widget.primary) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            boxShadow: sel
                ? [BoxShadow(color: widget.primary.withValues(alpha: 0.28),
                blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ico, const SizedBox(height: 6),
            Text(widget.title, textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight600.copyWith(
                    fontSize: widget.fontSize,
                    color: sel ? Colors.white
                        : (_hov ? widget.primary : Colors.black87),
                    height: 1.35)),
          ]),
        ),
      ),
    );
  }
}

// ── Value detail panel ────────────────────────────────────────────────────────
