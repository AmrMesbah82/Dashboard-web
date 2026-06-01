part of '../../pages/why_join_preview.dart';

class _ViewBar extends StatelessWidget {
  final double? width;
  const _ViewBar({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width ?? double.infinity,
      height: 36,
      decoration: const BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: const [
          Text(
            'View',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
