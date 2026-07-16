<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class KategoriController extends Controller
{
    // GET semua kategori
    public function index()
    {
        try {
            $kategori = DB::table('kategori')->orderBy('created_at', 'desc')->get();
            
            $formattedData = $kategori->map(function($item) {
                return [
                    'id' => (int)$item->id,
                    'nama' => $item->nama,
                    'status' => $item->status ?? 'Draft',
                    'created_at' => $item->created_at,
                    'updated_at' => $item->updated_at,
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => $formattedData
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // POST tambah kategori
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nama' => 'required|string|min:3|max:100|unique:kategori,nama',
                'status' => 'required|in:Draft,Dipublikasikan',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => $validator->errors()->first()
                ], 422);
            }
            
            $data = [
                'nama' => $request->nama,
                'status' => $request->status ?? 'Draft',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            
            $id = DB::table('kategori')->insertGetId($data);
            
            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil ditambahkan',
                'data' => ['id' => $id]
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan kategori: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // PUT update kategori
    public function update(Request $request, $id)
    {
        try {
            $kategori = DB::table('kategori')->where('id', $id)->first();
            
            if (!$kategori) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kategori tidak ditemukan'
                ], 404);
            }
            
            $validator = Validator::make($request->all(), [
                'nama' => 'required|string|min:3|max:100|unique:kategori,nama,' . $id,
                'status' => 'required|in:Draft,Dipublikasikan',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => $validator->errors()->first()
                ], 422);
            }
            
            $data = [
                'nama' => $request->nama,
                'status' => $request->status ?? 'Draft',
                'updated_at' => now(),
            ];
            
            DB::table('kategori')->where('id', $id)->update($data);
            
            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil diupdate'
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal update kategori: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // DELETE kategori
    public function destroy($id)
    {
        try {
            $kategori = DB::table('kategori')->where('id', $id)->first();
            
            if (!$kategori) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kategori tidak ditemukan'
                ], 404);
            }
            
            // Cek apakah ada edukasi yang menggunakan kategori ini
            $edukasiCount = DB::table('edukasi')->where('kategori_id', $id)->count();
            
            if ($edukasiCount > 0) {
                return response()->json([
                    'success' => false,
                    'message' => "Kategori tidak bisa dihapus karena masih digunakan oleh $edukasiCount edukasi. Hapus edukasi terlebih dahulu."
                ], 400);
            }
            
            DB::table('kategori')->where('id', $id)->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil dihapus'
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal hapus kategori: ' . $e->getMessage()
            ], 500);
        }
    }
}