import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // PASTIKAN URL INI BENAR - harus diakhiri dengan /api
  // 🔥 GANTI DENGAN IP SESUAI KONEKSI KAMU
  static const String baseUrl = 'http://192.168.1.3:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('🌐 GET: $url');
    return await http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('📤 POST: $url');
    print('📦 Body: $body');
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('✏️ PUT: $url');
    print('📦 Body: $body');
    return await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('🗑️ DELETE: $url');
    return await http.delete(Uri.parse(url), headers: headers);
  }

  // ============ AUTH (LOGIN) ============
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      print('📡 Login response status: ${response.statusCode}');
      print('📦 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token'] ?? '');
          await prefs.setInt('user_id', data['user_id'] ?? 0);
          await prefs.setString('role', data['role'] ?? '');
          await prefs.setString('nama', data['nama'] ?? '');
          await prefs.setInt('anak_id', data['anak_id'] ?? 0);
          await prefs.setString('nama_anak', data['nama_anak'] ?? '');
          await prefs.setString('jenis_kelamin', data['jenis_kelamin'] ?? '');

          return {'success': true, 'role': data['role'] ?? ''};
        }
      }
      return {'success': false, 'message': 'Login gagal'};
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ============ PROFIL KADER (PUNYA KAMU) ============
  static Future<Map<String, dynamic>> getProfilKader() async {
    try {
      final response = await get('/kader/profil');
      print('=== GET PROFIL KADER ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'data': data['data']};
        }
      }
      return {'success': false, 'message': 'Gagal mengambil data profil'};
    } catch (e) {
      print('Error getProfilKader: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateProfilKader({
    required String nama,
    required String email,
    required String alamat,
    required String noTelp,
  }) async {
    try {
      final response = await put('/kader/profil', {
        'nama': nama,
        'email': email,
        'alamat': alamat,
        'no_telp': noTelp,
      });

      print('=== UPDATE PROFIL KADER ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'data': data['data'],
        };
      }
      return {'success': false, 'message': 'Gagal update profil'};
    } catch (e) {
      print('Error updateProfilKader: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ============ STATISTIK KADER (PUNYA KAMU) ============
  static Future<Map<String, dynamic>> getStatistikKader() async {
    try {
      final response = await get('/kader/statistik');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false};
    } catch (e) {
      print('Error getStatistikKader: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getJadwalTerdekat() async {
    try {
      final response = await get('/kader/jadwal-terdekat');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false};
    } catch (e) {
      print('Error getJadwalTerdekat: $e');
      return {'success': false};
    }
  }

  // ============ PERTUMBUHAN (PUNYA TEMAN) ============
  static Future<List<dynamic>> getRiwayatPertumbuhan(int anakId) async {
    try {
      final response = await get('/pertumbuhan/$anakId');
      print('=== GET RIWAYAT ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error getRiwayatPertumbuhan: $e');
      return [];
    }
  }

  static Future<bool> simpanPertumbuhan({
    required int anakId,
    required double berat,
    required double tinggi,
    required double lingkarKepala,
    required String statusGizi,
  }) async {
    try {
      final response = await post('/pertumbuhan', {
        'anak_id': anakId,
        'berat_badan': berat,
        'tinggi_badan': tinggi,
        'lingkar_kepala': lingkarKepala,
        'status_gizi': statusGizi,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error simpan pertumbuhan: $e');
      return false;
    }
  }

  // ============ PROFIL ORANG TUA (PUNYA TEMAN) ============
  static Future<Map<String, dynamic>> getProfileOrangTua(int userId) async {
    try {
      final response = await get('/orangtua/profile/$userId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('Error getProfileOrangTua: $e');
      return {};
    }
  }

  // ============ EDUKASI (PUNYA TEMAN) ============
  static Future<List<dynamic>> getEdukasi() async {
    try {
      final response = await get('/edukasi');
      print('Edukasi response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error getEdukasi: $e');
      return [];
    }
  }

  // ============ DATA ANAK (PUNYA TEMAN) ============
  static Future<List<dynamic>> getDataAnak(int orangtuaId) async {
    try {
      final response = await get('/orangtua/$orangtuaId/anak');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error getDataAnak: $e');
      return [];
    }
  }

  static Future<bool> saveAnak(Map<String, dynamic> anakData) async {
    try {
      final response = await post('/anak', anakData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saveAnak: $e');
      return false;
    }
  }

  static Future<bool> updateAnak(
    int anakId,
    Map<String, dynamic> anakData,
  ) async {
    try {
      final response = await put('/anak/$anakId', anakData);
      return response.statusCode == 200;
    } catch (e) {
      print('Error updateAnak: $e');
      return false;
    }
  }

  static Future<bool> deleteAnak(int anakId) async {
    try {
      final response = await delete('/anak/$anakId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleteAnak: $e');
      return false;
    }
  }

  // ============ KELOLA ORANG TUA (PUNYA KAMU) ============
  static Future<http.Response> getOrangTua() async {
    return await get('/kader/orangtua');
  }

  static Future<http.Response> tambahOrangTua(Map<String, dynamic> data) async {
    return await post('/kader/tambah-orangtua', data);
  }

  static Future<http.Response> updateOrangTua(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await put('/kader/orangtua/$id', data);
  }

  static Future<http.Response> deleteOrangTua(int id) async {
    return await delete('/kader/orangtua/$id');
  }

  // ============ KELOLA ANAK (PUNYA KAMU) ============
  static Future<http.Response> getAllAnak() async {
    return await get('/kader/semua-anak');
  }

  static Future<http.Response> tambahAnak(Map<String, dynamic> data) async {
    return await post('/kader/anak', data);
  }

  static Future<http.Response> hapusAnak(int id) async {
    return await delete('/kader/anak/$id');
  }

  static Future<http.Response> getOrangTuaDropdown() async {
    return await get('/kader/orangtua');
  }
}
