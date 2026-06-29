import 'package:flutter/material.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifikasiPage extends StatefulWidget {
  final String role;

  const NotifikasiPage({super.key, required this.role});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<Map<String, dynamic>> _notifikasiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;
      final data = await ApiService.getNotifikasi(
        userId: userId,
        role: widget.role,
      );

      setState(() {
        _notifikasiList = data
            .map(
              (n) => {
                'id': n['id'],
                'judul': n['judul'],
                'isi': n['isi'],
                'jenis': n['jenis'],
                'is_read': n['is_read'] == 1,
                'created_at': n['created_at'],
                'link': n['link'],
                'target_role': n['target_role'],
              },
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error load notifikasi: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 1;
    await ApiService.markNotifikasiAsRead(id, userId: userId);
    setState(() {
      final index = _notifikasiList.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifikasiList[index]['is_read'] = true;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 1;
    await ApiService.markAllNotifikasiAsRead(userId: userId);
    setState(() {
      for (var n in _notifikasiList) {
        n['is_read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sudah dibaca'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTanggal(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Kemarin, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _getJenisIcon(String jenis) {
    switch (jenis) {
      case 'pemeriksaan':
        return 'P';
      case 'jadwal':
        return 'J';
      case 'edukasi':
        return 'E';
      case 'kader_tugas':
        return 'T';
      case 'kader_pengingat':
        return 'R';
      case 'kader_laporan':
        return 'L';
      case 'kader_verifikasi':
        return 'V';
      default:
        return 'N';
    }
  }

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'pemeriksaan':
        return Colors.blue.shade100;
      case 'jadwal':
        return Colors.orange.shade100;
      case 'edukasi':
        return Colors.green.shade100;
      case 'kader_tugas':
        return Colors.purple.shade100;
      case 'kader_pengingat':
        return Colors.red.shade100;
      case 'kader_laporan':
        return Colors.teal.shade100;
      case 'kader_verifikasi':
        return Colors.amber.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  void _handleNavigation(Map<String, dynamic> notifikasi) async {
    final jenis = notifikasi['jenis']?.toString() ?? '';
    final link = notifikasi['link']?.toString() ?? '';
    final id = notifikasi['id'];
    final role = widget.role;

    Navigator.pop(context, true);

    // ==================== ORANG TUA ====================
    if (role == 'orang_tua') {
      switch (jenis) {
        case 'jadwal':
        case 'jadwal_baru':
          // Kembali ke halaman utama (sudah ada jadwal di dashboard)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cek jadwal posyandu di halaman utama'),
              duration: Duration(seconds: 2),
            ),
          );
          break;

        case 'pemeriksaan':
        case 'penambahan_riwayat':
          final prefs = await SharedPreferences.getInstance();
          final anakId = prefs.getInt('anak_id') ?? 0;
          if (anakId != 0) {
            await Navigator.pushNamed(
              context,
              '/grafik',
              arguments: {
                'anakId': anakId,
                'fromNotification': true,
                'notificationId': id,
              },
            );
          }
          break;

        case 'edukasi':
        case 'edukasi_baru':
          String edukasiId = '';
          if (link.isNotEmpty) {
            final parts = link.split('/');
            if (parts.length > 2) {
              edukasiId = parts.last;
            }
          }
          await Navigator.pushNamed(
            context,
            '/edukasi',
            arguments: {
              'edukasiId': edukasiId,
              'fromNotification': true,
              'notificationId': id,
            },
          );
          break;

        default:
          if (link.isNotEmpty && link != '/') {
            try {
              await Navigator.pushNamed(
                context,
                link,
                arguments: {'fromNotification': true, 'notificationId': id},
              );
            } catch (e) {
              // Fallback
            }
          }
          break;
      }
      return;
    }

    // ==================== KADER ====================
    if (role == 'kader') {
      switch (jenis) {
        case 'jadwal':
        case 'jadwal_baru':
          await Navigator.pushNamed(
            context,
            '/jadwal',
            arguments: {'fromNotification': true, 'notificationId': id},
          );
          break;

        case 'kader_tugas':
        case 'kader_pengingat':
        case 'kader_laporan':
        case 'kader_verifikasi':
          await Navigator.pushNamed(
            context,
            '/kader/dashboard',
            arguments: {
              'fromNotification': true,
              'notificationId': id,
              'jenis': jenis,
            },
          );
          break;

        case 'edukasi':
        case 'edukasi_baru':
          String edukasiId = '';
          if (link.isNotEmpty) {
            final parts = link.split('/');
            if (parts.length > 2) {
              edukasiId = parts.last;
            }
          }
          await Navigator.pushNamed(
            context,
            '/edukasi',
            arguments: {
              'edukasiId': edukasiId,
              'fromNotification': true,
              'notificationId': id,
            },
          );
          break;

        default:
          if (link.isNotEmpty && link != '/') {
            try {
              await Navigator.pushNamed(
                context,
                link,
                arguments: {'fromNotification': true, 'notificationId': id},
              );
            } catch (e) {}
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifikasiList.where((n) => !n['is_read']).length;

    final title = widget.role == 'orang_tua'
        ? 'Notifikasi Saya'
        : 'Notifikasi Kader';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFE85D75),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Baca semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifikasiList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifikasiList.length,
              itemBuilder: (context, index) {
                final n = _notifikasiList[index];
                final isRead = n['is_read'] as bool;
                final jenis = n['jenis']?.toString() ?? '';

                return GestureDetector(
                  onTap: () async {
                    if (!isRead) {
                      await _markAsRead(n['id']);
                    }
                    _handleNavigation(n);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFFDE2E7),
                      borderRadius: BorderRadius.circular(16),
                      border: isRead
                          ? null
                          : Border.all(
                              color: const Color(0xFFE85D75),
                              width: 1.5,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getJenisColor(jenis),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getJenisIcon(jenis),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n['judul'],
                                style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['isi'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isRead
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatTanggal(n['created_at']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE85D75),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
