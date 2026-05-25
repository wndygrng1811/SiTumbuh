class RiwayatPertumbuhan {
  final String id;
  final DateTime tanggal;
  final double berat;
  final double tinggi;
  final double lKepala;
  final String status;

  RiwayatPertumbuhan({
    required this.id,
    required this.tanggal,
    required this.berat,
    required this.tinggi,
    required this.lKepala,
    required this.status,
  });

  factory RiwayatPertumbuhan.fromJson(Map<String, dynamic> json) {
    return RiwayatPertumbuhan(
      id: json['id'].toString(),
      tanggal: DateTime.parse(json['tanggal_pengukuran'].toString()),
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
      lKepala: (json['lingkar_kepala'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Normal',
    );
  }
}

class KmsDataPoint {
  final int usia;
  final double sd3Neg;
  final double sd2Neg;
  final double sd0;
  final double sd2;
  final double sd3;

  KmsDataPoint({
    required this.usia,
    required this.sd3Neg,
    required this.sd2Neg,
    required this.sd0,
    required this.sd2,
    required this.sd3,
  });

  factory KmsDataPoint.fromJson(Map<String, dynamic> json) {
    return KmsDataPoint(
      usia: int.parse(json['usia'].toString()),
      sd3Neg: (json['sd3_neg'] ?? 0).toDouble(),
      sd2Neg: (json['sd2_neg'] ?? 0).toDouble(),
      sd0: (json['sd0'] ?? 0).toDouble(),
      sd2: (json['sd2'] ?? 0).toDouble(),
      sd3: (json['sd3'] ?? 0).toDouble(),
    );
  }
}
