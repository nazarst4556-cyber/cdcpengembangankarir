import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/app_models.dart';
import '../services/blockchain_service.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/scroll_reveal.dart';

// ══════════════════════════════════════════════════════════════════════════
// DASHBOARD PAGE — Premium Corporate Profile Dashboard
// Ultra-premium entrance animations inspired by Unilever / BCG / Indofood
// ══════════════════════════════════════════════════════════════════════════

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  bool _isRegisteringEvent = false;
  String _companyFilter = '';

  // ── ENTRANCE ANIMATION CONTROLLERS ─────────────────────────────────────
  late AnimationController _masterCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _orbitCtrl;

  // Staggered fade + slide anims
  late Animation<double> _navbarFade;
  late Animation<Offset> _navbarSlide;
  late Animation<double> _statsFade;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;

  @override
  void initState() {
    super.initState();

    // Master entrance: 1.8s staggered
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // Pulse for live dot
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Shimmer sweep
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Orbital ring
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // ── Staggered intervals ───────────────────────────────────────────────
    _navbarFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _navbarSlide = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutQuart),
    ));

    _statsFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.38, 0.68, curve: Curves.easeOutCubic),
    );

    _cardsFade = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.52, 0.85, curve: Curves.easeOutCubic),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.52, 0.85, curve: Curves.easeOutQuart),
    ));
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  void _handleRegisterJobFair(AppController controller) async {
    setState(() => _isRegisteringEvent = true);
    await Future.delayed(const Duration(milliseconds: 700));
    await controller.registerJobFair();
    if (mounted) {
      setState(() => _isRegisteringEvent = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.emeraldVerified,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selamat! E-Tiket PNL Job Fair 2026 berhasil diterbitkan.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser;
    final isDesktop = context.isDesktop || context.isUltraWide;
    final isTablet = context.isTablet;
    final isMobile = context.isMobile;

    if (user == null) {
      return Center(
        child: FadeTransition(
          opacity: _navbarFade,
          child: LiquidGlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 48, color: AppColors.pnlPrimary),
                const SizedBox(height: 16),
                const Text(
                  'Sesi telah berakhir atau belum login.',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                LiquidButton(
                  label: 'Kembali ke Login',
                  icon: Icons.login_rounded,
                  onPressed: () => controller.setAuthMode(false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredCompanies = controller.companies.where((c) {
      if (_companyFilter.isEmpty) return true;
      return c.name.toLowerCase().contains(_companyFilter.toLowerCase()) ||
          c.sector.toLowerCase().contains(_companyFilter.toLowerCase());
    }).toList();

    final paddingH = context.responsive<double>(
      mobileCompact: 12,
      mobile: 16,
      tablet: 28,
      desktop: 44,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ══ 1. PREMIUM PROFILE HERO HEADER ══════════════════════════════
          _buildPremiumHeroHeader(context, controller, user, isDesktop, isTablet, isMobile, paddingH),

          // ══ 2. STATS BAR ════════════════════════════════════════════════
          _buildStatsBar(context, controller, user, isDesktop, paddingH),

          SizedBox(height: isDesktop ? 32 : 22),

          // ══ 3. MAIN CONTENT ════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingH),
            child: ResponsiveCenterContainer(
              maxWidth: 1320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Job Fair Agenda / E-Ticket
                  FadeTransition(
                    opacity: _cardsFade,
                    child: SlideTransition(
                      position: _cardsSlide,
                      child: _buildJobFairAgendaCard(context, controller, user, isDesktop, isTablet),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 32 : 22),

                  // Company Directory
                  ScrollReveal(
                    slideOffset: 30,
                    delay: const Duration(milliseconds: 100),
                    child: _buildCompanyDirectory(context, controller, filteredCompanies, isDesktop, isTablet, isMobile),
                  ),

                  SizedBox(height: isDesktop ? 32 : 22),

                  // Rules & Rundown
                  ScrollReveal(
                    slideOffset: 25,
                    delay: const Duration(milliseconds: 80),
                    child: _buildEventRundownAndRules(isDesktop),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 1. PREMIUM PROFILE HERO HEADER
  // Full-width cinematic banner with orbital avatar ring & shimmer
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPremiumHeroHeader(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    double paddingH,
  ) {
    return SlideTransition(
      position: _navbarSlide,
      child: FadeTransition(
        opacity: _navbarFade,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF090D16),
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ── Background animated mesh ───────────────────────────────
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _orbitCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _DashboardMeshPainter(_orbitCtrl.value),
                    );
                  },
                ),
              ),

              // ── Shimmer overlay sweep ──────────────────────────────────
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (context, _) {
                    return ShaderMask(
                      blendMode: BlendMode.srcOver,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(-2.0 + _shimmerCtrl.value * 4, -1),
                        end: Alignment(-1.5 + _shimmerCtrl.value * 4, 1),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ).createShader(bounds),
                      child: Container(color: Colors.transparent),
                    );
                  },
                ),
              ),

              // ── Main hero content ──────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    paddingH,
                    isDesktop ? 36 : 24,
                    paddingH,
                    isDesktop ? 42 : 28,
                  ),
                  child: isDesktop
                      ? _buildDesktopHeroLayout(context, controller, user)
                      : _buildMobileHeroLayout(context, controller, user, isMobile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeroLayout(
    BuildContext context,
    AppController controller,
    UserProfile user,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // PNL logo
        _buildPNLLogoRing(size: 52),
        const SizedBox(width: 20),

        // Avatar with orbital ring & tap-to-edit
        _buildAvatarWithRing(context, controller, user, size: 72),
        const SizedBox(width: 24),

        // User identity block
        Expanded(child: _buildUserIdentityBlock(context, controller, user, isCompact: false)),

        const SizedBox(width: 24),

        // Navigation actions
        _buildNavActions(context, controller, user: user, isDesktop: true),
      ],
    );
  }

  Widget _buildMobileHeroLayout(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: logo + nav actions
        Row(
          children: [
            _buildPNLLogoRing(size: 42),
            const Spacer(),
            _buildNavActions(context, controller, user: user, isDesktop: false),
          ],
        ),
        const SizedBox(height: 20),
        // Avatar + identity
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarWithRing(context, controller, user, size: 62),
            const SizedBox(width: 16),
            Expanded(child: _buildUserIdentityBlock(context, controller, user, isCompact: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildPNLLogoRing({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.pnlSignatureGold.withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo_pnl.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(
              Icons.school_rounded,
              color: AppColors.pnlPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithRing(
    BuildContext context,
    AppController controller,
    UserProfile user, {
    required double size,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitCtrl, _pulseCtrl]),
      builder: (context, _) {
        return Tooltip(
          message: 'Klik untuk Ubah Data Profil',
          child: GestureDetector(
            onTap: () => _showEditProfileDialog(context, controller, user),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: size + 14,
                height: size + 14,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Orbital ring
                    Transform.rotate(
                      angle: _orbitCtrl.value * 2 * math.pi,
                      child: Container(
                        width: size + 14,
                        height: size + 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.pnlSignatureGold.withOpacity(0.0),
                              AppColors.pnlSignatureGold,
                              const Color(0xFF64748B),
                              AppColors.emeraldVerified,
                              AppColors.pnlSignatureGold.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Pulse aura
                    Container(
                      width: size + 6 + (_pulseCtrl.value * 6),
                      height: size + 6 + (_pulseCtrl.value * 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pnlSignatureGold
                            .withOpacity(0.12 * (1 - _pulseCtrl.value)),
                      ),
                    ),
                    // Avatar circle (Executive Charcoal Slate with Gold Border)
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                        border: Border.all(
                          color: AppColors.pnlSignatureGold.withOpacity(0.85),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pnlSignatureGold.withOpacity(0.25),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: size * 0.38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    // Quick edit mini badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.5),
                        decoration: BoxDecoration(
                          color: AppColors.pnlSignatureGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F172A), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 11,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserIdentityBlock(
    BuildContext context,
    AppController controller,
    UserProfile user, {
    required bool isCompact,
  }) {
    final Color categoryColor = _getCategoryColor(user.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting line
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) => Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emeraldVerified,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emeraldVerified.withOpacity(
                          0.3 + 0.5 * _pulseCtrl.value),
                      blurRadius: 6 + 4 * _pulseCtrl.value,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'PORTAL RESMI CDC / UPA. PKK',
              style: TextStyle(
                fontSize: isCompact ? 9 : 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Full name + edit button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                user.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isCompact ? 20 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditProfileDialog(context, controller, user),
              child: Tooltip(
                message: 'Ubah Data Profil',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: AppColors.pnlSignatureGold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Category badge + NIM
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: categoryColor.withOpacity(0.55)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getCategoryIcon(user.category),
                      size: 12, color: categoryColor),
                  const SizedBox(width: 5),
                  Text(
                    user.category.shortLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: categoryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Text(
                user.identityNumber,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          user.major,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isCompact ? 11 : 12.5,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavActions(
    BuildContext context,
    AppController controller, {
    required UserProfile user,
    required bool isDesktop,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop) ...[
          // Lintas 6 Jurusan Vokasi spectrum dots (unambiguous & prestigious)
          Tooltip(
            message: 'Mencakup 6 Jurusan PNL: Sipil, Mesin, Kimia, Tata Niaga, TIK, & Elektro',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'LINTAS 6 JURUSAN VOKASI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pnlSignatureGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...[ AppColors.jurusanSipil, AppColors.jurusanMesin, AppColors.jurusanKimia,
                      AppColors.jurusanTataNiaga, AppColors.jurusanTIK, AppColors.jurusanElektro,
                  ].map((c) => Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c,
                      boxShadow: [BoxShadow(color: c.withOpacity(0.7), blurRadius: 5)],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Edit Profil button
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, controller, user),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.pnlSignatureGold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pnlSignatureGold.withOpacity(0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.tune_rounded, size: 16, color: AppColors.pnlSignatureGold),
                    SizedBox(width: 7),
                    Text('Edit Profil',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Portal Admin button
          GestureDetector(
            onTap: () => controller.setPage(AppPage.admin),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.pnlPrimary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.pnlCyanGlow),
                    SizedBox(width: 7),
                    Text('Portal Admin',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Portal CDC button
          GestureDetector(
            onTap: () => controller.setPage(AppPage.landing),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.home_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 7),
                    Text('Portal CDC',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else ...[
          // Mobile Admin button
          GestureDetector(
            onTap: () => controller.setPage(AppPage.admin),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.pnlPrimary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.6)),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.pnlCyanGlow, size: 18),
              ),
            ),
          ),
          // Mobile Edit Profile button
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, controller, user),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.pnlSignatureGold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pnlSignatureGold.withOpacity(0.45)),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.pnlSignatureGold, size: 18),
              ),
            ),
          ),
          // Mobile Home button
          GestureDetector(
            onTap: () => controller.setPage(AppPage.landing),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.home_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
        // Logout
        GestureDetector(
          onTap: () => controller.logout(),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.roseWarning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.roseWarning.withOpacity(0.35)),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.roseWarning, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PROFILE SETTINGS MODAL DIALOG
  // Allows updating full name, NIM/NIK, major, category, email & phone
  // ════════════════════════════════════════════════════════════════════════
  void _showEditProfileDialog(
    BuildContext context,
    AppController controller,
    UserProfile user,
  ) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final idCtrl = TextEditingController(text: user.identityNumber);
    final majorCtrl = TextEditingController(text: user.major);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    UserCategory selectedCategory = user.category;
    bool isSaving = false;
    String? errorText;

    const popularMajors = [
      'D4 Teknologi Rekayasa Komputer Jaringan',
      'D4 Teknik Rekayasa Pengolahan Minyak & Gas',
      'D4 Rekayasa Pembangkit Energi',
      'D4 Manajemen Keuangan Perbankan',
      'D4 Teknik Perancangan Jalan & Jembatan',
      'D4 Teknik Rekayasa Manufaktur',
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Profil',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (dialogCtx, _, _) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 580,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header (Deep Executive Midnight Slate & Gold) ────
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 22, 18, 22),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF090D16),
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.pnlSignatureGold.withOpacity(0.18),
                                  border: Border.all(
                                    color: AppColors.pnlSignatureGold.withOpacity(0.55),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.manage_accounts_rounded,
                                  color: AppColors.pnlSignatureGold,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pengaturan Profil Peserta',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Perbarui identitas akademik & kontak resmi CDC PNL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(),
                                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        // ── Content Form ─────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (errorText != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.roseWarning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.roseWarning.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: AppColors.roseWarning, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorText!,
                                          style: const TextStyle(
                                            color: AppColors.roseWarning,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // 1. Nama Lengkap & Gelar
                              _buildProfileFieldLabel('Nama Lengkap & Gelar', Icons.person_outline_rounded),
                              const SizedBox(height: 6),
                              TextField(
                                controller: nameCtrl,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                decoration: _buildProfileInputDecoration('Contoh: Rizki Maulana, S.Tr.Kom'),
                              ),
                              const SizedBox(height: 16),

                              // 2. Kategori Peserta (Chips)
                              _buildProfileFieldLabel('Kategori Peserta', Icons.badge_outlined),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: UserCategory.values.map((cat) {
                                  final isSel = selectedCategory == cat;
                                  return ChoiceChip(
                                    label: Text(cat.label),
                                    selected: isSel,
                                    selectedColor: const Color(0xFF0F172A),
                                    backgroundColor: AppColors.bgCard,
                                    labelStyle: TextStyle(
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    side: BorderSide(
                                      color: isSel ? AppColors.pnlSignatureGold : Colors.black12,
                                      width: isSel ? 1.5 : 1,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onSelected: (val) {
                                      if (val) {
                                        setDialogState(() => selectedCategory = cat);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // 3. Nomor Identitas (NIM / NIK)
                              _buildProfileFieldLabel(
                                selectedCategory == UserCategory.umum ? 'Nomor Induk Kependudukan (NIK)' : 'Nomor Induk Mahasiswa (NIM)',
                                Icons.pin_outlined,
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: idCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                                decoration: _buildProfileInputDecoration('Contoh: 2105102044'),
                              ),
                              const SizedBox(height: 16),

                              // 4. Program Studi / Jurusan
                              _buildProfileFieldLabel('Program Studi / Jurusan', Icons.school_outlined),
                              const SizedBox(height: 6),
                              TextField(
                                controller: majorCtrl,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                                decoration: _buildProfileInputDecoration('Pilih atau ketik program studi...'),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pilihan Cepat Program Studi PNL:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: popularMajors.map((m) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      setDialogState(() {
                                        majorCtrl.text = m;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCard,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.black.withOpacity(0.08)),
                                      ),
                                      child: Text(
                                        m.replaceAll('D4 ', ''),
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // 5. Kontak (Email & Phone)
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildProfileFieldLabel('Email Resmi', Icons.mail_outline_rounded),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: emailCtrl,
                                          keyboardType: TextInputType.emailAddress,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                                          decoration: _buildProfileInputDecoration('email@pnl.ac.id'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildProfileFieldLabel('No. WhatsApp', Icons.phone_outlined),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: phoneCtrl,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                                          decoration: _buildProfileInputDecoration('0812...'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Footer Actions ───────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: isSaving ? null : () => Navigator.of(dialogCtx).pop(),
                                child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        final trimmedName = nameCtrl.text.trim();
                                        if (trimmedName.isEmpty) {
                                          setDialogState(() => errorText = 'Nama lengkap tidak boleh kosong');
                                          return;
                                        }

                                        setDialogState(() {
                                          isSaving = true;
                                          errorText = null;
                                        });

                                        await Future.delayed(const Duration(milliseconds: 300));
                                        await controller.updateProfile(
                                          fullName: trimmedName,
                                          identityNumber: idCtrl.text.trim(),
                                          major: majorCtrl.text.trim(),
                                          category: selectedCategory,
                                          email: emailCtrl.text.trim(),
                                          phone: phoneCtrl.text.trim(),
                                        );

                                        if (dialogCtx.mounted) {
                                          Navigator.of(dialogCtx).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(0xFF0F172A),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                side: BorderSide(color: AppColors.pnlSignatureGold.withOpacity(0.5)),
                                              ),
                                              content: Row(
                                                children: const [
                                                  Icon(Icons.check_circle_rounded, color: AppColors.pnlSignatureGold),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      'Profil berhasil diperbarui secara langsung!',
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: AppColors.pnlSignatureGold.withOpacity(0.6)),
                                  ),
                                  elevation: 2,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.check_rounded, size: 18, color: AppColors.pnlSignatureGold),
                                          SizedBox(width: 6),
                                          Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildProfileInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDim, fontWeight: FontWeight.normal),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: AppColors.bgLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 2. STATS BAR — Animated counters with glass morphism
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildStatsBar(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isDesktop,
    double paddingH,
  ) {
    final totalJobs = controller.companies.fold<int>(0, (sum, c) => sum + c.openPositions);
    final stats = [
      {
        'icon': Icons.business_center_rounded,
        'label': 'Perusahaan Mitra',
        'value': '${controller.companies.length}',
        'color': AppColors.pnlPrimary,
      },
      {
        'icon': Icons.work_outline_rounded,
        'label': 'Total Lowongan',
        'value': '$totalJobs',
        'color': AppColors.emeraldVerified,
      },
      {
        'icon': Icons.qr_code_rounded,
        'label': 'Status E-Tiket',
        'value': user.isRegisteredJobFair ? 'Aktif' : 'Belum',
        'color': user.isRegisteredJobFair
            ? AppColors.emeraldVerified
            : AppColors.pnlSignatureGold,
      },
      {
        'icon': Icons.event_rounded,
        'label': 'Hari Event',
        'value': 'Mei 2026',
        'color': AppColors.pnlSignatureGold,
      },
    ];

    return FadeTransition(
      opacity: _statsFade,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F172A),
              AppColors.bgLight,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: isDesktop ? 0 : 0,
          ),
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: ResponsiveCenterContainer(
              maxWidth: 1320,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: isDesktop ? 18 : 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.pnlPrimary.withOpacity(0.06),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.90),
                            Colors.white.withOpacity(0.80),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.95),
                          width: 1.2,
                        ),
                      ),
                      child: isDesktop
                          ? Row(
                              children: stats.asMap().entries.map((e) {
                                final i = e.key;
                                final s = e.value;
                                return Expanded(
                                  child: _buildStatItem(s, i, stats.length, isDesktop),
                                );
                              }).toList(),
                            )
                          : GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              children: stats.asMap().entries.map((e) {
                                return _buildStatItem(e.value, e.key, stats.length, false);
                              }).toList(),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    Map<String, dynamic> stat,
    int index,
    int total,
    bool isDesktop,
  ) {
    final color = stat['color'] as Color;
    final bool notLast = index < total - 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 14,
        vertical: isDesktop ? 14 : 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: notLast && isDesktop
              ? BorderSide(
                  color: AppColors.pnlPrimary.withOpacity(0.08), width: 1)
              : BorderSide.none,
          bottom: !isDesktop && index < 2
              ? BorderSide(
                  color: AppColors.pnlPrimary.withOpacity(0.08), width: 1)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat['value'] as String,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 17,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                stat['label'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 3. JOB FAIR AGENDA CARD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildJobFairAgendaCard(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    if (user.isRegisteredJobFair && user.ticketCode != null) {
      return _buildActiveTicketView(context, user, isDesktop, isTablet);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.pnlPrimary.withOpacity(0.12),
            blurRadius: 36,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 40 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.pnlGold.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Event badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.pnlSignatureGold.withOpacity(0.2),
                            AppColors.pnlGold.withOpacity(0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.pnlSignatureGold
                                .withOpacity(0.45)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, _) => Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.pnlSignatureGold,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.pnlSignatureGold
                                        .withOpacity(0.4 +
                                            0.5 * _pulseCtrl.value),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AGENDA UTAMA CDC PNL 2026',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.pnlSignatureGold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Kuota badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldVerified.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.emeraldVerified.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.people_outline_rounded,
                              size: 13,
                              color: AppColors.emeraldVerified),
                          SizedBox(width: 5),
                          Text(
                            'Kuota Terbuka',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emeraldVerified,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.pnlPrimary,
                      Color(0xFF1E40AF),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'PNL Job Fair & Career Expo 2026',
                    style: TextStyle(
                      fontSize: isDesktop ? 30 : 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temu Akbar Karir Vokasi Politeknik Negeri Lhokseumawe. '
                  'Wajib memiliki E-Tiket resmi dengan QR Code untuk akses masuk gerbang auditorium.',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12.5,
                    color: AppColors.textMuted,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 26),

                // Event detail pills
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    _buildEventPill(Icons.calendar_month_rounded,
                        'Mei 2026', AppColors.pnlPrimary),
                    _buildEventPill(Icons.location_on_rounded,
                        'Auditorium PNL Bukitrata', AppColors.jurusanKimia),
                    _buildEventPill(Icons.apartment_rounded,
                        '30+ Perusahaan BUMN & Swasta', AppColors.emeraldVerified),
                  ],
                ),

                const SizedBox(height: 28),

                // Session picker label
                const Text(
                  'Pilih Sesi Kunjungan Kehadiran:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _buildSessionChip(
                      controller,
                      label: 'Sesi Pagi (08:30 - 12:00 WIB)',
                      isSelected: controller.selectedSession ==
                          'Sesi Pagi (08:30 - 12:00 WIB)',
                      icon: Icons.wb_sunny_rounded,
                    ),
                    _buildSessionChip(
                      controller,
                      label: 'Sesi Siang (13:30 - 17:00 WIB)',
                      isSelected: controller.selectedSession ==
                          'Sesi Siang (13:30 - 17:00 WIB)',
                      icon: Icons.wb_twilight_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // CTA Button
                SizedBox(
                  width: isDesktop ? null : double.infinity,
                  child: LiquidButton(
                    label:
                        'Konfirmasi Pendaftaran & Terbitkan E-Tiket QR',
                    icon: Icons.qr_code_2_rounded,
                    isGold: true,
                    isLoading: _isRegisteringEvent,
                    onPressed: () => _handleRegisterJobFair(controller),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 4. E-TICKET VIEW — Premium holographic digital pass
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildActiveTicketView(
    BuildContext context,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    final qrData =
        'PNL-JOBFAIR-2026|${user.ticketCode}|${user.identityNumber}|${user.fullName}';

    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF090D16),
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: AppColors.pnlSignatureGold.withOpacity(0.12),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Mesh background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _orbitCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _DashboardMeshPainter(_orbitCtrl.value),
                ),
              ),
            ),
            // Shimmer effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, _) => ShaderMask(
                  blendMode: BlendMode.srcOver,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment(-2.5 + _shimmerCtrl.value * 5, -0.5),
                    end: Alignment(-2.0 + _shimmerCtrl.value * 5, 0.5),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ).createShader(bounds),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(isDesktop ? 40 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verified header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldVerified.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.emeraldVerified.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, _) => Icon(
                                Icons.verified_rounded,
                                color: AppColors.emeraldVerified,
                                size: 14 + _pulseCtrl.value * 1.5,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'E-TIKET TERVERIFIKASI RESMI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emeraldVerified,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Text(
                          'JOBFAIR 2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.pnlGoldLight,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Ticket body: responsive layout
                  if (isDesktop || isTablet)
                    _buildTicketBodyWide(context, user, qrData, isDesktop)
                  else
                    _buildTicketBodyMobile(context, user, qrData),

                  const SizedBox(height: 24),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.pnlGoldLight),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tunjukkan kode QR ini langsung dari layar ponsel Anda kepada petugas Gate PNL di hari acara.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.65),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Download, Audit, and Share buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTicketActionButton(
                        icon: Icons.download_rounded,
                        label: 'Unduh E-Tiket',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'E-Tiket siap disimpan ke perangkat Anda!'),
                            ),
                          );
                        },
                      ),
                      _buildTicketActionButton(
                        icon: Icons.shield_rounded,
                        label: 'Audit Blockchain (PoA)',
                        onTap: () => _showBlockchainAuditDialog(context, user),
                      ),
                      _buildTicketActionButton(
                        icon: Icons.share_rounded,
                        label: 'Bagikan',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketBodyWide(
    BuildContext context,
    UserProfile user,
    String qrData,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTicketInfo(user, isDesktop)),
          SizedBox(width: isDesktop ? 32 : 20),
          _buildQRBlock(context, user, qrData, isDesktop ? 160 : 130),
        ],
      ),
    );
  }

  Widget _buildTicketBodyMobile(
    BuildContext context,
    UserProfile user,
    String qrData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTicketInfo(user, false),
        const SizedBox(height: 20),
        Center(child: _buildQRBlock(context, user, qrData, 140)),
      ],
    );
  }

  Widget _buildTicketInfo(UserProfile user, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PNL header
        Row(
          children: [
            Container(
              width: isDesktop ? 42 : 36,
              height: isDesktop ? 42 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pnlSignatureGold.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/logo_pnl.jpg',
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POLITEKNIK NEGERI LHOKSEUMAWE',
                  style: TextStyle(
                    fontSize: isDesktop ? 10.5 : 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.pnlGoldLight,
                  ),
                ),
                Text(
                  'PNL JOB FAIR 2026',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Ticket code
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    AppColors.pnlPrimary.withOpacity(0.5),
                    const Color(0xFF1E40AF).withOpacity(0.4),
                  ],
                ),
                border: Border.all(
                    color: AppColors.pnlCyanGlow.withOpacity(0.5)),
              ),
              child: Text(
                user.ticketCode!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: user.ticketCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kode tiket disalin ke clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded,
                    color: AppColors.pnlCyanGlow, size: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Detail rows
        _buildTicketDetailRow('Nama Pemegang', user.fullName),
        _buildTicketDetailRow('Kategori',
            '${user.category.shortLabel} — ${user.identityNumber}'),
        _buildTicketDetailRow('Program Studi', user.major),
        _buildTicketDetailRow('Sesi Terdaftar', user.sessionSlot ?? 'Sesi Pagi'),
        _buildTicketDetailRow('Lokasi', 'Auditorium Utama Kampus PNL Bukitrata'),

        // Blockchain Proof Badge
        if (user.blockchainBlockHash != null || user.blockIndex != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.emeraldVerified, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BLOCKCHAIN PoA VERIFIED — BLOCK #${user.blockIndex ?? 1}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emeraldVerified,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hash: ${user.blockchainBlockHash != null && user.blockchainBlockHash!.length > 20 ? '${user.blockchainBlockHash!.substring(0, 14)}...${user.blockchainBlockHash!.substring(user.blockchainBlockHash!.length - 8)}' : (user.blockchainBlockHash ?? 'SHA-256 Secured')}',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQRBlock(
    BuildContext context,
    UserProfile user,
    String qrData,
    double size,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.pnlPrimary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.pnlSignatureGold.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF0A1628),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF0A1628),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.qr_code_scanner_rounded,
                  size: 13, color: AppColors.pnlGoldLight),
              SizedBox(width: 6),
              Text(
                'Scan di Gerbang Masuk',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.pnlGoldLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 138,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500),
            ),
          ),
          Text(': ',
              style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withOpacity(0.4))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BLOCKCHAIN AUDIT DIALOG (PoA Ledger Verification)
  // ════════════════════════════════════════════════════════════════════════
  void _showBlockchainAuditDialog(BuildContext context, UserProfile user) {
    BlockchainBlock? block;
    try {
      if (user.blockchainBlockHash != null) {
        block = BlockchainService.ledger.firstWhere(
          (b) => b.hash == user.blockchainBlockHash,
        );
      }
    } catch (_) {}

    final blockIndex = block?.index ?? user.blockIndex ?? 1;
    final blockHash = block?.hash ?? user.blockchainBlockHash ?? '0000a4f89d81e3a9b1c7209bfd192847c5d';
    final prevHash = block?.previousHash ?? '00000000000000000000000000000000';
    final merkleRoot = block?.merkleRoot ?? '3f9a7b2c1d8e4f5a6b7c8d9e0f1a2b3c';
    final signature = block?.proofSignature ?? 'ECDSA_PoA_PNL_ROOT_KEY_VERIFIED';
    final timestamp = block?.timestamp ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.emeraldVerified.withOpacity(0.25),
                blurRadius: 35,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldVerified.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.5)),
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppColors.emeraldVerified, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sertifikat Ledger Blockchain PoA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Konsensus Proof-of-Authority UPA. PKK PNL',
                          style: TextStyle(
                            color: AppColors.emeraldVerified.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildAuditRow('Status Blok', 'IMMUTABLE & AUDITED ON-CHAIN', isAccent: true),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Tinggi Blok (Height)', '#$blockIndex'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Waktu Konsensus', timestamp.toIso8601String()),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Hash SHA-256', blockHash, isMonospace: true),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Hash Sebelumnya (prevHash)', prevHash, isMonospace: true),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Merkle Root', merkleRoot, isMonospace: true),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAuditRow('Tanda Tangan PoA', signature, isMonospace: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: blockHash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hash blok berhasil disalin ke clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.pnlSignatureGold),
                    label: const Text('Salin Hash', style: TextStyle(color: AppColors.pnlSignatureGold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tutup Sertifikat'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditRow(String label, String value, {bool isMonospace = false, bool isAccent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMonospace ? 10.5 : 12,
              fontFamily: isMonospace ? 'monospace' : null,
              fontWeight: isAccent ? FontWeight.w800 : FontWeight.w600,
              color: isAccent ? AppColors.emeraldVerified : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 5. COMPANY DIRECTORY
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildCompanyDirectory(
    BuildContext context,
    AppController controller,
    List<CompanyMitra> companies,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.pnlPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'DIREKTORI MITRA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.pnlPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Direktori Perusahaan & Booth Job Fair 2026',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cari posisi lowongan dan lokasi booth yang ingin Anda tuju di lokasi',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isDesktop || isTablet)
              SizedBox(
                width: 260,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.pnlPrimary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) =>
                        setState(() => _companyFilter = val),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Cari perusahaan atau sektor...',
                      hintStyle: TextStyle(
                          color: AppColors.textDim, fontSize: 12),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: AppColors.pnlPrimary, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ),
          ],
        ),

        if (isMobile) ...[
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.pnlPrimary.withOpacity(0.15)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _companyFilter = val),
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Cari perusahaan atau sektor...',
                hintStyle:
                    TextStyle(color: AppColors.textDim, fontSize: 12),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.pnlPrimary, size: 18),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: companies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio:
                isDesktop ? 1.5 : (isTablet ? 1.4 : 1.9),
          ),
          itemBuilder: (context, index) {
            final c = companies[index];
            return _buildCompanyCard(c, isMobile);
          },
        ),
      ],
    );
  }

  Widget _buildCompanyCard(CompanyMitra c, bool isMobile) {
    final sectorColors = {
      'migas': AppColors.jurusanKimia,
      'petrokimia': AppColors.jurusanMesin,
      'perbankan': AppColors.pnlPrimary,
      'telekomunikasi': AppColors.jurusanTIK,
      'tambang': AppColors.jurusanTataNiaga,
    };
    Color accentColor = AppColors.pnlPrimary;
    for (final key in sectorColors.keys) {
      if (c.sector.toLowerCase().contains(key)) {
        accentColor = sectorColors[key]!;
        break;
      }
    }

    return LiquidGlassCard(
      borderRadius: 18,
      tintColor: accentColor,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: accentColor.withOpacity(0.25)),
                ),
                child: Text(
                  c.boothNumber,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldVerified.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${c.openPositions} Lowongan',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldVerified,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            c.sector,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 12, color: AppColors.pnlSignatureGold),
                  const SizedBox(width: 4),
                  const Text(
                    'Mitra PNL',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pnlSignatureGold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kunjungi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded,
                      size: 13, color: accentColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 6. EVENT RUNDOWN & RULES
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildEventRundownAndRules(bool isDesktop) {
    final rules = [
      {
        'icon': Icons.checkroom_rounded,
        'text':
            'Berpakaian rapi, formal/sopan, serta mengenakan sepatu.',
      },
      {
        'icon': Icons.qr_code_scanner_rounded,
        'text':
            'Menunjukkan E-Tiket QR Code aktif kepada petugas di pintu gerbang Auditorium Utama Kampus PNL.',
      },
      {
        'icon': Icons.picture_as_pdf_rounded,
        'text':
            'Menyiapkan softcopy CV (PDF) di smartphone bila sewaktu-waktu diminta oleh HRD mitra industri.',
      },
      {
        'icon': Icons.people_rounded,
        'text':
            'Menjaga ketertiban, kebersihan, dan antrean di setiap booth perusahaan mitra.',
      },
    ];

    return LiquidGlassCard(
      borderRadius: 22,
      padding: EdgeInsets.all(isDesktop ? 32 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.pnlPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rule_rounded,
                    color: AppColors.pnlPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tata Tertib & Panduan Pengunjung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'PNL Job Fair 2026 — Panduan Resmi Peserta',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...rules.asMap().entries.map((e) {
            final idx = e.key;
            final r = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.pnlPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(r['icon'] as IconData,
                          size: 14, color: AppColors.pnlPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${idx + 1}. ${r['text']}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSessionChip(
    AppController controller, {
    required String label,
    required bool isSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => controller.setSelectedSession(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.pnlSignatureGold
                : Colors.black12,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? AppColors.pnlSignatureGold
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(UserCategory cat) {
    switch (cat) {
      case UserCategory.mahasiswaPnl:
        return const Color(0xFF38BDF8); // Refined executive sky cyan
      case UserCategory.alumniPnl:
        return AppColors.emeraldVerified;
      case UserCategory.umum:
        return AppColors.jurusanTataNiaga;
    }
  }

  IconData _getCategoryIcon(UserCategory cat) {
    switch (cat) {
      case UserCategory.mahasiswaPnl:
        return Icons.school_rounded;
      case UserCategory.alumniPnl:
        return Icons.workspace_premium_rounded;
      case UserCategory.umum:
        return Icons.person_rounded;
    }
  }


}

// ══════════════════════════════════════════════════════════════════════════
// BACKGROUND MESH PAINTER — Corporate animated dot mesh
// ══════════════════════════════════════════════════════════════════════════
class _DashboardMeshPainter extends CustomPainter {
  final double t;
  _DashboardMeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.8;

    const step = 56.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final wobbleX = x + math.sin(t * 2 * math.pi + y * 0.02) * 6;
        final wobbleY = y + math.cos(t * 2 * math.pi + x * 0.02) * 4;
        canvas.drawCircle(Offset(wobbleX, wobbleY), 1.5, paint);
      }
    }

    // Diagonal lines
    for (double d = -size.height; d < size.width + size.height; d += 110) {
      final shift = math.sin(t * 2 * math.pi + d * 0.003) * 12;
      canvas.drawLine(
        Offset(d + shift, 0),
        Offset(d + size.height + shift, size.height),
        linePaint,
      );
    }

    // Glowing orbs
    final orbPaint = Paint()..style = PaintingStyle.fill;

    final List<Map<String, dynamic>> orbs = [
      {
        'x': size.width * 0.1 + math.sin(t * 2 * math.pi * 0.6) * 30,
        'y': size.height * 0.3 + math.cos(t * 2 * math.pi * 0.4) * 20,
        'r': 80.0,
        'color': AppColors.pnlSignatureGold.withOpacity(0.08),
      },
      {
        'x': size.width * 0.85 + math.cos(t * 2 * math.pi * 0.5) * 25,
        'y': size.height * 0.5 + math.sin(t * 2 * math.pi * 0.7) * 18,
        'r': 65.0,
        'color': const Color(0xFF38BDF8).withOpacity(0.06),
      },
      {
        'x': size.width * 0.5 + math.sin(t * 2 * math.pi * 0.35) * 35,
        'y': size.height * 0.8 + math.cos(t * 2 * math.pi * 0.55) * 15,
        'r': 50.0,
        'color': AppColors.emeraldVerified.withOpacity(0.07),
      },
    ];

    for (final orb in orbs) {
      orbPaint.shader = RadialGradient(
        colors: [
          orb['color'] as Color,
          (orb['color'] as Color).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(orb['x'] as double, orb['y'] as double),
        radius: orb['r'] as double,
      ));
      canvas.drawCircle(
        Offset(orb['x'] as double, orb['y'] as double),
        orb['r'] as double,
        orbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardMeshPainter oldDelegate) =>
      oldDelegate.t != t;
}
