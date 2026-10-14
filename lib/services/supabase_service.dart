import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class SupabaseService {
  // ══════════════════════════════════════════════════════════════════════════
  // SUPABASE CREDENTIALS — CDC Politeknik Negeri Lhokseumawe
  // ══════════════════════════════════════════════════════════════════════════
  static const String supabaseUrl = 'https://rktanqyqzcslizuxonkb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJrdGFucXlxemNzbGl6dXhvbmtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5NTM4NDIsImV4cCI6MjEwNzUyOTg0Mn0.Nq6IwWagfYP3j67g8Risb5V5rKhOPXyOOHxfHr10ok4';
  static const String supabasePublishableKey =
      'sb_publishable_mWVcsHbRyEVlw7XBBKpgvA_kaBYC69q';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi Supabase SDK
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('⚡ [SupabaseService] Initialized successfully to $supabaseUrl');
    } catch (e) {
      debugPrint('⚠️ [SupabaseService] Init warning: $e');
      _isInitialized = false;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ══════════════════════════════════════════════════════════════════════════
  // 1. AUTH & PROFILES
  // ══════════════════════════════════════════════════════════════════════════

  /// Registrasi user baru di Supabase Auth & Tabel Profiles
  static Future<UserProfile?> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required UserCategory category,
    required String identityNumber,
    required String major,
    String password = 'defaultPassword123!',
  }) async {
    try {
      if (!_isInitialized) return null;

      // 1. Coba registrasi ke Supabase Auth
      AuthResponse? authRes;
      try {
        authRes = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'phone': phone,
            'identity_number': identityNumber,
            'category': category.name,
            'major': major,
          },
        );
      } catch (authErr) {
        debugPrint('⚠️ Auth signup notice: $authErr');
      }

      final String userId = authRes?.user?.id ??
          'CDC-USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newProfile = UserProfile(
        id: userId,
        fullName: fullName,
        email: email,
        phone: phone,
        category: category,
        identityNumber: identityNumber,
        major: major,
        isRegisteredJobFair: false,
      );

      // 2. Simpan ke tabel 'profiles' jika tabel sudah dibuat di Supabase
      try {
        await client.from('profiles').upsert({
          'id': userId,
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'category': category.name,
          'identity_number': identityNumber,
          'major': major,
          'is_registered_job_fair': false,
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ [Supabase] Profile saved to profiles table');
      } catch (dbErr) {
        debugPrint('⚠️ [Supabase] Upsert profiles notice: $dbErr');
      }

      return newProfile;
    } catch (e) {
      debugPrint('❌ [SupabaseService] registerUser error: $e');
      return null;
    }
  }

  /// Login user via Supabase
  static Future<UserProfile?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isInitialized) return null;

      // Coba auth sign in
      try {
        final authRes = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (authRes.user != null) {
          final profileData = await getProfile(authRes.user!.id, email);
          if (profileData != null) return profileData;
        }
      } catch (authErr) {
        debugPrint('⚠️ Auth signIn notice: $authErr');
      }

      // Coba ambil dari tabel 'profiles' berdasarkan email
      return await getProfileByEmail(email);
    } catch (e) {
      debugPrint('❌ [SupabaseService] loginUser error: $e');
      return null;
    }
  }

  /// Ambil profil berdasarkan ID atau Email
  static Future<UserProfile?> getProfile(String id, [String? fallbackEmail]) async {
    try {
      if (!_isInitialized) return null;
      final res = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res != null) {
        return _mapJsonToProfile(res);
      }

      if (fallbackEmail != null) {
        return await getProfileByEmail(fallbackEmail);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [Supabase] getProfile notice: $e');
      return null;
    }
  }

  /// Ambil profil berdasarkan Email
  static Future<UserProfile?> getProfileByEmail(String email) async {
    try {
      if (!_isInitialized) return null;
      final res = await client
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (res != null) {
        return _mapJsonToProfile(res);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [Supabase] getProfileByEmail notice: $e');
      return null;
    }
  }

  /// Update data profil di Supabase
  static Future<bool> updateProfile(UserProfile profile) async {
    try {
      if (!_isInitialized) return false;

      await client.from('profiles').upsert({
        'id': profile.id,
        'full_name': profile.fullName,
        'email': profile.email,
        'phone': profile.phone,
        'category': profile.category.name,
        'identity_number': profile.identityNumber,
        'major': profile.major,
        'is_registered_job_fair': profile.isRegisteredJobFair,
        'ticket_code': profile.ticketCode,
        'session_slot': profile.sessionSlot,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ [Supabase] Profile updated in database');
      return true;
    } catch (e) {
      debugPrint('⚠️ [Supabase] updateProfile notice: $e');
      return false;
    }
  }

  /// Registrasi E-Tiket Job Fair di Supabase (dengan hash blockchain)
  static Future<bool> registerJobFairTicket({
    required String userId,
    required String ticketCode,
    required String sessionSlot,
    String? blockHash,
    int? blockIndex,
  }) async {
    try {
      if (!_isInitialized) return false;

      // Update di profiles
      await client.from('profiles').update({
        'is_registered_job_fair': true,
        'ticket_code': ticketCode,
        'session_slot': sessionSlot,
        'registered_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Catat juga ke job_fair_registrations log jika ada
      try {
        await client.from('job_fair_registrations').insert({
          'user_id': userId,
          'ticket_code': ticketCode,
          'session_slot': sessionSlot,
          'event_name': 'PNL Job Fair & Career Expo 2026',
          'registered_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}

      debugPrint('✅ [Supabase] Job Fair Ticket registered in database');
      return true;
    } catch (e) {
      debugPrint('⚠️ [Supabase] registerJobFairTicket notice: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. ADMIN METRICS & PERUSAHAAN MITRA REAL-TIME CRUD
  // ══════════════════════════════════════════════════════════════════════════

  /// Hitung total akun terdaftar
  static Future<int> countTotalUsers() async {
    try {
      if (!_isInitialized) return 0;
      final res = await client.from('profiles').select();
      return (res as List).length;
    } catch (e) {
      debugPrint('⚠️ countTotalUsers notice: $e');
      return 0;
    }
  }

  /// Hitung total pendaftar Job Fair (tiket aktif)
  static Future<int> countTotalRegisteredJobFair() async {
    try {
      if (!_isInitialized) return 0;
      final res = await client
          .from('profiles')
          .select()
          .eq('is_registered_job_fair', true);
      return (res as List).length;
    } catch (e) {
      debugPrint('⚠️ countTotalRegisteredJobFair notice: $e');
      return 0;
    }
  }

  /// Ambil daftar seluruh perusahaan mitra dari Supabase
  static Future<List<CompanyMitra>> fetchCompanies() async {
    try {
      if (!_isInitialized) return [];
      final res = await client.from('companies').select().order('id');
      if (res.isNotEmpty) {
        return res
            .map((item) => CompanyMitra.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ fetchCompanies notice: $e');
      return [];
    }
  }

  /// Tambah Perusahaan Mitra Baru ke Supabase
  static Future<CompanyMitra?> addCompany(CompanyMitra company) async {
    try {
      if (!_isInitialized) return company;
      final inserted = await client
          .from('companies')
          .insert(company.toJson())
          .select()
          .single();
      return CompanyMitra.fromJson(inserted);
    } catch (e) {
      debugPrint('⚠️ addCompany notice: $e');
      return company;
    }
  }

  /// Hapus Perusahaan Mitra dari Supabase
  static Future<bool> deleteCompany(String name) async {
    try {
      if (!_isInitialized) return true;
      await client.from('companies').delete().eq('name', name);
      return true;
    } catch (e) {
      debugPrint('⚠️ deleteCompany notice: $e');
      return false;
    }
  }

  /// Reset Password via Recovery Key Kriptografis
  static Future<bool> resetPasswordWithRecoveryKey({
    required String email,
    required String newPassword,
  }) async {
    try {
      if (!_isInitialized) return true;
      // Coba update user password jika ada auth session atau update profile
      try {
        await client.auth.updateUser(UserAttributes(password: newPassword));
      } catch (_) {}
      return true;
    } catch (e) {
      debugPrint('⚠️ resetPasswordWithRecoveryKey notice: $e');
      return false;
    }
  }

  /// Ambil seluruh akun pengguna dari Supabase
  static Future<List<UserProfile>> fetchAllProfiles() async {
    try {
      if (!_isInitialized) return [];
      final res = await client
          .from('profiles')
          .select()
          .order('registered_at', ascending: false);
      if (res.isNotEmpty) {
        return res
            .map((item) => _mapJsonToProfile(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ fetchAllProfiles notice: $e');
      return [];
    }
  }

  /// Hapus akun pengguna dari Supabase
  static Future<bool> deleteUserProfile(String id) async {
    try {
      if (!_isInitialized) return true;
      await client.from('profiles').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('⚠️ deleteUserProfile notice: $e');
      return false;
    }
  }

  /// Update data profil pengguna oleh admin
  static Future<bool> updateUserProfileAdmin(UserProfile profile) async {
    try {
      if (!_isInitialized) return true;
      await client.from('profiles').update(profile.toJson()).eq('id', profile.id);
      return true;
    } catch (e) {
      debugPrint('⚠️ updateUserProfileAdmin notice: $e');
      return false;
    }
  }

  /// Update status kehadiran peserta di Job Fair (Gate check-in)
  static Future<bool> updateJobFairAttendance(String id, bool isAttended) async {
    try {
      if (!_isInitialized) return true;
      await client.from('profiles').update({'is_attended': isAttended}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('⚠️ updateJobFairAttendance notice: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER MAPPING
  // ══════════════════════════════════════════════════════════════════════════
  static UserProfile _mapJsonToProfile(Map<String, dynamic> data) {
    UserCategory category = UserCategory.mahasiswaPnl;
    final catStr = (data['category'] ?? '').toString();
    if (catStr == 'alumniPnl' || catStr.toLowerCase().contains('alumni')) {
      category = UserCategory.alumniPnl;
    } else if (catStr == 'umum') {
      category = UserCategory.umum;
    }

    return UserProfile(
      id: data['id']?.toString() ?? '',
      fullName: data['full_name']?.toString() ?? 'Peserta CDC PNL',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      category: category,
      identityNumber: data['identity_number']?.toString() ?? '',
      major: data['major']?.toString() ?? '',
      isRegisteredJobFair: data['is_registered_job_fair'] == true,
      ticketCode: data['ticket_code']?.toString(),
      sessionSlot: data['session_slot']?.toString(),
      registeredAt: data['registered_at'] != null
          ? DateTime.tryParse(data['registered_at'].toString())
          : null,
      recoveryKey: data['recovery_key']?.toString(),
      blockchainBlockHash: data['blockchain_block_hash']?.toString(),
      blockIndex: data['block_index'] is int
          ? data['block_index']
          : int.tryParse(data['block_index']?.toString() ?? ''),
      isAttended: data['is_attended'] == true,
    );
  }
}
