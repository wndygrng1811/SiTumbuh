class NotifikasiModel {
  final int id;
  final String judul;
  final String isi;
  final String jenis;
  final String? gambar;
  final String? link;
  final String targetRole;
  final bool isRead;
  final DateTime createdAt;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.jenis,
    this.gambar,
    this.link,
    required this.targetRole,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      jenis: json['jenis'] ?? 'pengumuman',
      gambar: json['gambar'],
      link: json['link'],
      targetRole: json['target_role'] ?? 'semua',
      isRead: json['is_read'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'jenis': jenis,
      'gambar': gambar,
      'link': link,
      'target_role': targetRole,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
