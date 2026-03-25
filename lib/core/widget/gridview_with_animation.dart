import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedCustomGridView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double mainAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Duration animationDuration;
  final Duration staggerDelay;
  final Curve curve;

  const AnimatedCustomGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    this.mainAxisSpacing = 15,
    this.crossAxisSpacing = 15,
    this.margin,
    this.height,
    this.physics = const BouncingScrollPhysics(),
    this.shrinkWrap = true,
    this.animationDuration = const Duration(milliseconds: 800), // Duration for EACH item
    this.staggerDelay = const Duration(milliseconds: 150), // Delay between items
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<AnimatedCustomGridView> createState() => _AnimatedCustomGridViewState();
}

class _AnimatedCustomGridViewState extends State<AnimatedCustomGridView>
    with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    //print('🎬 Initializing animations for ${widget.itemCount} items');

    // Dispose old controller if exists
    if (_slideAnimations.isNotEmpty) {
      _gridAnimationController.dispose();
    }

    // Calculate total duration needed
    // Total = (itemCount * staggerDelay) + animationDuration
    final totalDuration = Duration(
      milliseconds: (widget.itemCount * widget.staggerDelay.inMilliseconds) +
          widget.animationDuration.inMilliseconds,
    );

    //print('⏱️ Total animation duration: ${totalDuration.inMilliseconds}ms');

    // Create controller with total duration
    _gridAnimationController = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    // Create slide animations for each item
    _slideAnimations = List.generate(widget.itemCount, (index) {
      // Calculate start and end time for this item
      final startTime = index * widget.staggerDelay.inMilliseconds;
      final endTime = startTime + widget.animationDuration.inMilliseconds;

      // Convert to 0.0 - 1.0 range
      final startFraction = startTime / totalDuration.inMilliseconds;
      final endFraction = math.min(endTime / totalDuration.inMilliseconds, 1.0);

      //print('📊 Item $index: starts at ${startFraction.toStringAsFixed(2)}, ends at ${endFraction.toStringAsFixed(2)}');

      return Tween<Offset>(
        begin: const Offset(-1.0, 0.0), // Slide from left
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            startFraction,
            endFraction,
            curve: widget.curve,
          ),
        ),
      );
    });

    // Start animation
    _gridAnimationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedCustomGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize if item count changes
    if (oldWidget.itemCount != widget.itemCount) {
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin,
      child: GridView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          mainAxisExtent: widget.mainAxisExtent,
        ),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          // Safety check
          if (index >= _slideAnimations.length) {
            return widget.itemBuilder(context, index);
          }

          // Wrap item with slide animation
          return SlideTransition(
            position: _slideAnimations[index],
            child: widget.itemBuilder(context, index),
          );
        },
      ),
    );
  }
}