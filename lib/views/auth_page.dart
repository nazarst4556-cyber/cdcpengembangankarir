import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/blockchain_service.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/liquid_glass.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isRegister;
  UserCategory _selectedCategory = UserCategory.mahasiswaPnl;

  // Controllers
  final _nameController = TextEditingController(text: 'Cut Nurul Annisa');
  final _emailController = TextEditingController(text: 'cut.annisa@pnl.ac.id');
  final _phoneController = TextEditingController(text: '081269887766');
  final _idController = TextEditingController(text: '2205102035'); // NIM / NIK
  final _majorController = TextEditingController(text: 'D4 Teknik Rekayasa Pengolahan Minyak & Gas');
  final _passwordController = TextEditingController(text: 'password123');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppScope.of(context);
    _isRegister = controller.isAuthModeRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _majorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit(AppController controller) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (_isRegister) {
      if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Harap isi nama dan email dengan benar.';
          _isLoading = false;
        });
        return;
      }

      await controller.registerUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        category: _selectedCategory,
        identityNumber: _idController.text.trim(),
        major: _majorController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      await controller.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              // Top Navigation & 6 Jurusan Spectrum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => controller.setPage(AppPage.landing),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.pnlCyanGlow, size: 18),
                    label: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: AppColors.pnlCyanGlow, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => controller.setPage(AppPage.admin),
                        icon: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.pnlSignatureGold),
                        label: const Text(
                          'Portal Admin',
                          style: TextStyle(
                            color: AppColors.pnlSignatureGold,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const IslandJurusanSpectrumBadge(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main Auth Card
              LiquidGlassCard(
                borderRadius: 28,
                padding: EdgeInsets.all(isDesktop ? 36 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PNL & CDC Header
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pnlCyanGlow.withOpacity(0.35),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo_pnl.jpg',
                              width: 46,
                              height: 46,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'PORTAL AKUN CDC / UPA. PKK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: AppColors.pnlGoldLight,
                                ),
                              ),
                              Text(
                                'Politeknik Negeri Lhokseumawe',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tab Selector: Register vs Login
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAuthTab(
                              title: 'Daftar Akun Baru',
                              isActive: _isRegister,
                              onTap: () => setState(() => _isRegister = true),
                            ),
                          ),
                          Expanded(
                            child: _buildAuthTab(
                              title: 'Masuk Akun',
                              isActive: !_isRegister,
                              onTap: () => setState(() => _isRegister = false),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.roseWarning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.roseWarning.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.roseWarning, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_isRegister) ...[
                      // Category Selector
                      const Text(
                        'Kategori Keanggotaan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: UserCategory.values.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.pnlPrimary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.pnlPrimary
                                      : AppColors.pnlPrimary.withOpacity(0.15),
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
                              child: Text(
                                cat.shortLabel,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap (Sesuai KTP/Ijazah)',
                        icon: Icons.person_outline_rounded,
                      ),

                      const SizedBox(height: 16),

                      // Email & Phone in row or column
                      _buildTextField(
                        controller: _emailController,
                        label: 'Alamat Email Aktif',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Nomor WhatsApp (Aktif)',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      // NIM / NIK
                      _buildTextField(
                        controller: _idController,
                        label: _selectedCategory == UserCategory.umum ? 'Nomor NIK KTP' : 'Nomor Induk Mahasiswa (NIM)',
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Major / Institution
                      _buildTextField(
                        controller: _majorController,
                        label: _selectedCategory == UserCategory.umum ? 'Instansi / Asal Kampus' : 'Jurusan / Program Studi PNL',
                        icon: Icons.domain_rounded,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                    ] else ...[
                      // Login Mode
                      _buildTextField(
                        controller: _emailController,
                        label: 'Alamat Email Akun CDC',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => _showForgotPasswordE2EEDialog(context, controller),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.shield_outlined, size: 14, color: AppColors.pnlSignatureGold),
                                SizedBox(width: 4),
                                Text(
                                  'Lupa Kata Sandi? (E2EE Recovery)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.pnlSignatureGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Submit Button
                    LiquidButton(
                      label: _isRegister ? 'Daftar Akun CDC Sekarang' : 'Masuk ke Dashboard CDC',
                      icon: _isRegister ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                      isGold: _isRegister,
                      isLoading: _isLoading,
                      onPressed: () => _handleSubmit(controller),
                    ),

                    const SizedBox(height: 18),

                    // Privacy notice
                    Text(
                      'Dengan melanjutkan, Anda menyetujui syarat & ketentuan layanan UPA. Pengembangan Karir dan Kewirausahaan Politeknik Negeri Lhokseumawe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.pnlPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.pnlPrimary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.pnlPrimary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.pnlPrimary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // END-TO-END CRYPTOGRAPHIC PASSWORD RECOVERY DIALOG
  // ══════════════════════════════════════════════════════════════════════════
  void _showForgotPasswordE2EEDialog(BuildContext context, AppController controller) {
    final emailResetCtrl = TextEditingController(text: _emailController.text);
    final idResetCtrl = TextEditingController(text: _idController.text);
    final keyResetCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isProcessing = false;
    String? errorMsg;
    String? successMsg;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 480,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pnlSignatureGold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.enhanced_encryption_rounded,
                            color: AppColors.pnlSignatureGold, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemulihan Sandi Kriptografis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Validasi Zero-Knowledge E2EE & Hash SHA-256',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (errorMsg != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.roseWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.roseWarning, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(errorMsg!, style: const TextStyle(color: AppColors.roseWarning, fontSize: 11.5)),
                              ),
                            ],
                          ),
                        ),

                      if (successMsg != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldVerified.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldVerified, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(successMsg!, style: const TextStyle(color: AppColors.emeraldVerified, fontSize: 11.5, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),

                      _buildModalField('Email Akun CDC', emailResetCtrl, 'email@pnl.ac.id', Icons.mail_outline_rounded),
                      const SizedBox(height: 10),
                      _buildModalField('NIM atau NIK', idResetCtrl, '2105102044', Icons.badge_outlined),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kunci Pemulihan 6-Kata Kriptografi',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                          InkWell(
                            onTap: () {
                              final autoKey = BlockchainService.generateRecoverySeedPhrase(
                                emailResetCtrl.text.trim(),
                                idResetCtrl.text.trim(),
                              );
                              setDialogState(() => keyResetCtrl.text = autoKey);
                            },
                            child: const Text(
                              'Generate Kunci Valid',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.pnlPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: keyResetCtrl,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'kata1-kata2-kata3-kata4-kata5-kata6',
                          hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textDim),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.bgLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildModalField('Kata Sandi Baru', newPassCtrl, 'Minimal 6 karakter', Icons.lock_outline_rounded, isPassword: true),
                    ],
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final email = emailResetCtrl.text.trim();
                                final id = idResetCtrl.text.trim();
                                final key = keyResetCtrl.text.trim();
                                final newPass = newPassCtrl.text.trim();

                                if (email.isEmpty || id.isEmpty || key.isEmpty || newPass.isEmpty) {
                                  setDialogState(() => errorMsg = 'Harap lengkapi semua kolom pemulihan.');
                                  return;
                                }

                                setDialogState(() {
                                  isProcessing = true;
                                  errorMsg = null;
                                });

                                await Future.delayed(const Duration(milliseconds: 500));

                                final success = await controller.resetPasswordWithRecoveryKey(
                                  email: email,
                                  identityNumber: id,
                                  recoveryKey: key,
                                  newPassword: newPass,
                                );

                                if (success) {
                                  setDialogState(() {
                                    isProcessing = false;
                                    successMsg = 'Kata sandi berhasil dipulihkan secara terenkripsi!';
                                  });
                                  await Future.delayed(const Duration(milliseconds: 900));
                                  if (dialogCtx.mounted) {
                                    Navigator.of(dialogCtx).pop();
                                  }
                                } else {
                                  setDialogState(() {
                                    isProcessing = false;
                                    errorMsg = 'Kunci pemulihan tidak valid atau tidak cocok dengan data akun.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.pnlSignatureGold.withOpacity(0.5)),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Verifikasi & Simpan Sandi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
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
  }

  Widget _buildModalField(String label, TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textDim),
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: AppColors.bgLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
          ),
        ),
      ],
    );
  }
}
