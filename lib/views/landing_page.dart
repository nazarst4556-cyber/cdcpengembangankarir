import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/scroll_reveal.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late Timer _timer;
  Duration _timeUntilJobFair = const Duration(days: 42, hours: 14, minutes: 28, seconds: 15);

  // Section Keys for smooth anchor scrolling
  final _heroKey = GlobalKey();
  final _jobFairKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _companiesKey = GlobalKey();
  final _footerKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  // Entrance animations
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Pulse for seconds digit
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Company Search & Filter State
  String _selectedSector = 'Semua';
  String _searchQuery = '';

  // Selected Jurusan for interactive preview on mobile/tablet
  int _activeJurusanIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeUntilJobFair.inSeconds > 0) {
            _timeUntilJobFair = _timeUntilJobFair - const Duration(seconds: 1);
          }
        });
      }
    });

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Adaptive Floating Island Navbar
                  _buildNavbar(context, controller),

                  SizedBox(height: isMobile ? 12 : 24),

                  // Responsive Center Wrapper for wide displays (Desktop / Ultrawide)
                  ResponsiveCenterContainer(
                    maxWidth: 1320,
                    child: Column(
                      children: [
                        // 2. Hero Section with Scroll Reveal
                        ScrollReveal(
                          key: _heroKey,
                          slideOffset: 30.0,
                          child: _buildHeroSection(context, controller),
                        ),

                        SizedBox(height: isMobile ? 48 : (isTablet ? 64 : 80)),

                        // 3. PNL Job Fair 2026 Special Highlight — Holographic Boarding Pass
                        ScrollReveal(
                          key: _jobFairKey,
                          slideOffset: 45.0,
                          delay: const Duration(milliseconds: 60),
                          child: _buildJobFairHighlight(context, controller),
                        ),

                        SizedBox(height: isMobile ? 56 : (isTablet ? 72 : 90)),

                        // 4. 4 Pilar Layanan CDC / UPA. PKK — Bento Grid
                        ScrollReveal(
                          key: _servicesKey,
                          slideOffset: 35.0,
                          child: _buildServicesSection(context),
                        ),

                        SizedBox(height: isMobile ? 56 : (isTablet ? 72 : 90)),

                        // 5. Mitra Industri — Interactive Search & Filter Showcase
                        ScrollReveal(
                          key: _companiesKey,
                          slideOffset: 35.0,
                          child: _buildCompaniesSection(context, controller),
                        ),

                        SizedBox(height: isMobile ? 60 : (isTablet ? 80 : 100)),
                      ],
                    ),
                  ),

                  // 6. Responsive Footer with Scroll Reveal
                  ScrollReveal(
                    key: _footerKey,
                    slideOffset: 25.0,
                    child: _buildFooter(context),
                  ),

                  // Spacing for mobile floating bottom dock
                  if (isMobile) const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ),

        // 7. Mobile iOS Quick Navigation Floating Dock
        if (isMobile)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: _buildMobileBottomDock(context, controller),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. RESPONSIVE FLOATING ISLAND NAVBAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildNavbar(BuildContext context, AppController controller) {
    final isMobile = context.isMobile;
    final isMobileCompact = context.isMobileCompact;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 10,
      mobile: 14,
      tablet: 24,
      desktop: 44,
      ultraWide: 60,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 10 : 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobileCompact ? 12 : (isMobile ? 14 : 22),
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
              border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.pnlPrimary.withOpacity(0.06),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // ── BRAND IDENTITY ──────────────────────────────────
                InkWell(
                  onTap: () => _scrollTo(_heroKey),
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // PNL Logo with 6-Jurusan Sweep Gradient Ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: isMobile ? 40 : 48,
                            height: isMobile ? 40 : 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  AppColors.jurusanSipil,
                                  AppColors.jurusanMesin,
                                  AppColors.jurusanKimia,
                                  AppColors.jurusanTataNiaga,
                                  AppColors.jurusanTIK,
                                  AppColors.jurusanElektro,
                                  AppColors.pnlSignatureGold,
                                  AppColors.jurusanSipil,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: isMobile ? 35 : 42,
                            height: isMobile ? 35 : 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/logo_pnl.jpg',
                              width: isMobile ? 32 : 38,
                              height: isMobile ? 32 : 38,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.school_rounded,
                                size: isMobile ? 20 : 24,
                                color: AppColors.pnlPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: isMobile ? 8 : 12),

                      // Text Block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [AppColors.pnlPrimary, Color(0xFF1E40AF)],
                                ).createShader(bounds),
                                child: Text(
                                  isMobileCompact ? 'CDC PNL' : 'CDC / UPA. PKK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: isMobile ? 14 : 16.5,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.pnlSignatureGold, Color(0xFFD97706)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.pnlSignatureGold.withOpacity(0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'PNL',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isMobileCompact)
                            Text(
                              isMobile ? 'Politeknik Negeri Lhokseumawe' : 'Politeknik Negeri Lhokseumawe',
                              style: TextStyle(
                                fontSize: isMobile ? 9.5 : 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── DESKTOP NAVIGATION ANCHOR LINKS ────────────────
                if (isDesktop) ...[
                  const Spacer(),
                  _buildNavAnchor('Beranda', () => _scrollTo(_heroKey)),
                  _buildNavAnchor('Agenda 2026', () => _scrollTo(_jobFairKey)),
                  _buildNavAnchor('Layanan CDC', () => _scrollTo(_servicesKey)),
                  _buildNavAnchor('Mitra Industri', () => _scrollTo(_companiesKey)),
                  _buildNavAnchor('Kontak', () => _scrollTo(_footerKey)),
                  const SizedBox(width: 8),
                ] else
                  const Spacer(),

                // ── ACTIONS ─────────────────────────────────────────
                if (controller.isAuthenticated) ...[
                  LiquidButton(
                    label: isMobile ? 'Dashboard' : 'Buka Dashboard',
                    icon: Icons.dashboard_rounded,
                    onPressed: () => controller.setPage(AppPage.dashboard),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Keluar',
                    onPressed: () => controller.logout(),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.roseWarning, size: 18),
                  ),
                ] else ...[
                  // Desktop / Tablet: Masuk + Daftar buttons
                  if (isDesktop || isTablet) ...[
                    InkWell(
                      onTap: () => controller.setAuthMode(false),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.pnlPrimary.withOpacity(0.35),
                            width: 1.3,
                          ),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.pnlPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Daftar Button
                  InkWell(
                    onTap: () => controller.setAuthMode(true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: isMobile ? 9 : 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.pnlSignatureGold, Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pnlSignatureGold.withOpacity(0.38),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: isMobile ? 15 : 17),
                          const SizedBox(width: 6),
                          Text(
                            isDesktop ? 'Daftar Akun CDC' : 'Daftar',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: isMobile ? 12.5 : 13.5,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Mobile Menu Trigger Button
                  if (isMobile) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.pnlPrimary, size: 22),
                      tooltip: 'Navigasi Menu',
                      onPressed: () => _openMobileMenu(context, controller),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavAnchor(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _openMobileMenu(BuildContext context, AppController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Menu Navigasi CDC PNL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: AppColors.pnlPrimary),
                title: const Text('Beranda & 6 Jurusan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _scrollTo(_heroKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.stars_rounded, color: AppColors.pnlSignatureGold),
                title: const Text('Agenda PNL Job Fair 2026'),
                onTap: () {
                  Navigator.pop(ctx);
                  _scrollTo(_jobFairKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.work_rounded, color: AppColors.jurusanTIK),
                title: const Text('Pilar Layanan CDC / UPA. PKK'),
                onTap: () {
                  Navigator.pop(ctx);
                  _scrollTo(_servicesKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business_rounded, color: AppColors.emeraldVerified),
                title: const Text('Mitra Industri & Booth'),
                onTap: () {
                  Navigator.pop(ctx);
                  _scrollTo(_companiesKey);
                },
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pnlPrimary,
                        side: BorderSide(color: AppColors.pnlPrimary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.setAuthMode(false);
                      },
                      child: const Text('Masuk Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pnlPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.setAuthMode(true);
                      },
                      child: const Text('Daftar Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. HERO SECTION — Adaptive Typography & Unique Interactive 6-Jurusan
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSection(BuildContext context, AppController controller) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 14,
      mobile: 18,
      tablet: 32,
      desktop: 40,
    );

    // 6 Jurusan Resmi Politeknik Negeri Lhokseumawe
    final jurusan = [
      {
        'nama': 'Teknik Sipil',
        'singkat': 'T. Sipil',
        'sub': 'Infrastruktur & Konstruksi Hijau',
        'icon': Icons.foundation_rounded,
        'color': AppColors.jurusanSipil,
      },
      {
        'nama': 'Teknik Mesin',
        'singkat': 'T. Mesin',
        'sub': 'Manufaktur, Alat Berat & Energi',
        'icon': Icons.settings_rounded,
        'color': AppColors.jurusanMesin,
      },
      {
        'nama': 'Teknik Kimia',
        'singkat': 'T. Kimia',
        'sub': 'Pengolahan Migas & Petrokimia',
        'icon': Icons.science_rounded,
        'color': AppColors.jurusanKimia,
      },
      {
        'nama': 'Tata Niaga',
        'singkat': 'Tata Niaga',
        'sub': 'Akuntansi, Perbankan & Logistik',
        'icon': Icons.storefront_rounded,
        'color': AppColors.jurusanTataNiaga,
      },
      {
        'nama': 'Teknik Informasi & Komputer',
        'singkat': 'TIK',
        'sub': 'Software, Cyber & Cloud Tech',
        'icon': Icons.computer_rounded,
        'color': AppColors.jurusanTIK,
      },
      {
        'nama': 'Teknik Elektro',
        'singkat': 'T. Elektro',
        'sub': 'Ketenagalistrikan & Otomasi',
        'icon': Icons.bolt_rounded,
        'color': AppColors.jurusanElektro,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // ── LIVE STATUS CAPSLOCK BADGE ────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 18,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlPrimary.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emeraldVerified,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emeraldVerified.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PORTAL RESMI KARIR & KEWIRAUSAHAAN — PNL',
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.pnlPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 18 : 28),

          // ── PNL SEAL WITH AURA ─────────────────────────────────────
          Container(
            width: isMobile ? 74 : (isTablet ? 88 : 96),
            height: isMobile ? 74 : (isTablet ? 88 : 96),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlGold.withOpacity(0.35),
                  blurRadius: 30,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppColors.pnlPrimary.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_pnl.jpg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school_rounded,
                  size: 44,
                  color: AppColors.pnlPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Selamat Datang di CDC / UPA. PKK',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),

          // ── STAGGERED HEADLINE (Device Adaptive Sizing) ────────────
          _PremiumHeadline(
            entranceCtrl: _entranceCtrl,
          ),

          const SizedBox(height: 18),

          // ── SUBTITLE TEXT ──────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Unit Penunjang Akademik Pengembangan Karir & Kewirausahaan hadir sebagai akselerator kesiapan kerja, inkubator bisnis vokasi, dan jembatan resmi lulusan PNL ke industri nasional & global.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: isMobile ? 26 : 36),

          // ── CTA BUTTONS ────────────────────────────────────────────
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LiquidButton(
                      label: 'Daftar Akun CDC Sekarang',
                      icon: Icons.rocket_launch_rounded,
                      isGold: true,
                      onPressed: () => controller.setAuthMode(true),
                    ),
                    const SizedBox(height: 12),
                    LiquidButton(
                      label: 'Pelajari Agenda Job Fair 2026',
                      icon: Icons.calendar_month_rounded,
                      isSecondary: true,
                      onPressed: () => _scrollTo(_jobFairKey),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    LiquidButton(
                      label: 'Daftar Akun CDC Sekarang',
                      icon: Icons.rocket_launch_rounded,
                      isGold: true,
                      onPressed: () => controller.setAuthMode(true),
                    ),
                    LiquidButton(
                      label: 'Pelajari Agenda Job Fair 2026',
                      icon: Icons.calendar_month_rounded,
                      isSecondary: true,
                      onPressed: () => _scrollTo(_jobFairKey),
                    ),
                  ],
                ),

          SizedBox(height: isMobile ? 36 : 54),

          // ── 6 JURUSAN PNL UNIQUE INTERACTIVE SECTION ──────────────
          _buildJurusanMatrix(context, jurusan, isMobile, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildJurusanMatrix(
    BuildContext context,
    List<Map<String, dynamic>> jurusan,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.pnlPrimary.withOpacity(0.04),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pnlSignatureGold, AppColors.pnlPrimary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '6 JURUSAN RESMI POLITEKNIK NEGERI LHOKSEUMAWE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 9.5 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pnlPrimary, AppColors.pnlSignatureGold],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Desktop: 6-column panoramic row
          if (isDesktop)
            Row(
              children: jurusan.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _buildJurusanCard(item, isActive: _activeJurusanIndex == idx, onHover: () {
                      setState(() => _activeJurusanIndex = idx);
                    }),
                  ),
                );
              }).toList(),
            )
          // Tablet: 3x2 Grid
          else if (isTablet)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jurusan.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, idx) {
                return _buildJurusanCard(
                  jurusan[idx],
                  compact: true,
                  isActive: _activeJurusanIndex == idx,
                  onHover: () => setState(() => _activeJurusanIndex = idx),
                );
              },
            )
          // Mobile: Interactive 3x2 Grid Chips with selected details
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jurusan.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, idx) {
                    final item = jurusan[idx];
                    final isSel = _activeJurusanIndex == idx;
                    final color = item['color'] as Color;

                    return InkWell(
                      onTap: () => setState(() => _activeJurusanIndex = idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? color.withOpacity(0.16) : color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? color : color.withOpacity(0.22),
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(item['icon'] as IconData, color: color, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['singkat'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Active Department Spotlight Pill
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (jurusan[_activeJurusanIndex]['color'] as Color).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (jurusan[_activeJurusanIndex]['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        jurusan[_activeJurusanIndex]['icon'] as IconData,
                        color: jurusan[_activeJurusanIndex]['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jurusan[_activeJurusanIndex]['nama'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: jurusan[_activeJurusanIndex]['color'] as Color,
                              ),
                            ),
                            Text(
                              jurusan[_activeJurusanIndex]['sub'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildJurusanCard(
    Map<String, dynamic> j, {
    bool compact = false,
    bool isActive = false,
    VoidCallback? onHover,
  }) {
    final color = j['color'] as Color;
    final icon = j['icon'] as IconData;

    return MouseRegion(
      onEnter: (_) => onHover?.call(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 12,
          vertical: compact ? 10 : 16,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.22),
            width: isActive ? 1.6 : 1.1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: compact
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.14),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j['singkat'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          j['sub'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    j['nama'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    j['sub'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. PNL JOB FAIR 2026 SPECIAL HIGHLIGHT — Holographic Boarding Pass
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildJobFairHighlight(BuildContext context, AppController controller) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final days = _timeUntilJobFair.inDays;
    final hours = _timeUntilJobFair.inHours % 24;
    final minutes = _timeUntilJobFair.inMinutes % 60;
    final seconds = _timeUntilJobFair.inSeconds % 60;

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 14,
      mobile: 18,
      tablet: 32,
      desktop: 40,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: LiquidGlassCard(
        padding: EdgeInsets.all(isMobile ? 18 : (isTablet ? 30 : 40)),
        borderRadius: 28,
        tintColor: AppColors.pnlPrimary,
        borderColor: AppColors.pnlGold.withOpacity(0.4),
        customShadows: [
          BoxShadow(
            color: AppColors.pnlGold.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badges Row
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Gold Star Agenda Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.pnlSignatureGold, Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pnlSignatureGold.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'AGENDA KHUSUS TAHUN 2026',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pendaftaran Terbuka
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldVerified.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emeraldVerified,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Pendaftaran E-Tiket Dibuka',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldVerified,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Headline
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.textPrimary, AppColors.pnlPrimary],
              ).createShader(bounds),
              child: Text(
                'PNL JOB FAIR & CAREER EXPO 2026',
                style: TextStyle(
                  fontSize: isMobile ? 22 : (isTablet ? 30 : 36),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Temu Akbar Talenta Vokasi Politeknik Negeri Lhokseumawe dengan 30+ Perusahaan Mitra Nasional & Multinasional.',
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ── COUNTDOWN TIMER (Responsive & Auto-fit) ────────────────
            _buildResponsiveCountdown(days, hours, minutes, seconds, isMobile, isTablet, isDesktop),

            const SizedBox(height: 24),

            // ── EVENT SPECS (Date, Location, Ticket Access) ────────────
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildEventSpecBadge(
                          Icons.calendar_today_rounded,
                          'Waktu Pelaksanaan',
                          'Mei 2026 (08:30 - 17:00 WIB)',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildEventSpecBadge(
                          Icons.location_on_rounded,
                          'Lokasi Acara',
                          'Auditorium Utama Kampus PNL',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildEventSpecBadge(
                          Icons.confirmation_number_rounded,
                          'Akses Masuk',
                          'Wajib E-Tiket QR Code CDC',
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _buildEventSpecBadge(
                        Icons.calendar_today_rounded,
                        'Waktu Pelaksanaan',
                        'Mei 2026 (08:30 - 17:00 WIB)',
                      ),
                      _buildEventSpecBadge(
                        Icons.location_on_rounded,
                        'Lokasi Acara',
                        'Auditorium Utama PNL Bukitrata',
                      ),
                      _buildEventSpecBadge(
                        Icons.confirmation_number_rounded,
                        'Akses Masuk',
                        'Wajib E-Tiket QR Code CDC',
                      ),
                    ],
                  ),

            const SizedBox(height: 26),

            // ── ACTION CALLOUT / TICKET SIMULATION STRIP ─────────────
            Container(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.pnlPrimary.withOpacity(0.06),
                    AppColors.pnlSignatureGold.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.18)),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.pnlPrimary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.qr_code_2_rounded, color: AppColors.pnlPrimary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'E-Tiket resmi diterbitkan otomatis setelah Anda mendaftar akun CDC.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LiquidButton(
                          label: controller.isAuthenticated ? 'Klaim di Dashboard' : 'Daftar & Klaim E-Tiket',
                          icon: Icons.confirmation_number_rounded,
                          isGold: true,
                          onPressed: () {
                            if (controller.isAuthenticated) {
                              controller.setPage(AppPage.dashboard);
                            } else {
                              controller.setAuthMode(true);
                            }
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.pnlPrimary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: AppColors.pnlPrimary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Akses E-Tiket Masuk Job Fair 2026',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Daftar akun CDC Anda sekarang untuk reservasi slot kehadiran & cetak E-Tiket dengan barcode resmi.',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        LiquidButton(
                          label: controller.isAuthenticated ? 'Klaim di Dashboard' : 'Daftar & Klaim Tiket',
                          icon: Icons.confirmation_number_rounded,
                          isGold: true,
                          onPressed: () {
                            if (controller.isAuthenticated) {
                              controller.setPage(AppPage.dashboard);
                            } else {
                              controller.setAuthMode(true);
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveCountdown(
    int days,
    int hours,
    int minutes,
    int seconds,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 14 : 20,
        horizontal: isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.pnlPrimary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimerUnit('$days', 'HARI', isMobile),
          _buildTimerDivider(isMobile),
          _buildTimerUnit('$hours'.padLeft(2, '0'), 'JAM', isMobile),
          _buildTimerDivider(isMobile),
          _buildTimerUnit('$minutes'.padLeft(2, '0'), 'MENIT', isMobile),
          _buildTimerDivider(isMobile),
          _buildTimerUnit('$seconds'.padLeft(2, '0'), 'DETIK', isMobile, pulse: true),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(String value, String label, bool isMobile, {bool pulse = false}) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pulse
              ? ScaleTransition(
                  scale: _pulseAnim,
                  child: _timerNumber(value, isMobile, pulse: true),
                )
              : _timerNumber(value, isMobile, pulse: false),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.pnlPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 8 : 10,
                fontWeight: FontWeight.w800,
                color: AppColors.pnlPrimary,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerNumber(String value, bool isMobile, {required bool pulse}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: pulse
              ? [AppColors.jurusanKimia, AppColors.pnlSignatureGold]
              : [AppColors.pnlPrimary, AppColors.pnlSignatureGold],
        ).createShader(bounds),
        child: Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 24 : 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDivider(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 14 : 18),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: isMobile ? 18 : 26,
          fontWeight: FontWeight.w900,
          color: AppColors.pnlPrimary.withOpacity(0.40),
        ),
      ),
    );
  }

  Widget _buildEventSpecBadge(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pnlPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.pnlPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. 4 PILAR LAYANAN CDC / UPA. PKK — Responsive Bento Grid with ScrollReveal
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildServicesSection(BuildContext context) {
    final isMobile = context.isMobile;
    final isMobileCompact = context.isMobileCompact;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final services = [
      {
        'title': 'Bursa Kerja & Rekrutmen',
        'desc': 'Fasilitasi lowongan kerja resmi, walk-in interview, dan rekrutmen kampus bersama mitra industri.',
        'icon': Icons.business_center_rounded,
        'color': AppColors.pnlPrimary,
      },
      {
        'title': 'Inkubator Wirausaha Mahasiswa',
        'desc': 'Bimbingan bisnis rintisan, pendanaan inkubasi, dan pameran produk inovasi mahasiswa PNL.',
        'icon': Icons.lightbulb_rounded,
        'color': AppColors.pnlGold,
      },
      {
        'title': 'Konseling & Sertifikasi Karir',
        'desc': 'Review CV profesional, simulasi interview kerja, dan pemetaan keahlian kompetensi vokasi.',
        'icon': Icons.psychology_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Kemitraan Strategis DUDI',
        'desc': 'Kolaborasi kurikulum vokasi bersama BUMN, multinasional, dan asosiasi industri di Aceh & Nasional.',
        'icon': Icons.handshake_rounded,
        'color': AppColors.emeraldVerified,
      },
    ];

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 14,
      mobile: 18,
      tablet: 32,
      desktop: 40,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Column(
            children: [
              Text(
                'Pilar Layanan CDC / UPA. PKK PNL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 22 : (isTablet ? 26 : 30),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: const Text(
                  'Layanan komprehensif untuk memastikan lulusan Politeknik Negeri Lhokseumawe berdaya saing tinggi dan siap kerja di kancah nasional maupun global.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 24 : 36),

          // Responsive Bento Grid Layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              mainAxisSpacing: isMobile ? 12 : 20,
              crossAxisSpacing: isMobile ? 12 : 20,
              childAspectRatio: isDesktop ? 0.98 : (isTablet ? 1.35 : (isMobileCompact ? 1.65 : 1.9)),
            ),
            itemBuilder: (context, index) {
              final item = services[index];
              final color = item['color'] as Color;

              return LiquidGlassCard(
                borderRadius: 20,
                tintColor: color,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item['icon'] as IconData, color: color, size: isMobile ? 22 : 26),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 14.5 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        item['desc'] as String,
                        maxLines: isDesktop ? 4 : (isMobile ? 3 : 4),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Lihat Program',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. MITRA PERUSAHAAN INDUSTRI — Real-Time Search & Category Filter
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCompaniesSection(BuildContext context, AppController controller) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    final allCompanies = controller.companies;

    // Filter by sector and query
    final filtered = allCompanies.where((c) {
      final matchSector = _selectedSector == 'Semua' ||
          c.sector.toLowerCase().contains(_selectedSector.toLowerCase()) ||
          c.name.toLowerCase().contains(_selectedSector.toLowerCase());

      final matchQuery = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.sector.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.boothNumber.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchSector && matchQuery;
    }).toList();

    final sectors = ['Semua', 'Migas', 'Petrokimia', 'Perbankan', 'Telekomunikasi', 'Tambang'];

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 14,
      mobile: 18,
      tablet: 32,
      desktop: 40,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // Header with counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perusahaan Mitra Industri',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : (isTablet ? 24 : 28),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Eksibitor resmi yang siap merekrut di PNL Job Fair 2026',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pnlPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.2)),
                ),
                child: Text(
                  '${allCompanies.length} Mitra Terdaftar',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pnlPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Search & Filter Bar
          Column(
            children: [
              // Search Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search_rounded, color: AppColors.pnlPrimary, size: 20),
                    hintText: 'Cari perusahaan, booth, atau sektor karir...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textDim),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: sectors.map((sec) {
                    final isSel = _selectedSector == sec;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(sec),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedSector = sec),
                        selectedColor: AppColors.pnlPrimary,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textMuted,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(
                          color: isSel ? AppColors.pnlPrimary : AppColors.pnlPrimary.withOpacity(0.15),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Companies Grid
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Tidak ada perusahaan yang cocok dengan pencarian.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: isDesktop ? 1.42 : (isTablet ? 1.35 : (context.isMobileCompact ? 1.55 : 1.75)),
              ),
              itemBuilder: (context, index) {
                final c = filtered[index];
                return _buildCompanyCard(c, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyMitra c, bool isMobile) {
    return LiquidGlassCard(
      borderRadius: 18,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.pnlPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.2)),
                ),
                child: Text(
                  c.boothNumber,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pnlPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldVerified.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${c.openPositions} Posisi',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldVerified,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.sector,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.pnlPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pnlSignatureGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 12, color: AppColors.pnlSignatureGold),
                    SizedBox(width: 4),
                    Text(
                      'Mitra PNL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pnlSignatureGold,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kunjungi Booth',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pnlPrimary,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.pnlPrimary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. RESPONSIVE FOOTER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFooter(BuildContext context) {
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;

    final horizontalPadding = context.responsive<double>(
      mobileCompact: 16,
      mobile: 20,
      tablet: 36,
      desktop: 60,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 30 : 44,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: Border(
          top: BorderSide(color: AppColors.pnlPrimary.withOpacity(0.10)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campus Info
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Unit Penunjang Akademik (UPA) Pengembangan Karir & Kewirausahaan',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Politeknik Negeri Lhokseumawe (PNL)',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.pnlPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Jl. Banda Aceh - Medan Km. 280.3, Bukitrata, Mesjid Punteut, Blang Mangat, Kota Lhokseumawe, Aceh 24301',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Contact
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Kontak Layanan CDC PNL:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                          ),
                          SizedBox(height: 6),
                          Text('cdc@pnl.ac.id | info@pnl.ac.id',
                              style: TextStyle(fontSize: 13, color: AppColors.pnlPrimary, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('+62 645 42785 / +62 812-6900-XXXX',
                              style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Unit Penunjang Akademik (UPA) Pengembangan Karir & Kewirausahaan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Politeknik Negeri Lhokseumawe (PNL)',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.pnlPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jl. Banda Aceh - Medan Km. 280.3, Bukitrata, Lhokseumawe, Aceh 24301',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.5),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Email: cdc@pnl.ac.id | Hotline: +62 645 42785',
                      style: TextStyle(fontSize: 11.5, color: AppColors.pnlPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              Divider(color: AppColors.pnlPrimary.withOpacity(0.08)),
              const SizedBox(height: 14),

              Text(
                '© 2026 UPA. PKK / Career Development Center Politeknik Negeri Lhokseumawe. Seluruh Hak Cipta Dilindungi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. MOBILE FLOATING DOCK (Apple iOS Style Bottom Bar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileBottomDock(BuildContext context, AppController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.pnlPrimary.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockItem(Icons.home_rounded, 'Beranda', () => _scrollTo(_heroKey)),
          _buildDockItem(Icons.stars_rounded, 'Job Fair', () => _scrollTo(_jobFairKey)),
          _buildDockItem(Icons.business_rounded, 'Mitra', () => _scrollTo(_companiesKey)),
          InkWell(
            onTap: () {
              if (controller.isAuthenticated) {
                controller.setPage(AppPage.dashboard);
              } else {
                controller.setAuthMode(true);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pnlSignatureGold, Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pnlSignatureGold.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isAuthenticated ? Icons.dashboard_rounded : Icons.confirmation_number_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    controller.isAuthenticated ? 'Dashboard' : 'E-Tiket',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.pnlPrimary, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _PremiumHeadline — Staggered Word Reveal with Device-Adaptive Sizing
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumHeadline extends StatefulWidget {
  final AnimationController entranceCtrl;

  const _PremiumHeadline({
    required this.entranceCtrl,
  });

  @override
  State<_PremiumHeadline> createState() => _PremiumHeadlineState();
}

class _PremiumHeadlineState extends State<_PremiumHeadline> with TickerProviderStateMixin {
  late List<AnimationController> _wordCtrls;
  late List<Animation<double>> _wordFades;
  late List<Animation<Offset>> _wordSlides;

  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  static const _line1 = ['Koneksikan', 'Masa', 'Depan'];
  static const _line2 = ['Karir', 'Vokasi', 'Anda'];

  @override
  void initState() {
    super.initState();
    final allWords = [..._line1, ..._line2];
    _wordCtrls = List.generate(allWords.length, (i) {
      return AnimationController(vsync: this, duration: const Duration(milliseconds: 540));
    });
    _wordFades = _wordCtrls.map<Animation<double>>((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
    _wordSlides = _wordCtrls
        .map<Animation<Offset>>((c) => Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    for (int i = 0; i < _wordCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 180 + i * 90), () {
        if (mounted) _wordCtrls[i].forward();
      });
    }

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _shimmerCtrl.repeat();
    });
    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut);

    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _lineCtrl.forward();
    });
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOutExpo);
  }

  @override
  void dispose() {
    for (final c in _wordCtrls) {
      c.dispose();
    }
    _shimmerCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  Widget _buildWord(BuildContext context, String word, int index, {bool isAccent = false}) {
    final fs = context.responsive<double>(
      mobileCompact: isAccent ? 23.0 : 21.0,
      mobile: isAccent ? 27.0 : 25.0,
      tablet: isAccent ? 38.0 : 35.0,
      desktop: isAccent ? 48.0 : 45.0,
      ultraWide: isAccent ? 54.0 : 50.0,
    );

    return FadeTransition(
      opacity: _wordFades[index],
      child: SlideTransition(
        position: _wordSlides[index],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 2.5 : 4),
          child: isAccent
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.pnlPrimary, Color(0xFF4F46E5), AppColors.pnlSignatureGold],
                  ).createShader(bounds),
                  child: Text(
                    word,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: fs,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                )
              : Text(
                  word,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: fs,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.6,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;

    return Column(
      children: [
        const SizedBox(height: 10),
        Wrap(alignment: WrapAlignment.center, children: [
          _buildWord(context, 'Koneksikan', 0),
          _buildWord(context, 'Masa', 1),
          _buildWord(context, 'Depan', 2),
        ]),
        Wrap(alignment: WrapAlignment.center, children: [
          _buildWord(context, 'Karir', 3),
          _buildWord(context, 'Vokasi', 4),
          _buildWord(context, 'Anda', 5, isAccent: true),
        ]),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _lineAnim,
          builder: (_, child) => ClipRect(
            child: Align(
              widthFactor: _lineAnim.value,
              alignment: Alignment.center,
              child: Container(
                height: 3,
                width: isMobile ? 180 : (isDesktop ? 360 : 260),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pnlPrimary, Color(0xFF6366F1), AppColors.pnlSignatureGold],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pnlPrimary.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (_, child) {
            final s = _shimmerAnim.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 22,
                vertical: isMobile ? 7 : 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.pnlSignatureGold.withOpacity(0.50),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pnlPrimary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.pnlSignatureGold.withOpacity(0.18),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.pnlSignatureGold.withOpacity(0.25),
                          AppColors.pnlSignatureGold.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.pnlSignatureGold.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: isMobile ? 14 : 18,
                      color: AppColors.pnlSignatureGold,
                    ),
                  ),
                  SizedBox(width: isMobile ? 7 : 10),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [
                        (s - 0.35).clamp(0.0, 1.0),
                        s.clamp(0.0, 1.0),
                        (s + 0.35).clamp(0.0, 1.0),
                      ],
                      colors: const [
                        AppColors.pnlPrimary,
                        AppColors.pnlSignatureGold,
                        AppColors.pnlPrimary,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Politeknik Negeri Lhokseumawe',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isMobile ? 13 : (isDesktop ? 19 : 16),
                        fontWeight: FontWeight.w800,
                        color: AppColors.pnlPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
