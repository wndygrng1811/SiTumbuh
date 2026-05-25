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
        $data = DB::table('pertumbuhan')
            ->where('anak_id', $anakId)
            ->orderBy('created_at', 'asc')
            ->get();

        $hasil = [];

        foreach ($data as $item) {
            // kolom di database adalah 'tumbuh_id'
            $tanggal = now()->toDateString();
            if ($item->created_at) {
                $tanggal = date('Y-m-d', strtotime($item->created_at));
            }
            
            $hasil[] = [
                'id' => (string) ($item->tumbuh_id ?? $item->id),
                'tanggal' => $tanggal,
                'berat' => (float) ($item->berat_badan ?? 0),
                'tinggi' => (float) ($item->tinggi_badan ?? 0),
                'l_kepala' => (float) ($item->lingkar_kepala ?? 0),
                'status' => $item->status_gizi ?? 'Normal'
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $hasil
        ]);
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
            'jadwal_id' => $request->jadwal_id ?? 1,
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