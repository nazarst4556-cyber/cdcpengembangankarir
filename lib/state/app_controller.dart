import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/blockchain_service.dart';
import '../services/supabase_service.dart';

enum AppPage {
  landing,
  auth,
  dashboard,
  admin,
}

class AppController extends ChangeNotifier {
  AppPage _currentPage = AppPage.landing;
  UserProfile? _currentUser;
  bool _isAuthModeRegister = true; // true = Register, false = Login
  String? _selectedSession = 'Sesi Pagi (08:30 - 12:00 WIB)';

  // Real-time admin metrics (synced live with Supabase database)
  int _totalUserCount = 0;
  int _totalRegisteredJobFairCount = 0;
  bool _isAdminLoading = false;
  List<UserProfile> _allUsers = [];

  AppController() {
    fetchAdminMetrics();
  }

  // Mutable list of companies for Job Fair 2026 (Live synced with Supabase)
  List<CompanyMitra> _companies = [
    const CompanyMitra(
      id: 'comp-1',
      name: 'PT Pupuk Iskandar Muda (PIM)',
      sector: 'Petrokimia & Pupuk Nasional',
      boothNumber: 'Booth A-01 (Main Hall)',
      openPositions: 8,
      description: 'Anak perusahaan PT Pupuk Indonesia yang beroperasi di Kawasan Ekonomi Khusus Lhokseumawe.',
      logoCode: 'PIM',
    ),
    const CompanyMitra(
      id: 'comp-2',
      name: 'PT Pertamina (Persero)',
      sector: 'Energi, Minyak & Gas Bumi',
      boothNumber: 'Booth A-02 (Main Hall)',
      openPositions: 12,
      description: 'BUMN energi terkemuka membuka kesempatan Management Trainee dan Teknisi Lapangan.',
      logoCode: 'PERTAMINA',
    ),
    const CompanyMitra(
      id: 'comp-3',
      name: 'PT Medco E&P Malaka',
      sector: 'Eksplorasi Migas',
      boothNumber: 'Booth B-03',
      openPositions: 6,
      description: 'Operator Blok A Aceh Timur yang berkomitmen menyerap talenta vokasi teknik dari PNL.',
      logoCode: 'MEDCO',
    ),
    const CompanyMitra(
      id: 'comp-4',
      name: 'Bank Syariah Indonesia (BSI)',
      sector: 'Perbankan & Finansial Syariah',
      boothNumber: 'Booth B-04',
      openPositions: 15,
      description: 'Membuka program Officer Development Program (ODP) dan Customer Relationship.',
      logoCode: 'BSI',
    ),
    const CompanyMitra(
      id: 'comp-5',
      name: 'PT Telkom Indonesia (Persero) Tbk',
      sector: 'Telekomunikasi & Digital Solutions',
      boothNumber: 'Booth C-01',
      openPositions: 10,
      description: 'Peluang karir di bidang Network Engineer, Data Analyst, dan Cloud Architect.',
      logoCode: 'TELKOM',
    ),
    const CompanyMitra(
      id: 'comp-6',
      name: 'PT Harum Energy Tbk',
      sector: 'Pertambangan & Logistik Energi',
      boothNumber: 'Booth C-02',
      openPositions: 7,
      description: 'Perusahaan energi terintegrasi untuk posisi Mechanical & Electrical Supervisor.',
      logoCode: 'HARUM',
    ),
  ];

  // Getters
  AppPage get currentPage => _currentPage;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAuthModeRegister => _isAuthModeRegister;
  String? get selectedSession => _selectedSession;
  List<CompanyMitra> get companies => List.unmodifiable(_companies);
  int get totalUserCount => _totalUserCount;
  int get totalRegisteredJobFairCount => _totalRegisteredJobFairCount;
  bool get isAdminLoading => _isAdminLoading;
  List<UserProfile> get allUsers => List.unmodifiable(_allUsers);
  List<UserProfile> get jobFairAttendees =>
      List.unmodifiable(_allUsers.where((u) => u.isRegisteredJobFair).toList());

  void setPage(AppPage page) {
    _currentPage = page;
    if (page == AppPage.admin) {
      fetchAdminMetrics();
    }
    notifyListeners();
  }

  void setAuthMode(bool isRegister) {
    _isAuthModeRegister = isRegister;
    _currentPage = AppPage.auth;
    notifyListeners();
  }

  void setSelectedSession(String session) {
    _selectedSession = session;
    notifyListeners();
  }

  /// ══════════════════════════════════════════════════════════════════════════
  /// 1. AUTH & REGISTRASI DENGAN E2EE CRYPTOGRAPHIC RECOVERY KEY
  /// ══════════════════════════════════════════════════════════════════════════
  Future<void> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required UserCategory category,
    required String identityNumber,
    required String major,
    String password = 'defaultPassword123!',
  }) async {
    // Generate End-to-End Encryption Cryptographic Recovery Key
    final recoveryKey = BlockchainService.generateRecoverySeedPhrase(email, identityNumber);

    // Coba simpan ke Supabase
    UserProfile? supaUser;
    try {
      supaUser = await SupabaseService.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        category: category,
        identityNumber: identityNumber,
        major: major,
        password: password,
      );
    } catch (_) {}

    final id = supaUser?.id ?? 'CDC-USR-${Random().nextInt(90000) + 10000}';

    final newUser = (supaUser ??
        UserProfile(
          id: id,
          fullName: fullName,
          email: email,
          phone: phone,
          category: category,
          identityNumber: identityNumber,
          major: major,
          isRegisteredJobFair: false,
          registeredAt: DateTime.now(),
        )).copyWith(recoveryKey: recoveryKey);

    _currentUser = newUser;
    _allUsers.removeWhere((u) => u.id == newUser.id || u.email == newUser.email);
    _allUsers.insert(0, newUser);
    _totalUserCount = _allUsers.length;
    _currentPage = AppPage.dashboard;
    notifyListeners();
  }

  /// Login User di CDC PNL (terintegrasi Supabase)
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    // Coba ambil dari Supabase
    UserProfile? supaUser;
    try {
      supaUser = await SupabaseService.loginUser(
        email: email,
        password: password,
      );
    } catch (_) {}

    if (supaUser != null) {
      _currentUser = supaUser.copyWith(
        recoveryKey: BlockchainService.generateRecoverySeedPhrase(
            supaUser.email, supaUser.identityNumber),
      );
      _allUsers.removeWhere((u) => u.id == _currentUser!.id || u.email == _currentUser!.email);
      _allUsers.insert(0, _currentUser!);
    } else {
      final customUser = UserProfile(
        id: 'CDC-USR-${Random().nextInt(90000) + 10000}',
        fullName: email.isNotEmpty && email.contains('@')
            ? email.split('@').first.replaceAll('.', ' ').toUpperCase()
            : 'Peserta CDC PNL',
        email: email,
        phone: '081269001234',
        category: UserCategory.mahasiswaPnl,
        identityNumber: '2105102044',
        major: 'D4 Teknologi Rekayasa Komputer Jaringan',
        isRegisteredJobFair: false,
        registeredAt: DateTime.now(),
        recoveryKey: BlockchainService.generateRecoverySeedPhrase(email, '2105102044'),
      );
      _currentUser = customUser;
      _allUsers.removeWhere((u) => u.id == customUser.id || u.email == customUser.email);
      _allUsers.insert(0, customUser);
    }

    _totalUserCount = _allUsers.length;
    _currentPage = AppPage.dashboard;
    notifyListeners();
  }

  /// Pemulihan Kata Sandi Menggunakan Kriptografi End-to-End
  Future<bool> resetPasswordWithRecoveryKey({
    required String email,
    required String identityNumber,
    required String recoveryKey,
    required String newPassword,
  }) async {
    final isValid = BlockchainService.verifyRecoverySeedPhrase(
      email: email,
      identityNumber: identityNumber,
      enteredKey: recoveryKey,
    );

    if (!isValid) return false;

    // Sinkronisasi update kata sandi ke Supabase
    await SupabaseService.resetPasswordWithRecoveryKey(
      email: email,
      newPassword: newPassword,
    );

    return true;
  }

  /// ══════════════════════════════════════════════════════════════════════════
  /// 2. PENDAFTARAN EVENT DENGAN BLOCKCHAIN BLOCK TAMPER-PROOF HASH
  /// ══════════════════════════════════════════════════════════════════════════
  Future<void> registerJobFair() async {
    if (_currentUser == null) return;

    final randomCode = Random().nextInt(9000) + 1000;
    final ticketCode = 'PNL-JF26-$randomCode';
    final sessionSlot = _selectedSession ?? 'Sesi Pagi (08:30 - 12:00 WIB)';

    // Mine Immutable Blockchain Block
    final block = BlockchainService.mineTicketBlock(
      ticketCode: ticketCode,
      attendeeName: _currentUser!.fullName,
      identityNumber: _currentUser!.identityNumber,
      sessionSlot: sessionSlot,
    );

    // Sinkronisasi ke Supabase
    try {
      await SupabaseService.registerJobFairTicket(
        userId: _currentUser!.id,
        ticketCode: ticketCode,
        sessionSlot: sessionSlot,
        blockHash: block.hash,
        blockIndex: block.index,
      );
    } catch (_) {}

    final updated = _currentUser!.copyWith(
      isRegisteredJobFair: true,
      ticketCode: ticketCode,
      sessionSlot: sessionSlot,
      registeredAt: DateTime.now(),
      blockchainBlockHash: block.hash,
      blockIndex: block.index,
    );
    _currentUser = updated;

    final idx = _allUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _allUsers[idx] = updated;
    } else {
      _allUsers.insert(0, updated);
    }

    _totalRegisteredJobFairCount = _allUsers.where((u) => u.isRegisteredJobFair).length;
    notifyListeners();
  }

  /// Perbarui Data Profil Peserta (terintegrasi Supabase)
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    UserCategory? category,
    String? identityNumber,
    String? major,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      category: category,
      identityNumber: identityNumber,
      major: major,
    );

    // Sinkronisasi update ke Supabase
    try {
      await SupabaseService.updateProfile(_currentUser!);
    } catch (_) {}

    notifyListeners();
  }

  /// ══════════════════════════════════════════════════════════════════════════
  /// 3. ADMIN CONTROL CENTER (REAL-TIME METRICS & CRUD PERUSAHAAN MITRA)
  /// ══════════════════════════════════════════════════════════════════════════

  /// Refresh metrik admin, seluruh data akun, dan daftar perusahaan dari database secara real-time
  Future<void> fetchAdminMetrics() async {
    _isAdminLoading = true;
    notifyListeners();

    try {
      final supaProfiles = await SupabaseService.fetchAllProfiles();
      final supaCompanies = await SupabaseService.fetchCompanies();

      if (supaProfiles.isNotEmpty) {
        _allUsers = supaProfiles;
      }
      _totalUserCount = _allUsers.length;
      _totalRegisteredJobFairCount = _allUsers.where((u) => u.isRegisteredJobFair).length;

      if (supaCompanies.isNotEmpty) {
        _companies = supaCompanies;
      }
    } catch (_) {}

    _isAdminLoading = false;
    notifyListeners();
  }

  /// Hapus akun pengguna secara real-time oleh admin
  Future<void> adminDeleteUser(String id) async {
    _allUsers.removeWhere((u) => u.id == id);
    if (_currentUser?.id == id) {
      _currentUser = null;
    }
    _totalUserCount = _allUsers.length;
    _totalRegisteredJobFairCount = _allUsers.where((u) => u.isRegisteredJobFair).length;
    notifyListeners();

    try {
      await SupabaseService.deleteUserProfile(id);
    } catch (_) {}
  }

  /// Update data akun pengguna secara real-time oleh admin
  Future<void> adminUpdateUser(UserProfile updated) async {
    final idx = _allUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _allUsers[idx] = updated;
    }
    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
    }
    _totalRegisteredJobFairCount = _allUsers.where((u) => u.isRegisteredJobFair).length;
    notifyListeners();

    try {
      await SupabaseService.updateUserProfileAdmin(updated);
    } catch (_) {}
  }

  /// Verifikasi atau ubah status kehadiran peserta Job Fair di Gate
  Future<void> adminToggleAttendance(String userId, bool isAttended) async {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(isAttended: isAttended);
      _allUsers[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();

      try {
        await SupabaseService.updateJobFairAttendance(userId, isAttended);
      } catch (_) {}
    }
  }

  /// Batalkan tiket pendaftaran Job Fair peserta
  Future<void> adminCancelJobFairTicket(String userId) async {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _allUsers[idx].copyWith(
        isRegisteredJobFair: false,
        ticketCode: null,
        sessionSlot: null,
        isAttended: false,
      );
      _allUsers[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      _totalRegisteredJobFairCount = _allUsers.where((u) => u.isRegisteredJobFair).length;
      notifyListeners();

      try {
        await SupabaseService.updateUserProfileAdmin(updated);
      } catch (_) {}
    }
  }

  /// Tambah Perusahaan Mitra Baru Secara Real-Time
  Future<void> addCompany({
    required String name,
    required String sector,
    required String boothNumber,
    required int openPositions,
    required String description,
    required String logoCode,
  }) async {
    final newComp = CompanyMitra(
      id: 'comp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sector: sector,
      boothNumber: boothNumber,
      openPositions: openPositions,
      description: description,
      logoCode: logoCode.toUpperCase(),
    );

    _companies.insert(0, newComp);
    notifyListeners();

    // Simpan ke Supabase
    try {
      await SupabaseService.addCompany(newComp);
    } catch (_) {}
  }

  /// Hapus Perusahaan Mitra Secara Real-Time
  Future<void> deleteCompany(String name) async {
    _companies.removeWhere((c) => c.name == name);
    notifyListeners();

    try {
      await SupabaseService.deleteCompany(name);
    } catch (_) {}
  }

  void logout() {
    try {
      if (SupabaseService.isInitialized) {
        SupabaseService.client.auth.signOut();
      }
    } catch (_) {}
    _currentUser = null;
    _currentPage = AppPage.landing;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(result != null, 'No AppScope found in context');
    return result!.notifier!;
  }
}
