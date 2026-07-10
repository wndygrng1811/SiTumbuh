<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardKaderController extends Controller
{
    public function getStatistik(Request $request)
    {
        try {
            $jumlahAnak = DB::table('anak')->count();

            $jumlahOrangTua = DB::table('orang_tua')->count();

            $jumlahPemantauan = DB::table('pertumbuhan')->count();

            $jumlahKehadiran = DB::table('pertumbuhan')
                ->whereMonth('created_at', date('m'))
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'jumlah_anak' => $jumlahAnak,
                    'jumlah_orang_tua' => $jumlahOrangTua,
                    'jumlah_pemantauan' => $jumlahPemantauan,
                    'jumlah_kehadiran' => $jumlahKehadiran,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
    public function getJadwalTerdekat()
    {
        try {

            $jadwal = DB::table('jadwal')
                ->whereDate('tanggal', '>=', now()->toDateString())
                ->orderBy('tanggal', 'asc')
                ->first();

            if (!$jadwal) {
                return response()->json([
                    'success' => true,
                    'data' => null
                ]);
            }

            $waktuMulai = $jadwal->waktu;
            $waktuSelesai = '';

            if (str_contains($jadwal->waktu, '-')) {
                $waktu = explode('-', $jadwal->waktu);
                $waktuMulai = trim($waktu[0]);
                $waktuSelesai = trim($waktu[1]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'tanggal' => date('d F Y', strtotime($jadwal->tanggal)),
                    'waktu_mulai' => $waktuMulai,
                    'waktu_selesai' => $waktuSelesai,
                    'lokasi' => $jadwal->alamat,
                    'kegiatan' => $jadwal->nama_posyandu,
                ]
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);

        }
    }
    public function getProfilKader(Request $request, $userId)
    {
        try {

            $kader = DB::table('kader')
                ->where('user_id', $userId)
                ->first();

            if ($kader) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'nama' => $kader->nama,
                        'email' => $kader->email,
                    ]
                ]);
            }

            $user = DB::table('users')
                ->where('user_id', $userId)
                ->first();

            if ($user) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'nama' => $user->nama,
                        'email' => $user->email,
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Kader tidak ditemukan'
            ], 404);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);

        }
    }
}