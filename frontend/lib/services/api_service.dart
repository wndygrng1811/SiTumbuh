import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.43.115:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ METHOD DASAR ============
  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  // ============ AUTH (LOGIN) ============
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('role', data['user']['role']);

        if (data['user']['role'] == 'orang_tua' && data['anak'] != null) {
          await prefs.setInt('anak_id', data['anak']['anak_id']);
          await prefs.setString('nama_anak', data['anak']['nama_anak']);
          await prefs.setString('jenis_kelamin', data['anak']['jenis_kelamin']);
        }

        return {'success': true, 'role': data['user']['role']};
      }

      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ============ PERTUMBUHAN ============
  static Future<List<dynamic>> getRiwayatPertumbuhan(int anakId) async {
    try {
      final response = await get('/pertumbuhan/$anakId');

      print('=== GET RIWAYAT ===');
      print('URL: /pertumbuhan/$anakId');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================');

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

  // ============ PERTUMBUHAN (untuk Kader/Input Data) ============
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

      print('=== SIMPAN PERTUMBUHAN ===');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      print('===========================');

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
      return {};
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
      return [];
    }
  }

  static Future<bool> saveAnak(Map<String, dynamic> anakData) async {
    try {
      final response = await post('/anak', anakData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
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
      return false;
    }
  }

  static Future<bool> deleteAnak(int anakId) async {
    try {
      final response = await delete('/anak/$anakId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
