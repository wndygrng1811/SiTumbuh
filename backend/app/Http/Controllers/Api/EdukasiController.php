<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EdukasiController extends Controller
{
    // GET semua data edukasi
    public function index()
    {
        $edukasi = DB::table('edukasi')->get();
        
        $formattedData = $edukasi->map(function($item) {
            return [
                'id' => $item->edukasi_id,
                'title' => $item->judul,
                'desc' => $item->isi,
                'kategori_id' => $item->kategori_id,
                'status' => $item->status ?? 'Draft',
            ];
        });
        
        return response()->json([
            'success' => true,
            'data' => $formattedData
        ]);
    }
    
    // GET detail edukasi by ID
    public function show($id)
    {
        $edukasi = DB::table('edukasi')->where('edukasi_id', $id)->first();
        
        if (!$edukasi) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ]);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $edukasi->edukasi_id,
                'title' => $edukasi->judul,
                'desc' => $edukasi->isi,
                'kategori_id' => $edukasi->kategori_id,
                'status' => $edukasi->status ?? 'Draft',
            ]
        ]);
    }
    
    // POST tambah edukasi baru (CREATE)
    public function store(Request $request)
    {
        $data = [
            'judul' => $request->judul,
            'isi' => $request->isi,
            'kategori_id' => $request->kategori_id,
            'status' => $request->status ?? 'Draft',
            'created_at' => now(),
            'updated_at' => now(),
        ];
        
        $id = DB::table('edukasi')->insertGetId($data);
        
        return response()->json([
            'success' => true,
            'message' => 'Edukasi berhasil ditambahkan'
        ]);
    }
    
    // PUT update edukasi (EDIT)
    public function update(Request $request, $id)
    {
        try {
            // Ambil data edukasi lama
            $edukasi = DB::table('edukasi')->where('edukasi_id', $id)->first();
            
            if (!$edukasi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data tidak ditemukan'
                ]);
            }
            
            $oldStatus = $edukasi->status;
            $newStatus = $request->status ?? $oldStatus;
            
            // Log untuk debug
            Log::info('Update Edukasi - ID: ' . $id);
            Log::info('Old Status: ' . $oldStatus);
            Log::info('New Status: ' . $newStatus);
            
            // Update data
            $data = [
                'judul' => $request->judul ?? $edukasi->judul,
                'isi' => $request->isi ?? $edukasi->isi,
                'kategori_id' => $request->kategori_id ?? $edukasi->kategori_id,
                'status' => $newStatus,
                'updated_at' => now(),
            ];
            
            DB::table('edukasi')->where('edukasi_id', $id)->update($data);
            
            // KIRIM NOTIFIKASI JIKA STATUS MENJADI DIPUBLIKASIKAN
            if ($newStatus == 'Dipublikasikan' && $oldStatus != 'Dipublikasikan') {
                Log::info('Mengirim notifikasi edukasi baru...');
                $this->sendNotifikasiEdukasiBaru($id, $request->judul ?? $edukasi->judul);
            } else {
                Log::info('Tidak mengirim notifikasi. Status tidak berubah ke Dipublikasikan.');
            }
            
            return response()->json([
                'success' => true,
                'message' => 'Edukasi berhasil diupdate'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error update edukasi: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // DELETE edukasi (HAPUS)
    public function destroy($id)
    {
        $edukasi = DB::table('edukasi')->where('edukasi_id', $id)->first();
        
        if (!$edukasi) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ]);
        }
        
        DB::table('edukasi')->where('edukasi_id', $id)->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Edukasi berhasil dihapus'
        ]);
    }
    
    // 🔥 FUNGSI KIRIM NOTIFIKASI EDUKASI BARU
    private function sendNotifikasiEdukasiBaru($edukasiId, $judul)
{
    try {
        $users = DB::table('users')->where('role', 'orang_tua')->get();
        
        Log::info('Jumlah user orang_tua: ' . $users->count());
        
        if ($users->isEmpty()) {
            Log::warning('Tidak ada user dengan role orang_tua!');
            return;
        }
        
        // Simpan notifikasi - PASTIKAN JENIS = 'edukasi' (pakai string biasa)
        $notifikasiId = DB::table('notifikasi')->insertGetId([
            'judul' => "Edukasi Baru 📚",
            'isi' => "Edukasi baru tentang \"$judul\" telah tersedia. Yuk pelajari untuk perkembangan si kecil!",
            'jenis' => 'edukasi',  // ← PASTIKAN STRING 'edukasi'
            'link' => "/edukasi/$edukasiId",
            'target_role' => 'orang_tua',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        Log::info('Notifikasi ID: ' . $notifikasiId);
        
        foreach ($users as $user) {
            DB::table('notifikasi_user')->insert([
                'notifikasi_id' => $notifikasiId,
                'user_id' => $user->user_id,
                'is_read' => 0,
                'created_at' => now(),
            ]);
            Log::info('Notifikasi untuk user_id: ' . $user->user_id);
        }
        
        Log::info('✅ Notifikasi edukasi berhasil dikirim ke ' . $users->count() . ' orang tua');
        
    } catch (\Exception $e) {
        Log::error('Gagal kirim notifikasi edukasi: ' . $e->getMessage());
    }
}
}