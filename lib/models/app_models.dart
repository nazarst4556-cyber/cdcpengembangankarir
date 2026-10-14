enum UserCategory {
  mahasiswaPnl,
  alumniPnl,
  umum,
}

extension UserCategoryExtension on UserCategory {
  String get label {
    switch (this) {
      case UserCategory.mahasiswaPnl:
        return 'Mahasiswa Aktif PNL';
      case UserCategory.alumniPnl:
        return 'Alumni PNL';
      case UserCategory.umum:
        return 'Pencari Kerja Umum';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserCategory.mahasiswaPnl:
        return 'Mahasiswa PNL';
      case UserCategory.alumniPnl:
        return 'Alumni PNL';
      case UserCategory.umum:
        return 'Umum';
    }
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserCategory category;
  final String identityNumber; // NIM or NIK
  final String major; // Program Studi
  final bool isRegisteredJobFair;
  final String? ticketCode;
  final String? sessionSlot;
  final DateTime? registeredAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.category,
    required this.identityNumber,
    required this.major,
    this.isRegisteredJobFair = false,
    this.ticketCode,
    this.sessionSlot,
    this.registeredAt,
  });

  UserProfile copyWith({
    bool? isRegisteredJobFair,
    String? ticketCode,
    String? sessionSlot,
    DateTime? registeredAt,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      category: category,
      identityNumber: identityNumber,
      major: major,
      isRegisteredJobFair: isRegisteredJobFair ?? this.isRegisteredJobFair,
      ticketCode: ticketCode ?? this.ticketCode,
      sessionSlot: sessionSlot ?? this.sessionSlot,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}

class CompanyMitra {
  final String name;
  final String sector;
  final String boothNumber;
  final int openPositions;
  final String description;
  final String logoCode;

  const CompanyMitra({
    required this.name,
    required this.sector,
    required this.boothNumber,
    required this.openPositions,
    required this.description,
    required this.logoCode,
  });
}
