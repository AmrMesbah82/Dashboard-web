part of '../../pages/careers_preview.dart';

class _ViewBar extends StatelessWidget {
  final double? width;
  const _ViewBar({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width ?? double.infinity,
      height: 36,
      decoration:  BoxDecoration(
        color:        _kGreen,
        borderRadius: BorderRadius.circular(8.r)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            'View',
            style: StyleText.fontSize13Weight600.copyWith(
              fontSize: 13,
              color:    Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT  — rendered at native device resolution then scaled
// ═══════════════════════════════════════════════════════════════════════════════
