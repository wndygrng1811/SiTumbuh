<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class KehadiranController extends Controller
{
    // 1. GET - Ambil semua jadwal
    public function getAllJadwal()
    {
        try {
            $today = date('Y-m-d');
            
            $jadwal = DB::table('jadwal')
                ->where('tanggal', '>=', $today)
                ->orderBy('tanggal', 'asc')
                ->get();

            Log::info('Jadwal ditemukan: ' . $jadwal->count());

            return response()->json([
                'success' => true,
                'message' => 'Data jadwal berhasil diambil',
                'data' => $jadwal
            ], 200);
        } catch (\Exception $e) {
            Log::error('Error getAllJadwal: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // 2. GET - Ambil kehadiran berdasarkan jadwal_id
    public function getKehadiranByJadwal($jadwalId)
    {
        try {
            // Ambil semua anak dengan join ke orang_tua
            $semuaAnak = DB::table('anak')
                ->leftJoin('orang_tua', 'anak.orangtua_id', '=', 'orang_tua.orangtua_id')
                ->select(
                    'anak.anak_id',
                    'anak.nama as nama_anak',
                    'anak.jenis_kelamin',
                    'orang_tua.nama as nama_ortu',
                    'orang_tua.no_telp as no_telp_ortu'
                )
                ->get();

            // Ambil data pertumbuhan berdasarkan jadwal_id
            $pertumbuhan = DB::table('pertumbuhan')
                ->where('jadwal_id', $jadwalId)
                ->get();

            $anakHadirIds = $pertumbuhan->pluck('anak_id')->toArray();

            $kehadiran = [];
            foreach ($semuaAnak as $anak) {
                $kehadiran[] = [
                    'anak_id' => $anak->anak_id,
                    'nama_anak' => $anak->nama_anak,
                    'jenis_kelamin' => $anak->jenis_kelamin,
                    'nama_ortu' => $anak->nama_ortu ?? '-',
                    'no_telp_ortu' => $anak->no_telp_ortu ?? '',
                    'hadir' => in_array($anak->anak_id, $anakHadirIds),
                    'jadwal_id' => $jadwalId
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Data kehadiran berhasil diambil',
                'data' => $kehadiran
            ], 200);
        } catch (\Exception $e) {
            Log::error('Error getKehadiranByJadwal: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // 3. POST - Simpan semua kehadiran (massal)
    public function simpanSemuaKehadiran(Request $request)
    {
        try {
            Log::info('=== simpanSemuaKehadiran dipanggil ===');
            
            $request->validate([
                'jadwal_id' => 'required|integer|exists:jadwal,jadwal_id',
                'kehadiran' => 'required|array',
                'kehadiran.*.anak_id' => 'required|integer|exists:anak,anak_id',
                'kehadiran.*.status' => 'required|in:hadir,tidak_hadir'
            ]);

            $jadwalId = $request->jadwal_id;

            DB::beginTransaction();

            foreach ($request->kehadiran as $item) {
                $existing = DB::table('kehadiran')
                    ->where('anak_id', $item['anak_id'])
                    ->where('jadwal_id', $jadwalId)
                    ->first();

                if ($existing) {
                    DB::table('kehadiran')
                        ->where('anak_id', $item['anak_id'])
                        ->where('jadwal_id', $jadwalId)
                        ->update([
                            'status' => $item['status']
                        ]);
                } else {
                    DB::table('kehadiran')->insert([
                        'anak_id' => $item['anak_id'],
                        'jadwal_id' => $jadwalId,
                        'status' => $item['status']
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data kehadiran berhasil disimpan'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error simpanSemuaKehadiran: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan: ' . $e->getMessage()
            ], 500);
        }
    }
}