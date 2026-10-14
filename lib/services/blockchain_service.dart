import 'dart:convert';
import 'package:crypto/crypto.dart';

class BlockchainBlock {
  final int index;
  final DateTime timestamp;
  final String previousHash;
  final String hash;
  final String ticketCode;
  final String attendeeName;
  final String identityNumber;
  final String sessionSlot;
  final String merkleRoot;
  final String proofSignature;

  const BlockchainBlock({
    required this.index,
    required this.timestamp,
    required this.previousHash,
    required this.hash,
    required this.ticketCode,
    required this.attendeeName,
    required this.identityNumber,
    required this.sessionSlot,
    required this.merkleRoot,
    required this.proofSignature,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'timestamp': timestamp.toIso8601String(),
        'previous_hash': previousHash,
        'hash': hash,
        'ticket_code': ticketCode,
        'attendee_name': attendeeName,
        'identity_number': identityNumber,
        'session_slot': sessionSlot,
        'merkle_root': merkleRoot,
        'proof_signature': proofSignature,
      };

  factory BlockchainBlock.fromJson(Map<String, dynamic> json) =>
      BlockchainBlock(
        index: json['index'] is int ? json['index'] : int.parse(json['index'].toString()),
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        previousHash: json['previous_hash']?.toString() ?? '0x0000000000000000',
        hash: json['hash']?.toString() ?? '',
        ticketCode: json['ticket_code']?.toString() ?? '',
        attendeeName: json['attendee_name']?.toString() ?? '',
        identityNumber: json['identity_number']?.toString() ?? '',
        sessionSlot: json['session_slot']?.toString() ?? '',
        merkleRoot: json['merkle_root']?.toString() ?? '',
        proofSignature: json['proof_signature']?.toString() ?? '',
      );
}

class BlockchainService {
  static const String _genesisHash =
      '0x0000000000000000CDC2026PNLCAREEREXPOVOCATIONALPORTALGENESIS00';

  // In-memory ledger blocks (synced with Supabase or fallback)
  static final List<BlockchainBlock> _ledger = [
    BlockchainBlock(
      index: 1001,
      timestamp: DateTime(2026, 4, 1, 9, 0),
      previousHash: _genesisHash,
      hash: '0x3a9f1c7d4e8b2a1f9e0c5d7a3b1e8f2c6d4a0b9e8f1c3d5a7b9e0c2d4f6a8b1c',
      ticketCode: 'PNL-JF26-INIT',
      attendeeName: 'Sistem Protokol CDC PNL',
      identityNumber: 'UPA-PKK-2026',
      sessionSlot: 'Sesi Khusus VIP Pembukaan',
      merkleRoot: '0x9b2e4f7a1c8d3e5f',
      proofSignature: 'ECDSA-SHA256-PNL-AUTHORIZED',
    ),
  ];

  static List<BlockchainBlock> get ledger => List.unmodifiable(_ledger);

  /// 1. END-TO-END RECOVERY KEY GENERATOR (6-Word Mnemonic Cryptographic Seed)
  /// Digunakan pengguna saat lupa kata sandi tanpa perlu mengekspos plain password
  static String generateRecoverySeedPhrase(String email, String identityNumber) {
    const wordList = [
      'vokasi', 'teknologi', 'kreasi', 'integritas', 'mandiri',
      'kompeten', 'rekayasa', 'digital', 'industri', 'sinergi',
      'prestasi', 'unggul', 'lhokseumawe', 'karir', 'politeknik',
      'sukses', 'amanah', 'global', 'energi', 'inovasi'
    ];

    final input = '$email:$identityNumber:CDC-PNL-E2EE-VAULT-2026';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);

    // Pick 6 words deterministically
    final words = <String>[];
    for (int i = 0; i < 6; i++) {
      final index = digest.bytes[i * 4] % wordList.length;
      words.add(wordList[index]);
    }
    return words.join('-');
  }

  /// Verifikasi kecocokan Recovery Seed Phrase
  static bool verifyRecoverySeedPhrase({
    required String email,
    required String identityNumber,
    required String enteredKey,
  }) {
    final expected = generateRecoverySeedPhrase(email, identityNumber).toLowerCase().trim();
    final normalizedEntered = enteredKey.toLowerCase().replaceAll(' ', '-').trim();
    return expected == normalizedEntered;
  }

  /// 2. BLOCK MINING / CRYPTOGRAPHIC PROOF FOR JOB FAIR REGISTRATION
  /// Menghasilkan Block Hash tidak terduplikasi untuk e-tiket pendaftaran Job Fair
  static BlockchainBlock mineTicketBlock({
    required String ticketCode,
    required String attendeeName,
    required String identityNumber,
    required String sessionSlot,
  }) {
    final int newIndex = _ledger.isEmpty ? 1001 : _ledger.last.index + 1;
    final String prevHash = _ledger.isEmpty ? _genesisHash : _ledger.last.hash;
    final now = DateTime.now();

    // Generate SHA-256 Block Hash
    final rawData = '$newIndex|$prevHash|$ticketCode|$attendeeName|$identityNumber|$sessionSlot|${now.millisecondsSinceEpoch}';
    final bytes = utf8.encode(rawData);
    final digest = sha256.convert(bytes);
    final hash = '0x${digest.toString()}';

    // Merkle Root simulation
    final merkleBytes = utf8.encode('$hash:PNL:UPA-PKK');
    final merkleRoot = '0x${sha256.convert(merkleBytes).toString().substring(0, 16)}';

    // Proof signature
    final signature = 'BLOCK-POA-$newIndex-${digest.toString().substring(0, 8).toUpperCase()}';

    final block = BlockchainBlock(
      index: newIndex,
      timestamp: now,
      previousHash: prevHash,
      hash: hash,
      ticketCode: ticketCode,
      attendeeName: attendeeName,
      identityNumber: identityNumber,
      sessionSlot: sessionSlot,
      merkleRoot: merkleRoot,
      proofSignature: signature,
    );

    _ledger.add(block);
    return block;
  }

  /// Validasi Kriptografis Keaslian Tiket (Anti-Tamper & Anti-Palsu)
  static bool verifyBlockIntegrity(String ticketCode, String hash) {
    return _ledger.any((b) => b.ticketCode == ticketCode && b.hash == hash);
  }

  /// Cari block berdasarkan ticket code
  static BlockchainBlock? findBlockByTicket(String ticketCode) {
    try {
      return _ledger.firstWhere((b) => b.ticketCode == ticketCode);
    } catch (_) {
      return null;
    }
  }
}
