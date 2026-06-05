<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use App\Models\Pertumbuhan;
use App\Models\Anak;
use Carbon\Carbon;

class PertumbuhanController extends Controller
{
    public function getRiwayat($anakId)
    {
        // 🔥 JOIN dengan tabel jadwal untuk mendapatkan nama posyandu dan alamat
        $data = DB::table('pertumbuhan')
            ->leftJoin('jadwal', 'pertumbuhan.jadwal_id', '=', 'jadwal.jadwal_id')
            ->where('pertumbuhan.anak_id', $anakId)
            ->select(
                'pertumbuhan.*',
                'jadwal.nama_posyandu',
                'jadwal.alamat',
                'jadwal.waktu'
            )
            ->orderBy('pertumbuhan.created_at', 'desc')
            ->get();

        $hasil = [];

        foreach ($data as $item) {
            // Format tanggal
            $tanggal = now()->toDateString();
            if ($item->created_at) {
                $tanggal = date('Y-m-d', strtotime($item->created_at));
            }
            
            // Format tanggal untuk display (dd MM yyyy)
            $tanggalDisplay = date('d F Y', strtotime($item->created_at));
            
            // Dapatkan nama hari
            $hari = date('l', strtotime($item->created_at));
            $hariIndonesia = $this->getHariIndonesia($hari);
            
            $hasil[] = [
                'id' => (string) ($item->tumbuh_id ?? $item->id),
                'tanggal' => $tanggal,
                'tanggal_display' => $tanggalDisplay,
                'hari' => $hariIndonesia,
                'berat' => (float) ($item->berat_badan ?? 0),
                'tinggi' => (float) ($item->tinggi_badan ?? 0),
                'l_kepala' => (float) ($item->lingkar_kepala ?? 0),
                'status' => $item->status_gizi ?? 'Normal',
                'posyandu' => $item->nama_posyandu ?? 'Posyandu Melati',
                'alamat' => $item->alamat ?? 'Jl. Sejahtera RT 03 RW 06',
                'waktu' => $item->waktu ?? '08:00-11:00',
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $hasil
        ]);
    }

    private function getHariIndonesia($day)
    {
        $hari = [
            'Monday' => 'Senin',
            'Tuesday' => 'Selasa',
            'Wednesday' => 'Rabu',
            'Thursday' => 'Kamis',
            'Friday' => 'Jumat',
            'Saturday' => 'Sabtu',
            'Sunday' => 'Minggu',
        ];
        return $hari[$day] ?? 'Senin';
    }

    public function store(Request $request)
    {
        $request->validate([
            'anak_id' => 'required',
            'berat_badan' => 'required',
            'tinggi_badan' => 'required',
        ]);

        $now = now()->toDateTimeString();

        $tumbuhId = DB::table('pertumbuhan')->insertGetId([
            'anak_id' => $request->anak_id,
            'orangtua_id' => $request->orangtua_id ?? 1,
            'jadwal_id' => $request->jadwal_id ?? null,
            'berat_badan' => $request->berat_badan,
            'tinggi_badan' => $request->tinggi_badan,
            'lingkar_kepala' => $request->lingkar_kepala ?? 0,
            'status_gizi' => $request->status_gizi ?? 'Normal',
            'created_at' => $now,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data berhasil disimpan',
            'data' => [
                'id' => $tumbuhId,
                'tanggal' => date('Y-m-d'),
                'berat' => (float) $request->berat_badan,
                'tinggi' => (float) $request->tinggi_badan,
                'l_kepala' => (float) ($request->lingkar_kepala ?? 0),
                'status' => $request->status_gizi ?? 'Normal'
            ]
        ]);
    }
}