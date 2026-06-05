<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KehadiranController extends Controller
{
    // 1. GET - Ambil semua jadwal
    public function getAllJadwal()
    {
        $jadwal = DB::table('jadwal')
            ->orderBy('tanggal', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data jadwal berhasil diambil',
            'data' => $jadwal
        ], 200);
    }

    // 2. GET - Ambil kehadiran berdasarkan jadwal_id (dari tabel pertumbuhan)
    public function getKehadiranByJadwal($jadwalId)
    {
        // Ambil semua anak
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

        // Daftar anak_id yang hadir (yang punya data pertumbuhan di jadwal ini)
        $anakHadirIds = $pertumbuhan->pluck('anak_id')->toArray();

        // Buat data kehadiran
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
    }
}