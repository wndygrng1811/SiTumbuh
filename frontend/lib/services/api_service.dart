import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // PASTIKAN URL INI BENAR - harus diakhiri dengan /api
  static const String baseUrl = 'http://192.168.100.29:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json', // Tambahkan Accept header
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('GET URL: $url');
    return await http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('POST URL: $url');
    print('POST Body: $body');
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
    print('PUT URL: $url');
    print('PUT Body: $body');
    return await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('DELETE URL: $url');
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

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

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
      print('Login error: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ============ PERTUMBUHAN ============
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

  // ============ PROFIL ORANG TUA ============
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

  // ============ EDUKASI ============
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

  // ============ DATA ANAK ============
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
}
