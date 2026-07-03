class EdukasiModel {
  String id;
  String title;
  String kategoriId;
  String desc;
  String status;
  String youtubeUrl;
  String jenisKonten;
  String? image;

  EdukasiModel({
    required this.id,
    required this.title,
    required this.kategoriId,
    required this.desc,
    required this.status,
    this.youtubeUrl = '',
    this.jenisKonten = 'artikel',
    this.image,
  });

  factory EdukasiModel.fromJson(Map<String, dynamic> json) {
    return EdukasiModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      kategoriId: json['kategori_id'].toString(),
      desc: json['desc'] ?? '',
      status: json['status'] ?? 'Draft',
      youtubeUrl: json['youtube_url'] ?? '',
      jenisKonten: json['jenis_konten'] ?? 'artikel',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'kategori_id': kategoriId,
      'desc': desc,
      'status': status,
      'youtube_url': youtubeUrl,
      'jenis_konten': jenisKonten,
    };
  }
}