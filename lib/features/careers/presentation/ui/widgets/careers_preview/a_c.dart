part of '../../pages/careers_preview.dart';

class _AC {
  static const Color primary   = Color(0xFF008037);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color red       = Color(0xFFD32F2F);
}

// ── User-app palette (mirrors live careers page) ──────────────────────────────
const Color _kGreen      = Color(0xFF008037);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kDivider    = Color(0xFFDDE8DD);
const Color _kBodyBg     = Color(0xFFF8F9FA);

// ── Device viewport constants ─────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1200.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  900.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

// ── Network image via HtmlElementView ────────────────────────────────────────
Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  if (url.isEmpty) return const SizedBox.shrink();
  final id =
      'careers-pv-${url.hashCode}-${width?.toInt()}-${height?.toInt()}-${fit.index}';
  ui_web.platformViewRegistry.registerViewFactory(id, (_) {
    final img = html.ImageElement()
      ..src = url
      ..style.width  = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });
  Widget inner = HtmlElementView(viewType: id);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE  (admin shell)
// ═══════════════════════════════════════════════════════════════════════════════
