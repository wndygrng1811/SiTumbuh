class KategoriModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  KategoriModel({
    required this.id,
    required this.nama,
    this.deskripsi = '',
    this.status = 'Draft',
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'Draft',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'deskripsi': deskripsi, 'status': status};
  }
}
