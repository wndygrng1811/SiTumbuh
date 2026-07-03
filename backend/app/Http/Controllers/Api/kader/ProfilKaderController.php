<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfilKaderController extends Controller
{
    // GET PROFIL KADER
    public function getProfil($userId)
    {
        try {
            // Cari data kader berdasarkan user_id
            $kader = DB::table('kader')
                ->where('user_id', $userId)
                ->first();

            if (!$kader) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data kader tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'nama' => $kader->nama,
                    'email' => $kader->email,
                    'alamat' => $kader->alamat,
                    'no_telp' => $kader->no_telp
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // UPDATE PROFIL KADER
    public function updateProfil(Request $request, $userId)
    {
        try {
            // Validasi input
            $request->validate([
                'nama' => 'required|string|max:100',
                'email' => 'required|email|max:100',
                'alamat' => 'required|string',
                'no_telp' => 'required|string|max:15'
            ]);

            // Cek apakah data kader ada
            $kader = DB::table('kader')
                ->where('user_id', $userId)
                ->first();

            if (!$kader) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data kader tidak ditemukan'
                ], 404);
            }

            // Update data kader
            DB::table('kader')
                ->where('user_id', $userId)
                ->update([
                    'nama' => $request->nama,
                    'email' => $request->email,
                    'alamat' => $request->alamat,
                    'no_telp' => $request->no_telp,
                ]);

            // Update tabel users
            DB::table('users')
                ->where('user_id', $userId)
                ->update([
                    'nama' => $request->nama,
                    'email' => $request->email,
                    'updated_at' => now(),
                ]);
                        return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diupdate',
                'data' => [
                    'nama' => $request->nama,
                    'email' => $request->email,
                    'alamat' => $request->alamat,
                    'no_telp' => $request->no_telp
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}