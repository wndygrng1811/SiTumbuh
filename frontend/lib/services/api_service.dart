import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl =
      "https://situmbuh-backend-production.up.railway.app/api";

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
    print('GET: $url');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));
      print('GET Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('POST: $url');
    print('Body: $body');

    try {
      final response = await http
          .post(Uri.parse(url), headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 30));
      print('POST Response: ${response.statusCode}');
      print('Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('POST Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('PUT: $url');
    print('Body: $body');

    try {
      final response = await http
          .put(Uri.parse(url), headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 30));
      print('PUT Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('PUT Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    print('DELETE: $url');

    try {
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));
      print('DELETE Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  // ============ AUTH (LOGIN) ============
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      print('Login URL: $url');
      print('Email: $email');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah',
        };
      }

      if (response.statusCode == 422) {
        String errorMessage = 'Email atau password salah';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            errorMessage = errors.values.first.first;
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {'success': false, 'message': errorMessage};
      }

      if (response.statusCode == 500) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('token', data['token'] ?? '');
          await prefs.setInt('user_id', data['user_id'] ?? 0);
          await prefs.setString('role', data['role'] ?? '');
          await prefs.setString('nama', data['nama'] ?? '');
          await prefs.setString('email', data['email'] ?? '');

          if (data['orangtua_id'] != null) {
            await prefs.setInt('orangtua_id', data['orangtua_id']);
          }

          await prefs.setInt('anak_id', data['anak_id'] ?? 0);
          await prefs.setString('nama_anak', data['nama_anak'] ?? '');
          await prefs.setString('jenis_kelamin', data['jenis_kelamin'] ?? '');

          print('Login berhasil. Role: ${data['role']}');
          print('orangtua_id: ${data['orangtua_id']}');

          return {
            'success': true,
            'role': data['role'] ?? '',
            'user_id': data['user_id'] ?? 0,
            'orangtua_id': data['orangtua_id'] ?? 0,
            'nama': data['nama'] ?? '',
            'email': data['email'] ?? '',
            'token': data['token'] ?? '',
            'anak_id': data['anak_id'] ?? 0,
            'nama_anak': data['nama_anak'] ?? '',
            'jenis_kelamin': data['jenis_kelamin'] ?? '',
            'message': data['message'] ?? 'Login berhasil',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Email atau password salah',
          };
        }
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal. Silakan coba lagi.',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa koneksi internet Anda.',
      };
    }
  }

  // ============ LOGOUT ============
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
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

  static Future<Map<String, dynamic>> getProfileOrangTuaById(
    int orangtuaId,
  ) async {
    try {
      final response = await get('/orangtua/profile/$orangtuaId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('Error getProfileOrangTuaById: $e');
      return {};
    }
  }

  // ============ PROFIL KADER ============
  // PERBAIKI: tambahkan parameter userId
  static Future<Map<String, dynamic>> getProfilKader(int userId) async {
    try {
      final response = await get(
        '/kader/profil-sederhana/$userId',
      ); // <- PERBAIKI
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

  // ============ STATISTIK KADER ============
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

  // ============ EDUKASI ============
  static Future<List<dynamic>> getEdukasi() async {
    try {
      final response = await get('/edukasi');
      print('Edukasi response status: ${response.statusCode}');
      print('Edukasi response body: ${response.body}');

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

  // ============ KELOLA ORANG TUA (KADER) ============
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

  // ============ KELOLA ANAK (KADER) ============
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

  // ============ NOTIFIKASI ============
  static Future<List<dynamic>> getNotifikasi({
    int? userId,
    String? role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = userId ?? prefs.getInt('user_id') ?? 1;
      final currentRole = role ?? prefs.getString('role') ?? '';

      final response = await get(
        '/notifikasi?user_id=$currentUserId&role=$currentRole',
      );

      print('Notifikasi response status: ${response.statusCode}');
      print('Notifikasi response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error get notifikasi: $e');
      return [];
    }
  }

  static Future<bool> markNotifikasiAsRead(int id, {int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = userId ?? prefs.getInt('user_id') ?? 1;

      final response = await put(
        '/notifikasi/$id/read?user_id=$currentUserId',
        {},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error mark notifikasi: $e');
      return false;
    }
  }

  static Future<bool> markAllNotifikasiAsRead({int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = userId ?? prefs.getInt('user_id') ?? 1;
      final currentRole = prefs.getString('role') ?? '';

      final response = await put(
        '/notifikasi/read-all?user_id=$currentUserId&role=$currentRole',
        {},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error mark all notifikasi: $e');
      return false;
    }
  }
}
