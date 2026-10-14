import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/liquid_glass.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isRegisteringEvent = false;
  String _companyFilter = '';

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
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Selamat! E-Tiket PNL Job Fair 2026 berhasil diterbitkan.',
                style: TextStyle(fontWeight: FontWeight.bold),
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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (user == null) {
      return Center(
        child: LiquidGlassCard(
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sesi telah berakhir atau belum login.'),
              const SizedBox(height: 16),
              LiquidButton(
                label: 'Kembali ke Login',
                onPressed: () => controller.setAuthMode(false),
              ),
            ],
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
      mobileCompact: 14,
      mobile: 18,
      tablet: 32,
      desktop: 48,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: paddingH,
        vertical: context.isMobile ? 16 : 24,
      ),
      child: ResponsiveCenterContainer(
        maxWidth: 1320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Navigation / Header
            _buildDashboardHeader(context, controller, user, isDesktop),

            SizedBox(height: context.isMobile ? 18 : 28),

            // Main Highlight Section: PNL Job Fair 2026
            _buildJobFairAgendaCard(context, controller, user, isDesktop),

            SizedBox(height: context.isMobile ? 24 : 36),

            // Company Directory & Booth Map Section
            _buildCompanyDirectory(context, controller, filteredCompanies, isDesktop),

            SizedBox(height: context.isMobile ? 24 : 36),

            // Event Rundown & Rules
            _buildEventRundownAndRules(isDesktop),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isDesktop,
  ) {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      borderRadius: 22,
      child: Row(
        children: [
          // Logo Resmi PNL
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlCyanGlow.withOpacity(0.35),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_pnl.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school_rounded, color: AppColors.pnlPrimary),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Avatar Pengguna
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.pnlPrimary, AppColors.pnlGold],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlPrimary.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.pnlPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.4)),
                      ),
                      child: Text(
                        user.category.shortLabel,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pnlCyanGlow,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${user.identityNumber} • ${user.major}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 12.5 : 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (isDesktop) ...[
            const IslandJurusanSpectrumBadge(),
            const SizedBox(width: 14),
            TextButton.icon(
              onPressed: () => controller.setPage(AppPage.landing),
              icon: const Icon(Icons.home_rounded, size: 18, color: AppColors.pnlCyanGlow),
              label: const Text('Portal CDC', style: TextStyle(color: AppColors.pnlCyanGlow)),
            ),
            const SizedBox(width: 12),
          ],

          IconButton(
            tooltip: 'Keluar dari Akun',
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.roseWarning, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildJobFairAgendaCard(
    BuildContext context,
    AppController controller,
    UserProfile user,
    bool isDesktop,
  ) {
    if (user.isRegisteredJobFair && user.ticketCode != null) {
      // TAMPILKAN E-TIKET DIGITAL LIQUID GLASS
      return _buildActiveTicketView(context, user, isDesktop);
    }

    // TAMPILKAN KARTU REGISTRASI EVENT JOB FAIR 2026
    return LiquidGlassCard(
      borderRadius: 28,
      padding: EdgeInsets.all(isDesktop ? 36 : 24),
      tintColor: AppColors.pnlPrimary,
      borderColor: AppColors.pnlGold.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pnlGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pnlGold.withOpacity(0.5)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.event_available_rounded, color: AppColors.pnlGoldLight, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AGENDA UTAMA CDC PNL 2026',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pnlGoldLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldVerified.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Kuota Terbuka',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldVerified,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'PNL Job Fair & Career Expo 2026',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Temu Akbar Karir Vokasi Politeknik Negeri Lhokseumawe. Wajib memiliki E-Tiket resmi dengan QR Code untuk akses masuk gerbang auditorium.',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12.5,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Event Specs
          Wrap(
            spacing: 20,
            runSpacing: 14,
            children: [
              _buildDetailItem(Icons.calendar_month_rounded, 'Jadwal Acara', 'Mei 2026'),
              _buildDetailItem(Icons.location_on_rounded, 'Lokasi Venue', 'Auditorium Utama PNL Bukitrata'),
              _buildDetailItem(Icons.apartment_rounded, 'Mitra Industri', '30+ Perusahaan BUMN & Swasta'),
            ],
          ),

          const SizedBox(height: 28),

          // Pilihan Sesi Masuk
          const Text(
            'Pilih Sesi Kunjungan Kehadiran:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildSessionChip(
                controller,
                label: 'Sesi Pagi (08:30 - 12:00 WIB)',
                isSelected: controller.selectedSession == 'Sesi Pagi (08:30 - 12:00 WIB)',
              ),
              _buildSessionChip(
                controller,
                label: 'Sesi Siang (13:30 - 17:00 WIB)',
                isSelected: controller.selectedSession == 'Sesi Siang (13:30 - 17:00 WIB)',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Tombol Konfirmasi Pendaftaran
          LiquidButton(
            label: 'Konfirmasi Pendaftaran & Terbitkan E-Tiket QR',
            icon: Icons.qr_code_2_rounded,
            isGold: true,
            isLoading: _isRegisteringEvent,
            onPressed: () => _handleRegisterJobFair(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTicketView(
    BuildContext context,
    UserProfile user,
    bool isDesktop,
  ) {
    final qrData = 'PNL-JOBFAIR-2026|${user.ticketCode}|${user.identityNumber}|${user.fullName}';

    return LiquidGlassCard(
      borderRadius: 28,
      padding: EdgeInsets.all(isDesktop ? 36 : 24),
      tintColor: AppColors.pnlPrimary,
      borderColor: AppColors.pnlCyanGlow.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.emeraldVerified.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.6)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_rounded, color: AppColors.emeraldVerified, size: 16),
                    SizedBox(width: 6),
                    Text(
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
              Text(
                'Tahun 2026',
                style: TextStyle(fontSize: 12, color: AppColors.pnlGoldLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Ticket Card Box (Liquid Hologram Aesthetic)
          Container(
            padding: EdgeInsets.all(isDesktop ? 28 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.pnlPrimary.withOpacity(0.06),
                  AppColors.jurusanSipil.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pnlPrimary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                // Info Section
                if (isDesktop)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.pnlGold, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.pnlGold.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo_pnl.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'POLITEKNIK NEGERI LHOKSEUMAWE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: AppColors.pnlGoldLight,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'PNL JOB FAIR 2026',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Ticket Code Box
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.pnlPrimary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.5)),
                              ),
                              child: Text(
                                user.ticketCode!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Salin Kode Tiket',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: user.ticketCode!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kode tiket disalin ke clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, color: AppColors.pnlCyanGlow, size: 18),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildTicketDetailRow('Nama Pemegang', user.fullName),
                        _buildTicketDetailRow('Kategori / Identitas', '${user.category.shortLabel} (${user.identityNumber})'),
                        _buildTicketDetailRow('Program Studi', user.major),
                        _buildTicketDetailRow('Sesi Terdaftar', user.sessionSlot ?? 'Sesi Pagi'),
                        _buildTicketDetailRow('Lokasi', 'Auditorium Utama Kampus PNL Bukitrata'),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppColors.pnlGold, width: 1.5),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo_pnl.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'POLITEKNIK NEGERI LHOKSEUMAWE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: AppColors.pnlGoldLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PNL JOB FAIR 2026',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.pnlPrimary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.pnlCyanGlow.withOpacity(0.5)),
                            ),
                            child: Text(
                              user.ticketCode!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: user.ticketCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kode tiket disalin!')),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, color: AppColors.pnlCyanGlow, size: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _buildTicketDetailRow('Nama', user.fullName),
                      _buildTicketDetailRow('Kategori', '${user.category.shortLabel} (${user.identityNumber})'),
                      _buildTicketDetailRow('Sesi', user.sessionSlot ?? 'Sesi Pagi'),
                    ],
                  ),

                SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 20),

                // QR Code Container
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: isDesktop ? 140.0 : 120.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan di Gerbang Masuk',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              LiquidButton(
                label: 'Unduh E-Tiket (PNG/PDF)',
                icon: Icons.download_rounded,
                isSecondary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('E-Tiket siap disimpan ke perangkat Anda!'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '💡 Tunjukkan kode QR ini langsung dari layar ponsel Anda kepada petugas Gate PNL di hari acara.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.pnlCyanGlow, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionChip(
    AppController controller, {
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.setSelectedSession(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pnlPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.pnlPrimary : AppColors.pnlPrimary.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pnlPrimary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 16,
              color: isSelected ? AppColors.pnlCyanGlow : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyDirectory(
    BuildContext context,
    AppController controller,
    List<CompanyMitra> companies,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direktori Perusahaan & Booth Job Fair 2026',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Cari posisi lowongan dan lokasi booth yang ingin Anda tuju di lokasi',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ],
            ),
            // Search Input
            if (isDesktop)
              SizedBox(
                width: 260,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _companyFilter = val),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Cari perusahaan atau sektor...',
                      hintStyle: TextStyle(color: AppColors.textDim, fontSize: 12),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.pnlPrimary, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 18),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: companies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.6 : 2.4,
          ),
          itemBuilder: (context, index) {
            final c = companies[index];
            return LiquidGlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.pnlPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.boothNumber,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pnlCyanGlow,
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
                  const SizedBox(height: 12),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.sector,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.pnlPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventRundownAndRules(bool isDesktop) {
    return LiquidGlassCard(
      borderRadius: 22,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.rule_rounded, color: AppColors.pnlPrimary, size: 20),
              SizedBox(width: 10),
              Text(
                'Tata Tertib & Panduan Pengunjung PNL Job Fair 2026',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '1. Berpakaian rapi, formal/soput, serta mengenakan sepatu.\n'
            '2. Menunjukkan E-Tiket QR Code aktif kepada petugas di pintu gerbang Auditorium Utama Kampus PNL.\n'
            '3. Menyiapkan softcopy CV (PDF) di smartphone bila sewaktu-waktu diminta oleh HRD mitra industri.\n'
            '4. Menjaga ketertiban, kebersihan, dan antrean di setiap booth perusahaan mitra.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
