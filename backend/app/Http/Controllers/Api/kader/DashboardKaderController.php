<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardKaderController extends Controller
{
    // GET STATISTIK DASHBOARD
    public function getStatistik(Request $request)
    {
        try {
            // Jumlah anak
            $jumlahAnak = DB::table('anak')->count();
            
            // Jumlah orang tua
            $jumlahOrangTua = DB::table('orang_tua')->count();
            
            // Jumlah pemantauan (data pertumbuhan)
            $jumlahPemantauan = DB::table('pertumbuhan')->count();
            
            // Jumlah kehadiran bulan ini (sementara pakai pemantauan bulan ini)
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
    
    // GET JADWAL POSYANDU TERDEKAT
    public function getJadwalTerdekat(Request $request)
    {
        try {
            // Cek apakah ada tabel jadwal_posyandu
            $hasTable = DB::table('information_schema.tables')
                ->where('table_schema', env('DB_DATABASE'))
                ->where('table_name', 'jadwal_posyandu')
                ->exists();
            
            if ($hasTable) {
                // Ambil jadwal terdekat dari database
                $jadwal = DB::table('jadwal_posyandu')
                    ->where('tanggal', '>=', date('Y-m-d'))
                    ->orderBy('tanggal', 'asc')
                    ->first();
                
                if ($jadwal) {
                    return response()->json([
                        'success' => true,
                        'data' => [
                            'tanggal' => date('d F Y', strtotime($jadwal->tanggal)),
                            'waktu_mulai' => $jadwal->waktu_mulai ?? '08:00',
                            'waktu_selesai' => $jadwal->waktu_selesai ?? '12:00',
                            'lokasi' => $jadwal->lokasi,
                            'kegiatan' => $jadwal->kegiatan,
                        ]
                    ]);
                }
            }
            
            // Data default jika tidak ada tabel atau data
            return response()->json([
                'success' => true,
                'data' => [
                    'tanggal' => date('d F Y', strtotime('+7 days')),
                    'waktu_mulai' => '08:00',
                    'waktu_selesai' => '12:00',
                    'lokasi' => 'Posyandu Mawar, RT 05 RW 03',
                    'kegiatan' => 'Penimbangan, Pengukuran, Imunisasi, Vitamin A',
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    // GET PROFIL KADER SEDERHANA
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
            
            // Jika tidak ditemukan, coba dari tabel users
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