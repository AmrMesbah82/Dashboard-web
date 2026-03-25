import 'package:flutter/material.dart';

class AnimatedPageRoute extends PageRouteBuilder {
  final Widget page;

  AnimatedPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300  ),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {

      // ── Slide from bottom-right corner ──────────────────────────────
      final slideTween = Tween<Offset>(
        begin: const Offset(1.0, 1.0), // bottom-right corner
        end:   Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      // ── Fade in ─────────────────────────────────────────────────────
      final fadeTween = Tween<double>(
        begin: 0.0,
        end:   1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ));

      // ── Scale: grows from corner ────────────────────────────────────
      final scaleTween = Tween<double>(
        begin: 0.85,
        end:   1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      // ── 3-D tilt as it comes in ─────────────────────────────────────
      final skewTween = Tween<double>(
        begin: -0.06,
        end:   0.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      // ── Previous page fades + shrinks slightly ──────────────────────
      final exitFade = Tween<double>(
        begin: 1.0,
        end:   0.88,
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeIn,
      ));

      return FadeTransition(
        opacity: exitFade,
        child: FadeTransition(
          opacity: fadeTween,
          child: SlideTransition(
            position: slideTween,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(skewTween.value)
                    ..scale(scaleTween.value),
                  alignment: Alignment.bottomRight, // anchor = corner
                  child: child,
                );
              },
              child: child,
            ),
          ),
        ),
      );
    },
  );
}