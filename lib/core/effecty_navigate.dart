import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FadePage — GoRouter page wrapper
// ALL animation lives here. Pages themselves must NOT have their own entrance
// animation — that causes the two to fight and neither is visible.
// ═══════════════════════════════════════════════════════════════════════════════

class FadePage<T> extends Page<T> {
  final Widget child;

  const FadePage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => _CornerSlideRoute<T>(
    settings: this,
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// AnimatedPageRoute — same animation, for Navigator.push calls
// ═══════════════════════════════════════════════════════════════════════════════

class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  AnimatedPageRoute({required Widget page})
      : super(
    pageBuilder:               (_, __, ___) => page,
    transitionDuration:        const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder:        _cornerSlideBuilder,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared route implementation
// ═══════════════════════════════════════════════════════════════════════════════

class _CornerSlideRoute<T> extends PageRouteBuilder<T> {
  _CornerSlideRoute({required RouteSettings settings, required Widget child})
      : super(
    settings:                  settings,
    pageBuilder:               (_, __, ___) => child,
    transitionDuration:        const Duration(milliseconds: 900),
    reverseTransitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder:        _cornerSlideBuilder,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// The actual animation — bottom-right corner sweep
// ═══════════════════════════════════════════════════════════════════════════════

Widget _cornerSlideBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  final slide = Tween<Offset>(
    begin: const Offset(1.0, 1.0),
    end:   Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve:  Curves.easeOutCubic,
  ));

  final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: animation,
      curve:  const Interval(0.0, 0.5, curve: Curves.easeIn),
    ),
  );

  final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
  );

  final tilt = Tween<double>(begin: -0.06, end: 0.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
  );

  final fadeOut = Tween<double>(begin: 1.0, end: 0.88).animate(
    CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
  );

  return FadeTransition(
    opacity: fadeOut,
    child: FadeTransition(
      opacity: fadeIn,
      child: SlideTransition(
        position: slide,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, inner) => Transform(
            alignment: Alignment.bottomRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(tilt.value)
              ..scale(scale.value),
            child: inner,
          ),
          child: child,
        ),
      ),
    ),
  );
}