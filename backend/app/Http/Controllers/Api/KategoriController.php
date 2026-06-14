<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KategoriController extends Controller
{
    // GET semua kategori
    public function index()
    {
        $kategori = DB::table('kategori')->get();
        
        $formattedData = $kategori->map(function($item) {
            return [
                'id' => (string)$item->id,
                'nama' => $item->nama,
                'deskripsi' => $item->deskripsi ?? '',
                'image' => $item->image ?? '',
                'status' => $item->status ?? 'Dipublikasikan',
            ];
        });
        
        return response()->json([
            'success' => true,
            'data' => $formattedData
        ]);
    }
    
    // POST tambah kategori
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|min:3|unique:kategori,nama',
        ]);
        
        $data = [
            'nama' => $request->nama,
            'deskripsi' => $request->deskripsi ?? '',
            'image' => $request->image ?? '',
            'status' => $request->status ?? 'Dipublikasikan',
            'created_at' => now(),
            'updated_at' => now(),
        ];
        
        $id = DB::table('kategori')->insertGetId($data);
        
        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil ditambahkan',
            'data' => ['id' => $id]
        ]);
    }
    
    // PUT update kategori
    public function update(Request $request, $id)
    {
        $kategori = DB::table('kategori')->where('id', $id)->first();
        
        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan'
            ]);
        }
        
        $data = [
            'nama' => $request->nama ?? $kategori->nama,
            'deskripsi' => $request->deskripsi ?? $kategori->deskripsi,
            'image' => $request->image ?? $kategori->image,
            'status' => $request->status ?? $kategori->status,
            'updated_at' => now(),
        ];
        
        DB::table('kategori')->where('id', $id)->update($data);
        
        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diupdate'
        ]);
    }
    
    // DELETE kategori (HAPUS) - dengan pengecekan relasi
    public function destroy($id)
    {
        $kategori = DB::table('kategori')->where('id', $id)->first();
        
        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan'
            ]);
        }
        
        // Cek apakah ada edukasi yang menggunakan kategori ini
        $edukasiCount = DB::table('edukasi')->where('kategori_id', $id)->count();
        
        if ($edukasiCount > 0) {
            return response()->json([
                'success' => false,
                'message' => "Kategori tidak bisa dihapus karena masih digunakan oleh $edukasiCount edukasi. Hapus edukasi terlebih dahulu."
            ]);
        }
        
        DB::table('kategori')->where('id', $id)->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil dihapus'
        ]);
    }
}