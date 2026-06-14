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
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 🔥 KIRIM NOTIFIKASI OTOMATIS KE ORANG TUA
        $this->sendNotifikasiJadwal($jadwalId, $request->nama_posyandu, $request->tanggal);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil dibuat',
            'data' => ['jadwal_id' => $jadwalId]
        ]);
    }

    private function sendNotifikasiJadwal($jadwalId, $namaPosyandu, $tanggal)
    {
        // Ambil semua user dengan role orang_tua
        $users = DB::table('users')->where('role', 'orang_tua')->get();

        $notifikasiId = DB::table('notifikasi')->insertGetId([
            'judul' => "Jadwal Posyandu Baru 📅",
            'isi' => "Jadwal posyandu \"$namaPosyandu\" akan dilaksanakan pada tanggal $tanggal. Jangan lupa datang ya!",
            'jenis' => 'jadwal',
            'link' => "/jadwal/$jadwalId",
            'target_role' => 'orang_tua',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        foreach ($users as $user) {
            DB::table('notifikasi_user')->insert([
                'notifikasi_id' => $notifikasiId,
                'user_id' => $user->user_id,
                'is_read' => 0,
                'created_at' => now(),
            ]);
        }
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
                'updated_at' => now(),
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