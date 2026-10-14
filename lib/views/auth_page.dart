import 'package:flutter/material.dart';
import '../models/app_models.dart';
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
                  const IslandJurusanSpectrumBadge(),
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
                        child: Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.pnlCyanGlow,
                            fontWeight: FontWeight.w500,
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
}
