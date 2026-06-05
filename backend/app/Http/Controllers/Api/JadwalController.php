<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class JadwalController extends Controller
{
    public function index()
    {
        $jadwal = DB::table('jadwal')
            ->orderBy('tanggal', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $jadwal
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_posyandu' => 'required|string|max:255',
            'tanggal' => 'required|date',
            'waktu' => 'required|string',
            'alamat' => 'required|string',
            'template' => 'nullable|string',
        ]);

        $jadwalId = DB::table('jadwal')->insertGetId([
            'nama_posyandu' => $request->nama_posyandu,
            'tanggal' => $request->tanggal,
            'waktu' => $request->waktu,
            'alamat' => $request->alamat,
            'template' => $request->template,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil dibuat',
            'data' => ['jadwal_id' => $jadwalId]
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_posyandu' => 'required|string|max:255',
            'tanggal' => 'required|date',
            'waktu' => 'required|string',
            'alamat' => 'required|string',
            'template' => 'nullable|string',
        ]);

        DB::table('jadwal')
            ->where('jadwal_id', $id)
            ->update([
                'nama_posyandu' => $request->nama_posyandu,
                'tanggal' => $request->tanggal,
                'waktu' => $request->waktu,
                'alamat' => $request->alamat,
                'template' => $request->template,
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil diupdate'
        ]);
    }

    public function destroy($id)
    {
        DB::table('jadwal')->where('jadwal_id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil dihapus'
        ]);
    }
}