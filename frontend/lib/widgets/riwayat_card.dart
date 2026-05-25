import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:si_tumbuh/models/pertumbuhan_model.dart';

class RiwayatCard extends StatelessWidget {
  final RiwayatPertumbuhan data;

  const RiwayatCard({super.key, required this.data});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color(0xFF4CAF50);
      case 'kurang':
        return const Color(0xFFFFC107);
      case 'lebih':
        return const Color(0xFFFF9800);
      case 'bgm':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tanggal + badge status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Color(0xFFD95F82),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatter.format(data.tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(data.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor(data.status).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: _statusColor(data.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Detail data pengukuran
            Row(
              children: [
                _buildMetrikItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Berat',
                  nilai: '${data.berat} kg',
                ),
                const SizedBox(width: 24),
                _buildMetrikItem(
                  icon: Icons.height_rounded,
                  label: 'Tinggi',
                  nilai: '${data.tinggi} cm',
                ),
              ],
            ),

            const SizedBox(height: 6),

            _buildMetrikItem(
              icon: Icons.circle_outlined,
              label: 'L. Kepala',
              nilai: '${data.lKepala} cm',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrikItem({
    required IconData icon,
    required String label,
    required String nilai,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          nilai,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
