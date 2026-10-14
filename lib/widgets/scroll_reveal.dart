import 'dart:async';
import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════════
/// SCROLL REVEAL ANIMATOR ENGINE (Fail-Safe & High Performance)
/// Ensures elements gracefully slide-up & fade-in upon entering viewport.
/// GUARANTEED to never leave content blank or invisible.
/// ══════════════════════════════════════════════════════════════════

enum RevealDirection {
  up,    // Slides up into view (default)
  down,  // Slides down into view
  left,  // Slides in from the right
  right, // Slides in from the left
  scale, // Subtle zoom scale in place
}

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double slideOffset;
  final RevealDirection direction;
  final Curve curve;
  final bool enableScale;
  final double startScale;

  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.slideOffset = 28.0,
    this.direction = RevealDirection.up,
    this.curve = Curves.easeOutCubic,
    this.enableScale = true,
    this.startScale = 0.97,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  ScrollPosition? _scrollPosition;
  bool _isVisible = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    Offset beginOffset;
    switch (widget.direction) {
      case RevealDirection.up:
        beginOffset = Offset(0, widget.slideOffset / 100);
        break;
      case RevealDirection.down:
        beginOffset = Offset(0, -widget.slideOffset / 100);
        break;
      case RevealDirection.left:
        beginOffset = Offset(widget.slideOffset / 100, 0);
        break;
      case RevealDirection.right:
        beginOffset = Offset(-widget.slideOffset / 100, 0);
        break;
      case RevealDirection.scale:
        beginOffset = Offset.zero;
        break;
    }

    _slideAnim = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved);

    _scaleAnim = widget.enableScale
        ? Tween<double>(begin: widget.startScale, end: 1.0).animate(curved)
        : const AlwaysStoppedAnimation(1.0);

    // Fail-safe watchdog: Ensure content is NEVER permanently blank
    _safetyTimer = Timer(const Duration(milliseconds: 400) + widget.delay, () {
      if (mounted && !_controller.isCompleted) {
        _isVisible = true;
        _controller.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_checkVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _scrollPosition?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _isVisible) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final position = renderObject.localToGlobal(Offset.zero);
    final itemTop = position.dy;
    final itemBottom = position.dy + renderObject.size.height;

    // Viewport threshold: element is reachable or within view
    final isInViewport = itemTop < screenHeight * 0.98 && itemBottom > -50;

    if (isInViewport) {
      _isVisible = true;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _fadeAnim.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: _slideAnim.value * 100,
            child: Transform.scale(
              scale: _scaleAnim.value,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
