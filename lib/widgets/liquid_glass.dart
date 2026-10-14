import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ══════════════════════════════════════════════════════════════════
/// LIQUID GLASS CARD — Light-Mode Frosted Glass Elegance
/// Ultra-premium white frosted glass with colored ambient accents.
/// ══════════════════════════════════════════════════════════════════
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final Color? borderColor;
  final List<BoxShadow>? customShadows;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 24,
    this.blurSigma = 20.0,
    this.tintColor,
    this.borderColor,
    this.customShadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tintColor ?? AppColors.pnlPrimary;

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: customShadows ??
            [
              // Soft elevation shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              // Subtle colored ambient glow
              BoxShadow(
                color: accent.withOpacity(0.08),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              // White frosted glass fill
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.82),
                  Colors.white.withOpacity(0.65),
                ],
              ),
              border: Border.all(
                width: 1.0,
                color: borderColor ?? Colors.white.withOpacity(0.90),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      );
    }
    return content;
  }
}

/// ══════════════════════════════════════════════════════════════════
/// ANTIGRAVITY GRID PAINTER — Light Corporate Micro-Grid
/// Refined dot-matrix + crosshair on white canvas
/// ══════════════════════════════════════════════════════════════════
class AntigravityGridPainter extends CustomPainter {
  final double pulse;
  final double openingProgress;

  AntigravityGridPainter({required this.pulse, required this.openingProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (openingProgress <= 0.01) return;

    // Subtle dark dots on white background
    final dotPaint = Paint()
      ..color = AppColors.pnlPrimary
          .withOpacity(0.06 * openingProgress * (0.85 + 0.15 * pulse))
      ..style = PaintingStyle.fill;

    final crossPaint = Paint()
      ..color = AppColors.pnlGold
          .withOpacity(0.09 * openingProgress * (0.80 + 0.20 * pulse))
      ..strokeWidth = 0.8;

    const double step = 60.0;
    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        if (((x / step).round() + (y / step).round()) % 4 == 0) {
          // Subtle crosshair accent
          canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), crossPaint);
          canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), crossPaint);
        } else {
          canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant AntigravityGridPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.openingProgress != openingProgress;
  }
}

/// ══════════════════════════════════════════════════════════════════
/// AMBIENT LIQUID BACKDROP — White Island Canvas
/// Pure white base + vivid 6-jurusan pastel orbs + PNL gold focal
/// Antigravity entrance + Lissajous orbital drift + breathing pulse
/// ══════════════════════════════════════════════════════════════════
class AmbientLiquidBackdrop extends StatefulWidget {
  final Widget child;

  const AmbientLiquidBackdrop({super.key, required this.child});

  @override
  State<AmbientLiquidBackdrop> createState() => _AmbientLiquidBackdropState();
}

class _AmbientLiquidBackdropState extends State<AmbientLiquidBackdrop>
    with TickerProviderStateMixin {
  late AnimationController _driftController;
  late AnimationController _pulseController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    // Smooth corporate opening lift (2.8s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    // Zero-gravity orbital drift (28s full cycle)
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    // Luminous breathing pulse (7s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _driftController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildOrb({
    required double x,
    required double y,
    required double size,
    required Color primaryColor,
    required Color secondaryColor,
    required double baseOpacity,
    required double entranceProgress,
    required double pulseVal,
  }) {
    final effectiveOpacity =
        (baseOpacity * entranceProgress * (0.90 + 0.10 * pulseVal))
            .clamp(0.0, 1.0);
    final effectiveSize = size * (0.75 + 0.25 * entranceProgress);

    return Positioned(
      left: x - (effectiveSize / 2),
      top: y - (effectiveSize / 2),
      child: IgnorePointer(
        child: Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryColor.withOpacity(effectiveOpacity),
                secondaryColor.withOpacity(effectiveOpacity * 0.40),
                Colors.transparent,
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCapsule({
    required double x,
    required double y,
    required double width,
    required double height,
    required double angle,
    required Color accentColor,
    required double entranceProgress,
  }) {
    return Positioned(
      left: x,
      top: y,
      child: IgnorePointer(
        child: Opacity(
          opacity: (0.90 * entranceProgress).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                // Glassy white fill
                color: Colors.white.withOpacity(0.55),
                border: Border.all(
                  color: accentColor.withOpacity(0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.20),
                    blurRadius: 22,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.80),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final w = screenSize.width;
    final h = screenSize.height;

    return Stack(
      children: [
        // ── LAYER 1: Pure White Island Canvas ──────────────────────
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.15, -0.20),
              radius: 1.45,
              colors: [
                Color(0xFFFFFFFF), // Pure white center (island clean)
                Color(0xFFF6F8FF), // Soft ice-blue white
                Color(0xFFEEF2FF), // Very subtle indigo-white edge
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // ── LAYER 2: Corporate Micro-Grid (breathing, colored) ──────
        AnimatedBuilder(
          animation: Listenable.merge([_entranceController, _pulseController]),
          builder: (context, _) {
            final openProgress =
                Curves.easeOutCubic.transform(_entranceController.value);
            return CustomPaint(
              size: screenSize,
              painter: AntigravityGridPainter(
                pulse: _pulseController.value,
                openingProgress: openProgress,
              ),
            );
          },
        ),

        // ── LAYER 3: 6 Jurusan + Gold + White Orbs (Lissajous) ─────
        AnimatedBuilder(
          animation: Listenable.merge(
              [_entranceController, _driftController, _pulseController]),
          builder: (context, _) {
            final t = _driftController.value;
            final pulse = _pulseController.value;
            final entrance =
                Curves.easeOutQuart.transform(_entranceController.value);

            // — Orbital positions (Lissajous harmonic frequencies) —
            // 🔵 Teknik Sipil – top-left
            final sipilX = w * 0.08 + math.sin(t * 2 * math.pi + 0.3) * 48;
            final sipilY = h * 0.10 + math.cos(t * 2 * math.pi * 0.78) * 38;

            // 🔴 Teknik Mesin – top-right
            final mesinX =
                w * 0.84 + math.cos(t * 2 * math.pi * 0.88 + 1.2) * 52;
            final mesinY =
                h * 0.14 + math.sin(t * 2 * math.pi * 0.68 + 0.4) * 42;

            // 🟠 Teknik Kimia – mid-right
            final kimiaX =
                w * 0.90 + math.sin(t * 2 * math.pi * 0.63 + 2.4) * 44;
            final kimiaY =
                h * 0.50 + math.cos(t * 2 * math.pi * 0.83 + 1.8) * 50;

            // 🟣 Tata Niaga – lower-right
            final niagaX =
                w * 0.72 + math.cos(t * 2 * math.pi * 0.73 + 3.6) * 48;
            final niagaY =
                h * 0.86 + math.sin(t * 2 * math.pi * 0.58 + 3.1) * 44;

            // 🟤 TIK – bottom-left
            final tikX =
                w * 0.10 + math.sin(t * 2 * math.pi * 0.80 + 4.5) * 42;
            final tikY =
                h * 0.82 + math.cos(t * 2 * math.pi * 0.70 + 2.8) * 46;

            // 🟢 Teknik Elektro – mid-bottom
            final elektroX =
                w * 0.42 + math.cos(t * 2 * math.pi * 0.68 + 5.2) * 46;
            final elektroY =
                h * 0.90 + math.sin(t * 2 * math.pi * 0.88 + 4.3) * 40;

            // 🟡 PNL Gold – center focal
            final pnlGoldX =
                w * 0.52 + math.sin(t * 2 * math.pi * 0.48 + 1.0) * 34;
            final pnlGoldY =
                h * 0.36 + math.cos(t * 2 * math.pi * 0.58 + 0.8) * 38;

            return Stack(
              children: [
                // 🟡 PNL Signature Gold — big focal center orb
                _buildOrb(
                  x: pnlGoldX,
                  y: pnlGoldY,
                  size: math.min(w * 0.80, 660),
                  primaryColor: AppColors.pnlSignatureGold,
                  secondaryColor: const Color(0xFFFBBF24),
                  baseOpacity: 0.22,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🔵 Biru – Teknik Sipil
                _buildOrb(
                  x: sipilX,
                  y: sipilY,
                  size: math.min(w * 0.60, 520),
                  primaryColor: AppColors.jurusanSipil,
                  secondaryColor: AppColors.pnlCyanGlow,
                  baseOpacity: 0.20,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🔴 Merah – Teknik Mesin
                _buildOrb(
                  x: mesinX,
                  y: mesinY,
                  size: math.min(w * 0.55, 490),
                  primaryColor: AppColors.jurusanMesin,
                  secondaryColor: const Color(0xFFFCA5A5),
                  baseOpacity: 0.18,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🟠 Orange – Teknik Kimia
                _buildOrb(
                  x: kimiaX,
                  y: kimiaY,
                  size: math.min(w * 0.52, 465),
                  primaryColor: AppColors.jurusanKimia,
                  secondaryColor: const Color(0xFFFED7AA),
                  baseOpacity: 0.18,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🟣 Ungu – Tata Niaga
                _buildOrb(
                  x: niagaX,
                  y: niagaY,
                  size: math.min(w * 0.58, 515),
                  primaryColor: AppColors.jurusanTataNiaga,
                  secondaryColor: const Color(0xFFE9D5FF),
                  baseOpacity: 0.20,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🟤 Coklat-Amber – TIK
                _buildOrb(
                  x: tikX,
                  y: tikY,
                  size: math.min(w * 0.54, 475),
                  primaryColor: AppColors.jurusanTIK,
                  secondaryColor: const Color(0xFFFDE68A),
                  baseOpacity: 0.19,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // 🟢 Hijau – Teknik Elektro
                _buildOrb(
                  x: elektroX,
                  y: elektroY,
                  size: math.min(w * 0.52, 470),
                  primaryColor: AppColors.jurusanElektro,
                  secondaryColor: const Color(0xFFA7F3D0),
                  baseOpacity: 0.18,
                  entranceProgress: entrance,
                  pulseVal: pulse,
                ),

                // ⬡ Floating glass capsule accents
                _buildFloatingCapsule(
                  x: sipilX - 50,
                  y: sipilY + 110,
                  width: 88,
                  height: 28,
                  angle: -0.20,
                  accentColor: AppColors.jurusanSipil,
                  entranceProgress: entrance,
                ),
                _buildFloatingCapsule(
                  x: mesinX - 35,
                  y: mesinY + 130,
                  width: 76,
                  height: 26,
                  angle: 0.17,
                  accentColor: AppColors.jurusanMesin,
                  entranceProgress: entrance,
                ),
                _buildFloatingCapsule(
                  x: kimiaX - 90,
                  y: kimiaY - 35,
                  width: 100,
                  height: 30,
                  angle: -0.13,
                  accentColor: AppColors.pnlSignatureGold,
                  entranceProgress: entrance,
                ),
                _buildFloatingCapsule(
                  x: tikX + 55,
                  y: tikY - 55,
                  width: 82,
                  height: 28,
                  angle: 0.23,
                  accentColor: AppColors.jurusanElektro,
                  entranceProgress: entrance,
                ),
                _buildFloatingCapsule(
                  x: niagaX - 40,
                  y: niagaY - 45,
                  width: 70,
                  height: 24,
                  angle: -0.28,
                  accentColor: AppColors.jurusanTataNiaga,
                  entranceProgress: entrance,
                ),
              ],
            );
          },
        ),

        // ── LAYER 4: Global frosted unification blur ──────────────
        // Softer blur for light mode — preserves color visibility
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: Container(
              decoration: BoxDecoration(
                // Gentle white veil — keeps canvas bright & airy
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.30),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── LAYER 5: App content ──────────────────────────────────
        widget.child,
      ],
    );
  }
}

/// ══════════════════════════════════════════════════════════════════
/// ISLAND JURUSAN SPECTRUM BADGE — Light Mode Edition
/// Refined pill badge showing 6 departmental colors + PNL gold
/// ══════════════════════════════════════════════════════════════════
class IslandJurusanSpectrumBadge extends StatelessWidget {
  final bool compact;

  const IslandJurusanSpectrumBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final items = <Color>[
      AppColors.jurusanSipil,
      AppColors.jurusanMesin,
      AppColors.jurusanKimia,
      AppColors.jurusanTataNiaga,
      AppColors.jurusanTIK,
      AppColors.jurusanElektro,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.pnlPrimary.withOpacity(0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pnlSignatureGold.withOpacity(0.14),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.90),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PNL Gold Crown
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pnlSignatureGold,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlSignatureGold.withOpacity(0.55),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LINTAS 6 JURUSAN VOKASI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.pnlPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((color) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.60),
                      blurRadius: 5,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════
/// LIQUID BUTTON — Light Mode Edition
/// Vivid solid-color buttons with crisp shadows & hover animations
/// ══════════════════════════════════════════════════════════════════
class LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isGold;
  final bool isLoading;

  const LiquidButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isSecondary = false,
    this.isGold = false,
    this.isLoading = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor =
        widget.isGold ? AppColors.pnlSignatureGold : AppColors.pnlPrimary;
    Color glowColor =
        widget.isGold ? AppColors.pnlGold : AppColors.jurusanSipil;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isSecondary
                ? LinearGradient(
                    colors: [
                      _isHovered
                          ? Colors.white.withOpacity(0.95)
                          : Colors.white.withOpacity(0.80),
                      Colors.white.withOpacity(_isHovered ? 0.90 : 0.70),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isGold
                        ? [
                            _isHovered
                                ? const Color(0xFFFBBF24)
                                : AppColors.pnlSignatureGold,
                            const Color(0xFFD97706),
                          ]
                        : [
                            _isHovered
                                ? const Color(0xFF2563EB)
                                : AppColors.pnlPrimary,
                            const Color(0xFF1E40AF),
                          ],
                  ),
            border: Border.all(
              color: widget.isSecondary
                  ? (_isHovered
                      ? primaryColor.withOpacity(0.40)
                      : AppColors.pnlPrimary.withOpacity(0.18))
                  : Colors.white.withOpacity(0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isSecondary
                        ? AppColors.pnlPrimary
                        : (_isHovered ? glowColor : primaryColor))
                    .withOpacity(_isHovered ? 0.30 : 0.15),
                blurRadius: _isHovered ? 22 : 10,
                spreadRadius: _isHovered ? 1 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSecondary
                      ? (_isHovered ? primaryColor : AppColors.pnlPrimary)
                      : Colors.white,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSecondary
                      ? (_isHovered ? primaryColor : AppColors.pnlPrimary)
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
