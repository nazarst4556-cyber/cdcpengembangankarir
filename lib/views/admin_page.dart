import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/blockchain_service.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedTab = 0; // 0: Mitra, 1: Akun Pengguna, 2: Peserta Job Fair, 3: Blockchain
  String _companySearch = '';
  String _userSearch = '';
  UserCategory? _selectedCategoryFilter;
  String _attendeeSearch = '';
  String _selectedAttendanceFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).fetchAdminMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final isDesktop = context.isDesktop || context.isUltraWide;
    final paddingH = context.responsive<double>(mobile: 16, tablet: 24, desktop: 40);

    final filteredCompanies = controller.companies.where((c) {
      if (_companySearch.isEmpty) return true;
      final q = _companySearch.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.sector.toLowerCase().contains(q) ||
          c.boothNumber.toLowerCase().contains(q);
    }).toList();

    final totalJobs = controller.companies.fold<int>(
      0,
      (sum, item) => sum + item.openPositions,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Top Executive Admin Bar ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
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
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 28),
                  child: Column(
                    children: [
                      // Nav row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.pnlSignatureGold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.pnlSignatureGold.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.security_rounded,
                                    color: AppColors.pnlSignatureGold, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'ADMIN CONTROL CENTER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.pnlSignatureGold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Live Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldVerified.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.emeraldVerified.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.emeraldVerified,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'SUPABASE REAL-TIME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emeraldVerified,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Back to Portal
                          OutlinedButton.icon(
                            onPressed: () => controller.setPage(AppPage.landing),
                            icon: const Icon(Icons.arrow_back_rounded, size: 15, color: Colors.white),
                            label: const Text('Ke Portal', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.25)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Title & Subtitle
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CDC PNL Operations & Analytics',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 26 : 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pemantauan registrasi peserta, immutable ledger blockchain, dan direktori perusahaan mitra.',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 13 : 11.5,
                                    color: Colors.white.withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDesktop) ...[
                            ElevatedButton.icon(
                              onPressed: () => _showAddCompanyDialog(context, controller),
                              icon: const Icon(Icons.add_business_rounded, size: 16),
                              label: const Text('Tambah Perusahaan', style: TextStyle(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pnlSignatureGold,
                                foregroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Live Metrics Row ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingH),
                child: ResponsiveCenterContainer(
                  maxWidth: 1320,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth >= 900
                          ? 4
                          : (constraints.maxWidth >= 550 ? 2 : 1);
                      final width = (constraints.maxWidth - ((cols - 1) * 14)) / cols;

                      final metrics = [
                        {
                          'label': 'Total Akun Terdaftar',
                          'value': '${controller.totalUserCount}',
                          'sub': 'Data Live Supabase Database',
                          'icon': Icons.people_alt_rounded,
                          'color': const Color(0xFF38BDF8),
                        },
                        {
                          'label': 'E-Tiket Diterbitkan',
                          'value': '${controller.totalRegisteredJobFairCount}',
                          'sub': 'Peserta Terkonfirmasi On-Chain',
                          'icon': Icons.qr_code_2_rounded,
                          'color': AppColors.emeraldVerified,
                        },
                        {
                          'label': 'Mitra Industri Aktif',
                          'value': '${controller.companies.length}',
                          'sub': 'BUMN & Korporasi Mitra',
                          'icon': Icons.apartment_rounded,
                          'color': AppColors.pnlSignatureGold,
                        },
                        {
                          'label': 'Lowongan Terbuka',
                          'value': '$totalJobs',
                          'sub': 'Akumulasi Posisi dari Mitra',
                          'icon': Icons.work_history_rounded,
                          'color': const Color(0xFFA855F7),
                        },
                      ];

                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: metrics.map((m) {
                          return SizedBox(
                            width: width,
                            child: _buildMetricCard(
                              title: m['label'] as String,
                              value: m['value'] as String,
                              sub: m['sub'] as String,
                              icon: m['icon'] as IconData,
                              color: m['color'] as Color,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Tabs Navigation & Actions ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(paddingH, 12, paddingH, 16),
              child: ResponsiveCenterContainer(
                maxWidth: 1320,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Perusahaan Mitra (${controller.companies.length})', Icons.business_center_rounded),
                      const SizedBox(width: 8),
                      _buildTabButton(1, 'Akun Pengguna (${controller.allUsers.length})', Icons.people_alt_rounded),
                      const SizedBox(width: 8),
                      _buildTabButton(2, 'Peserta Job Fair (${controller.jobFairAttendees.length})', Icons.qr_code_scanner_rounded),
                      const SizedBox(width: 8),
                      _buildTabButton(3, 'Blockchain Ledger (${BlockchainService.ledger.length})', Icons.hub_rounded),
                      if (_selectedTab == 0 && !isDesktop) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showAddCompanyDialog(context, controller),
                          icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF0F172A), size: 28),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Main Tab Body Content ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(paddingH, 0, paddingH, 48),
              child: ResponsiveCenterContainer(
                maxWidth: 1320,
                child: _buildCurrentTabContent(context, controller, filteredCompanies, isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Metric Card ──────────────────────────────────────────────────────────
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }

  // ── Tab Button ────────────────────────────────────────────────────────────
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? AppColors.pnlSignatureGold : Colors.black12,
            width: isSel ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSel ? AppColors.pnlSignatureGold : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: PERUSAHAAN MITRA MANAGEMENT (CRUD) ────────────────────────────
  Widget _buildCompaniesTab(
    BuildContext context,
    AppController controller,
    List<CompanyMitra> companies,
    bool isDesktop,
  ) {
    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _companySearch = val),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama perusahaan, sektor, atau nomor booth...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textDim),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_companySearch.isNotEmpty)
                IconButton(
                  onPressed: () => setState(() => _companySearch = ''),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  splashRadius: 16,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Company cards list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: companies.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final c = companies[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.pnlSignatureGold.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        c.logoCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pnlSignatureGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldVerified.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${c.openPositions} Lowongan',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emeraldVerified,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c.sector}  •  ${c.boothNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withOpacity(0.65),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete Button
                  IconButton(
                    onPressed: () => _confirmDeleteCompany(context, controller, c.name),
                    tooltip: 'Hapus Perusahaan',
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.roseWarning, size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── TAB 2: BLOCKCHAIN LEDGER EXPLORER ─────────────────────────────────────
  Widget _buildBlockchainLedgerTab(BuildContext context) {
    final blocks = BlockchainService.ledger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.pnlSignatureGold.withOpacity(0.4)),
          ),
          child: Row(
            children: const [
              Icon(Icons.shield_outlined, color: AppColors.pnlSignatureGold, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamper-Proof Proof-of-Authority (PoA) Ledger',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Setiap E-Tiket diverifikasi secara kriptografis menggunakan algoritma SHA-256 dan terangkai ke blok sebelumnya.',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: blocks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final b = blocks[blocks.length - 1 - idx]; // Newest first
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BLOCK #${b.index}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pnlSignatureGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        b.ticketCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        b.timestamp.toLocal().toString().substring(0, 16),
                        style: const TextStyle(fontSize: 11, color: AppColors.textDim),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Peserta: ${b.attendeeName} (${b.identityNumber})  •  Slot: ${b.sessionSlot}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hash: ${b.hash}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF334155), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PrevHash: ${b.previousHash.substring(0, 24)}...',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
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

  // ── Modal Tambah Perusahaan ──────────────────────────────────────────────
  void _showAddCompanyDialog(BuildContext context, AppController controller) {
    final nameCtrl = TextEditingController();
    final sectorCtrl = TextEditingController();
    final boothCtrl = TextEditingController();
    final positionsCtrl = TextEditingController(text: '5');
    final descCtrl = TextEditingController();
    final logoCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.add_business_rounded, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Tambah Perusahaan Mitra', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorText != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.roseWarning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorText!, style: const TextStyle(color: AppColors.roseWarning, fontSize: 12)),
                    ),
                  _buildInput('Nama Perusahaan', nameCtrl, 'Contoh: PT Pupuk Iskandar Muda'),
                  const SizedBox(height: 12),
                  _buildInput('Sektor Industri', sectorCtrl, 'Contoh: Petrokimia & Pupuk Nasional'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInput('Nomor Booth', boothCtrl, 'Booth A-05')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInput('Posisi Lowongan', positionsCtrl, 'Jumlah')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput('Kode Logo / Singkatan (3-8 huruf)', logoCtrl, 'Contoh: PIM / PLN'),
                  const SizedBox(height: 12),
                  _buildInput('Deskripsi Singkat', descCtrl, 'Deskripsi peluang karir...', maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || sectorCtrl.text.trim().isEmpty) {
                  setDialogState(() => errorText = 'Nama dan sektor tidak boleh kosong.');
                  return;
                }

                await controller.addCompany(
                  name: nameCtrl.text.trim(),
                  sector: sectorCtrl.text.trim(),
                  boothNumber: boothCtrl.text.trim().isEmpty ? 'Booth TBD' : boothCtrl.text.trim(),
                  openPositions: int.tryParse(positionsCtrl.text.trim()) ?? 1,
                  description: descCtrl.text.trim().isEmpty
                      ? 'Perusahaan mitra membuka peluang vokasi di PNL Job Fair 2026.'
                      : descCtrl.text.trim(),
                  logoCode: logoCtrl.text.trim().isEmpty
                      ? nameCtrl.text.trim().substring(0, 3).toUpperCase()
                      : logoCtrl.text.trim(),
                );

                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perusahaan berhasil ditambahkan secara real-time!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF0F172A),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan Perusahaan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textDim),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.bgLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTabContent(
    BuildContext context,
    AppController controller,
    List<CompanyMitra> filteredCompanies,
    bool isDesktop,
  ) {
    switch (_selectedTab) {
      case 0:
        return _buildCompaniesTab(context, controller, filteredCompanies, isDesktop);
      case 1:
        return _buildUsersTab(context, controller, isDesktop);
      case 2:
        return _buildJobFairAttendeesTab(context, controller, isDesktop);
      case 3:
      default:
        return _buildBlockchainLedgerTab(context);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: DATA AKUN PENGGUNA TERDAFTAR (REAL-TIME MANAGEMENT)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildUsersTab(BuildContext context, AppController controller, bool isDesktop) {
    final filteredUsers = controller.allUsers.where((u) {
      if (_selectedCategoryFilter != null && u.category != _selectedCategoryFilter) {
        return false;
      }
      if (_userSearch.isNotEmpty) {
        final q = _userSearch.toLowerCase();
        final match = u.fullName.toLowerCase().contains(q) ||
            u.identityNumber.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.major.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls bar: Search & Category Filter
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _userSearch = val),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, NIM/NIK, email, atau program studi...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDim),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.pnlPrimary),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Refresh Data Database',
                    onPressed: () => controller.fetchAdminMetrics(),
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.pnlPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Category filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryFilterChip(null, 'Semua Akun (${controller.allUsers.length})'),
                    const SizedBox(width: 8),
                    _buildCategoryFilterChip(UserCategory.mahasiswaPnl, 'Mahasiswa PNL'),
                    const SizedBox(width: 8),
                    _buildCategoryFilterChip(UserCategory.alumniPnl, 'Alumni PNL'),
                    const SizedBox(width: 8),
                    _buildCategoryFilterChip(UserCategory.umum, 'Umum'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filteredUsers.isEmpty)
          _buildEmptyPlaceholder(
            'Tidak ada akun pengguna yang cocok',
            'Silakan ubah filter pencarian atau pastikan pengguna telah terdaftar di database Supabase.',
            Icons.people_outline_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredUsers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserCard(context, controller, user, isDesktop);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryFilterChip(UserCategory? cat, String label) {
    final isSel = _selectedCategoryFilter == cat;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: const Color(0xFF0F172A),
      labelStyle: TextStyle(
        color: isSel ? Colors.white : const Color(0xFF334155),
        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
        fontSize: 11.5,
      ),
      onSelected: (_) => setState(() => _selectedCategoryFilter = cat),
    );
  }

  Widget _buildUserCard(BuildContext context, AppController controller, UserProfile user, bool isDesktop) {
    final catColor = _getCategoryColor(user.category);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  border: Border.all(color: catColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: catColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            user.category.shortLabel,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: catColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.identityNumber}  •  ${user.major}',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${user.email}  |  WA: ${user.phone.isNotEmpty ? user.phone : '-'}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
              // Action buttons: Edit & Delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Profil Akun',
                    icon: const Icon(Icons.edit_rounded, color: AppColors.pnlPrimary, size: 20),
                    onPressed: () => _showEditUserDialog(context, controller, user),
                  ),
                  IconButton(
                    tooltip: 'Hapus Akun Pengguna',
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.roseWarning, size: 20),
                    onPressed: () => _confirmDeleteUser(context, controller, user),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Badges row: Job Fair Status & Recovery key
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: user.isRegisteredJobFair ? AppColors.emeraldVerified.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.isRegisteredJobFair ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 13,
                      color: user.isRegisteredJobFair ? AppColors.emeraldVerified : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      user.isRegisteredJobFair ? 'Tiket: ${user.ticketCode ?? "Aktif"}' : 'Belum Daftar Job Fair',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: user.isRegisteredJobFair ? AppColors.emeraldVerified : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (user.recoveryKey != null) ...[
                Text(
                  'Key E2EE: ${user.recoveryKey!.substring(0, user.recoveryKey!.length > 18 ? 18 : user.recoveryKey!.length)}...',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: PESERTA JOB FAIR TERDAFTAR (GATE ATTENDANCE & VERIFICATION)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildJobFairAttendeesTab(BuildContext context, AppController controller, bool isDesktop) {
    final attendees = controller.jobFairAttendees.where((u) {
      if (_selectedAttendanceFilter == 'Hadir' && !u.isAttended) return false;
      if (_selectedAttendanceFilter == 'Belum Hadir' && u.isAttended) return false;
      if (_selectedAttendanceFilter == 'Sesi Pagi' && !(u.sessionSlot?.contains('Pagi') ?? false)) return false;
      if (_selectedAttendanceFilter == 'Sesi Siang' && !(u.sessionSlot?.contains('Siang') ?? false)) return false;

      if (_attendeeSearch.isNotEmpty) {
        final q = _attendeeSearch.toLowerCase();
        final match = u.fullName.toLowerCase().contains(q) ||
            u.identityNumber.toLowerCase().contains(q) ||
            (u.ticketCode?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls bar: Search & Filters
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (val) => setState(() => _attendeeSearch = val),
                decoration: InputDecoration(
                  hintText: 'Cari nomor tiket, nama peserta, atau NIM/NIK...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDim),
                  prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppColors.pnlSignatureGold),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.bgLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips for attendance & session
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['Semua', 'Sesi Pagi', 'Sesi Siang', 'Belum Hadir', 'Hadir'].map((filter) {
                    final isSel = _selectedAttendanceFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSel,
                        selectedColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF334155),
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 11.5,
                        ),
                        onSelected: (_) => setState(() => _selectedAttendanceFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (attendees.isEmpty)
          _buildEmptyPlaceholder(
            'Belum ada peserta Job Fair yang sesuai',
            'Peserta yang mengonfirmasi pendaftaran E-Tiket di Dashboard akan otomatis muncul di sini secara real-time.',
            Icons.event_seat_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendees.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = attendees[index];
              return _buildAttendeeCard(context, controller, user);
            },
          ),
      ],
    );
  }

  Widget _buildAttendeeCard(BuildContext context, AppController controller, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: user.isAttended ? AppColors.emeraldVerified.withOpacity(0.4) : Colors.black.withOpacity(0.06),
          width: user.isAttended ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pnlSignatureGold.withOpacity(0.6)),
                ),
                child: Text(
                  user.ticketCode ?? 'PNL-JF26-LIVE',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${user.identityNumber}  •  ${user.major}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.sessionSlot ?? 'Sesi Pagi (08:30 - 12:00 WIB)',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.pnlPrimary),
                    ),
                  ],
                ),
              ),
              // Gate Attendance Toggle
              ElevatedButton.icon(
                onPressed: () => controller.adminToggleAttendance(user.id, !user.isAttended),
                icon: Icon(
                  user.isAttended ? Icons.check_circle_rounded : Icons.login_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  user.isAttended ? 'Hadir di Gate' : 'Check-in Gate',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isAttended ? AppColors.emeraldVerified : const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Blockchain Proof Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: AppColors.emeraldVerified),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Block #${user.blockIndex ?? 1001}  •  Hash: ${user.blockchainBlockHash ?? "0x3a9f1c7d...PoA"}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF334155)),
                  ),
                ),
                InkWell(
                  onTap: () => _confirmCancelTicket(context, controller, user),
                  child: const Text(
                    'Batalkan Tiket',
                    style: TextStyle(fontSize: 10.5, color: AppColors.roseWarning, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textDim),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Color _getCategoryColor(UserCategory cat) {
    switch (cat) {
      case UserCategory.mahasiswaPnl:
        return AppColors.emeraldVerified;
      case UserCategory.alumniPnl:
        return AppColors.pnlSignatureGold;
      case UserCategory.umum:
        return AppColors.jurusanTIK;
    }
  }

  // ── Modal Edit Akun Pengguna ──────────────────────────────────────────────
  void _showEditUserDialog(BuildContext context, AppController controller, UserProfile user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final idCtrl = TextEditingController(text: user.identityNumber);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final majorCtrl = TextEditingController(text: user.major);
    UserCategory selectedCategory = user.category;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.manage_accounts_rounded, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Edit Profil Akun Pengguna', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Nama Lengkap', nameCtrl, 'Nama peserta'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInput('NIM / NIK', idCtrl, 'Nomor identitas')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInput('No. WhatsApp', phoneCtrl, '0812...')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput('Email Resmi', emailCtrl, 'email@pnl.ac.id'),
                  const SizedBox(height: 12),
                  _buildInput('Program Studi / Jurusan', majorCtrl, 'Prodi peserta'),
                  const SizedBox(height: 12),
                  const Text('Kategori Akun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: UserCategory.values.map((cat) {
                      final isSel = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat.shortLabel),
                        selected: isSel,
                        selectedColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF334155),
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 11.5,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = user.copyWith(
                  fullName: nameCtrl.text.trim(),
                  identityNumber: idCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  major: majorCtrl.text.trim(),
                  category: selectedCategory,
                );
                await controller.adminUpdateUser(updated);
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data profil akun berhasil diperbarui secara real-time!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Konfirmasi Hapus Akun Pengguna ─────────────────────────────────────────
  void _confirmDeleteUser(BuildContext context, AppController controller, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun Pengguna?'),
        content: Text('Apakah Anda yakin ingin menghapus akun "${user.fullName}" (${user.identityNumber}) dari database Supabase? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await controller.adminDeleteUser(user.id);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Akun ${user.fullName} berhasil dihapus dari database.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseWarning),
            child: const Text('Hapus Akun', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi Pembatalan Tiket Job Fair ───────────────────────────────────
  void _confirmCancelTicket(BuildContext context, AppController controller, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Tiket Job Fair?'),
        content: Text('Batalkan pendaftaran tiket ${user.ticketCode} milik "${user.fullName}"? Status tiket akan dicabut.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await controller.adminCancelJobFairTicket(user.id);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tiket milik ${user.fullName} berhasil dibatalkan.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseWarning),
            child: const Text('Batalkan Tiket', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi Hapus Perusahaan Mitra ─────────────────────────────────────
  void _confirmDeleteCompany(BuildContext context, AppController controller, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perusahaan?'),
        content: Text('Apakah Anda yakin ingin menghapus "$name" dari direktori mitra PNL Job Fair?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              controller.deleteCompany(name);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Perusahaan $name berhasil dihapus.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseWarning),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
