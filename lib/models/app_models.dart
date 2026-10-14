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
  final String? recoveryKey;
  final String? blockchainBlockHash;
  final int? blockIndex;
  final bool isAttended;

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
    this.recoveryKey,
    this.blockchainBlockHash,
    this.blockIndex,
    this.isAttended = false,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    UserCategory? category,
    String? identityNumber,
    String? major,
    bool? isRegisteredJobFair,
    String? ticketCode,
    String? sessionSlot,
    DateTime? registeredAt,
    String? recoveryKey,
    String? blockchainBlockHash,
    int? blockIndex,
    bool? isAttended,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      identityNumber: identityNumber ?? this.identityNumber,
      major: major ?? this.major,
      isRegisteredJobFair: isRegisteredJobFair ?? this.isRegisteredJobFair,
      ticketCode: ticketCode ?? this.ticketCode,
      sessionSlot: sessionSlot ?? this.sessionSlot,
      registeredAt: registeredAt ?? this.registeredAt,
      recoveryKey: recoveryKey ?? this.recoveryKey,
      blockchainBlockHash: blockchainBlockHash ?? this.blockchainBlockHash,
      blockIndex: blockIndex ?? this.blockIndex,
      isAttended: isAttended ?? this.isAttended,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'category': category.name,
        'identity_number': identityNumber,
        'major': major,
        'is_registered_job_fair': isRegisteredJobFair,
        'ticket_code': ticketCode,
        'session_slot': sessionSlot,
        'registered_at': registeredAt?.toIso8601String(),
        'recovery_key': recoveryKey,
        'blockchain_block_hash': blockchainBlockHash,
        'block_index': blockIndex,
        'is_attended': isAttended,
      };
}

class CompanyMitra {
  final String? id;
  final String name;
  final String sector;
  final String boothNumber;
  final int openPositions;
  final String description;
  final String logoCode;

  const CompanyMitra({
    this.id,
    required this.name,
    required this.sector,
    required this.boothNumber,
    required this.openPositions,
    required this.description,
    required this.logoCode,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'sector': sector,
        'booth_number': boothNumber,
        'open_positions': openPositions,
        'description': description,
        'logo_code': logoCode,
      };

  factory CompanyMitra.fromJson(Map<String, dynamic> json) => CompanyMitra(
        id: json['id']?.toString(),
        name: json['name']?.toString() ?? '',
        sector: json['sector']?.toString() ?? '',
        boothNumber: json['booth_number']?.toString() ?? '',
        openPositions: json['open_positions'] is int
            ? json['open_positions']
            : int.tryParse(json['open_positions']?.toString() ?? '1') ?? 1,
        description: json['description']?.toString() ?? '',
        logoCode: json['logo_code']?.toString() ?? 'PNL',
      );

  CompanyMitra copyWith({
    String? id,
    String? name,
    String? sector,
    String? boothNumber,
    int? openPositions,
    String? description,
    String? logoCode,
  }) {
    return CompanyMitra(
      id: id ?? this.id,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      boothNumber: boothNumber ?? this.boothNumber,
      openPositions: openPositions ?? this.openPositions,
      description: description ?? this.description,
      logoCode: logoCode ?? this.logoCode,
    );
  }
}
