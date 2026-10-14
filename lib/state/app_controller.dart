import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_models.dart';

enum AppPage {
  landing,
  auth,
  dashboard,
}

class AppController extends ChangeNotifier {
  AppPage _currentPage = AppPage.landing;
  UserProfile? _currentUser;
  bool _isAuthModeRegister = true; // true = Register, false = Login
  String? _selectedSession = 'Sesi Pagi (08:30 - 12:00 WIB)';

  // Mock list of companies for Job Fair 2026
  final List<CompanyMitra> _companies = const [
    CompanyMitra(
      name: 'PT Pupuk Iskandar Muda (PIM)',
      sector: 'Petrokimia & Pupuk Nasional',
      boothNumber: 'Booth A-01 (Main Hall)',
      openPositions: 8,
      description: 'Anak perusahaan PT Pupuk Indonesia yang beroperasi di Kawasan Ekonomi Khusus Lhokseumawe.',
      logoCode: 'PIM',
    ),
    CompanyMitra(
      name: 'PT Pertamina (Persero)',
      sector: 'Energi, Minyak & Gas Bumi',
      boothNumber: 'Booth A-02 (Main Hall)',
      openPositions: 12,
      description: 'BUMN energi terkemuka membuka kesempatan Management Trainee dan Teknisi Lapangan.',
      logoCode: 'PERTAMINA',
    ),
    CompanyMitra(
      name: 'PT Medco E&P Malaka',
      sector: 'Eksplorasi Migas',
      boothNumber: 'Booth B-03',
      openPositions: 6,
      description: 'Operator Blok A Aceh Timur yang berkomitmen menyerap talenta vokasi teknik dari PNL.',
      logoCode: 'MEDCO',
    ),
    CompanyMitra(
      name: 'Bank Syariah Indonesia (BSI)',
      sector: 'Perbankan & Finansial Syariah',
      boothNumber: 'Booth B-04',
      openPositions: 15,
      description: 'Membuka program Officer Development Program (ODP) dan Customer Relationship.',
      logoCode: 'BSI',
    ),
    CompanyMitra(
      name: 'PT Telkom Indonesia (Persero) Tbk',
      sector: 'Telekomunikasi & Digital Solutions',
      boothNumber: 'Booth C-01',
      openPositions: 10,
      description: 'Peluang karir di bidang Network Engineer, Data Analyst, dan Cloud Architect.',
      logoCode: 'TELKOM',
    ),
    CompanyMitra(
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
  List<CompanyMitra> get companies => _companies;

  void setPage(AppPage page) {
    _currentPage = page;
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

  /// Register User Baru di CDC PNL
  Future<void> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required UserCategory category,
    required String identityNumber,
    required String major,
  }) async {
    // Generate simple ID
    final id = 'CDC-USR-${Random().nextInt(90000) + 10000}';

    _currentUser = UserProfile(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      category: category,
      identityNumber: identityNumber,
      major: major,
      isRegisteredJobFair: false,
    );

    _currentPage = AppPage.dashboard;
    notifyListeners();
  }

  /// Login Dummy / Demo User
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    // Demo Login: jika ada akun sebelumnya pakai, jika tidak buat profil default mahasiswa PNL
    _currentUser ??= UserProfile(
      id: 'CDC-USR-202611',
      fullName: 'Rizki Maulana, S.Tr.Kom',
      email: email.isNotEmpty ? email : 'rizki.maulana@pnl.ac.id',
      phone: '081269001234',
      category: UserCategory.mahasiswaPnl,
      identityNumber: '2105102044',
      major: 'D4 Teknologi Rekayasa Komputer Jaringan',
      isRegisteredJobFair: false,
    );

    _currentPage = AppPage.dashboard;
    notifyListeners();
  }

  /// Pendaftaran Event Job Fair 2026
  Future<void> registerJobFair() async {
    if (_currentUser == null) return;

    final randomCode = Random().nextInt(9000) + 1000;
    final ticketCode = 'PNL-JF26-$randomCode';

    _currentUser = _currentUser!.copyWith(
      isRegisteredJobFair: true,
      ticketCode: ticketCode,
      sessionSlot: _selectedSession ?? 'Sesi Pagi (08:30 - 12:00 WIB)',
      registeredAt: DateTime.now(),
    );

    notifyListeners();
  }

  void logout() {
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
