// ******************* FILE INFO *******************
// File Name: branding_helper.dart
// Description: Global helpers to read CMS branding colors/fonts from
//              HomeCmsCubit state anywhere in the app.
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';

// ── Default fallback colors (used before CMS loads) ──────────────────────────
const Color _kDefaultPrimary   = Color(0xFF008037);
const Color _kDefaultSecondary = Color(0xFF4049B9);

// ── Parse hex string → Color ──────────────────────────────────────────────────
Color hexToColor(String hex, {Color fallback = _kDefaultPrimary}) {
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return fallback;
}

// ── Extract branding from any HomeCmsState ────────────────────────────────────
extension HomeCmsStateX on HomeCmsState {
  String get _primaryHex => switch (this) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };

  String get _secondaryHex => switch (this) {
    HomeCmsLoaded(:final data) => data.branding.secondaryColor,
    HomeCmsSaved(:final data)  => data.branding.secondaryColor,
    _                          => '',
  };

  Color get primaryColor   => hexToColor(_primaryHex,   fallback: _kDefaultPrimary);
  Color get secondaryColor => hexToColor(_secondaryHex, fallback: _kDefaultSecondary);
}

// ── Read directly from BuildContext (no BlocBuilder needed) ──────────────────
extension BrandingContext on BuildContext {
  /// Quick access: context.primaryBrandColor
  Color get primaryBrandColor {
    try {
      final state = read<HomeCmsCubit>().state;
      return state.primaryColor;
    } catch (_) {
      return _kDefaultPrimary;
    }
  }

  /// Quick access: context.secondaryBrandColor
  Color get secondaryBrandColor {
    try {
      final state = read<HomeCmsCubit>().state;
      return state.secondaryColor;
    } catch (_) {
      return _kDefaultSecondary;
    }
  }
}

// ── BrandingBuilder widget — rebuilds when branding changes ──────────────────
/// Wrap any widget that needs live branding colors.
/// Usage:
///   BrandingBuilder(
///     builder: (context, primary, secondary) => MyWidget(color: primary),
///   )
class BrandingBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Color primary, Color secondary) builder;

  const BrandingBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      buildWhen: (prev, next) =>
      prev.primaryColor != next.primaryColor ||
          prev.secondaryColor != next.secondaryColor,
      builder: (context, state) =>
          builder(context, state.primaryColor, state.secondaryColor),
    );
  }
}