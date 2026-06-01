part of '../../pages/careers_preview.dart';

class _BulletText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _BulletText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.45, right: 6),
          child: Container(
            width:  fontSize * 0.4,
            height: fontSize * 0.4,
            decoration: const BoxDecoration(
              color: Color(0xFF444444),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   fontSize,
              height:     1.7,
              color:      const Color(0xFF444444),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAT CARD  — number-headline style matching Figma stats grid
// ═══════════════════════════════════════════════════════════════════════════════
