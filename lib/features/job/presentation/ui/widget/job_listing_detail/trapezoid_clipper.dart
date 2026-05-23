part of '../../pages/job_listing_detail.dart';

class _TrapezoidClipper extends CustomClipper<Path> {
  final double topWidthFraction;
  final double bottomWidthFraction;

  _TrapezoidClipper({
    required this.topWidthFraction,
    required this.bottomWidthFraction,
  });

  @override
  Path getClip(Size size) {
    final topInset = size.width * (1.0 - topWidthFraction) / 2;
    final bottomInset = size.width * (1.0 - bottomWidthFraction) / 2;

    return Path()
      ..moveTo(topInset, 0)
      ..lineTo(size.width - topInset, 0)
      ..lineTo(size.width - bottomInset, size.height)
      ..lineTo(bottomInset, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_TrapezoidClipper oldClipper) =>
      topWidthFraction != oldClipper.topWidthFraction ||
          bottomWidthFraction != oldClipper.bottomWidthFraction;
}
