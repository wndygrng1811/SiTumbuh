<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LaporanController extends Controller
{
    public function getAllPertumbuhan(Request $request)
    {
        try {
            $bulan = $request->query('bulan');
            $tahun = $request->query('tahun');

            $query = DB::table('pertumbuhan')
                ->join('anak', 'pertumbuhan.anak_id', '=', 'anak.anak_id')
                ->join('orang_tua', 'anak.orangtua_id', '=', 'orang_tua.orangtua_id')
                ->select(
                    'pertumbuhan.*',
                    'anak.nama as nama_anak',
                    'anak.jenis_kelamin',
                    'anak.tanggal_lahir',
                    'orang_tua.nama as nama_ortu'
                );

            if ($bulan && $tahun) {
                $query->whereMonth('pertumbuhan.created_at', $bulan)
                      ->whereYear('pertumbuhan.created_at', $tahun);
            }

            $query->whereRaw('pertumbuhan.created_at = (
                SELECT MAX(created_at) 
                FROM pertumbuhan p 
                WHERE p.anak_id = pertumbuhan.anak_id 
                AND MONTH(p.created_at) = ' . ($bulan ?: 'MONTH(pertumbuhan.created_at)') . '
                AND YEAR(p.created_at) = ' . ($tahun ?: 'YEAR(pertumbuhan.created_at)') . '
            )');

            $data = $query->orderBy('anak.nama')->get();

            return response()->json([
                'success' => true,
                'message' => 'Data pertumbuhan berhasil diambil',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }
}