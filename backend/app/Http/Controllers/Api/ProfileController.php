<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\OrangTua;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function getProfile($userId)
    {
        $orangTua = OrangTua::where('user_id', $userId)->first();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'nama_lengkap' => $orangTua->nama,
                'email' => $orangTua->email,
                'no_hp' => $orangTua->no_telp,
                'alamat' => $orangTua->alamat,
            ]
        ]);
    }
    
    public function getProfileLengkap($userId)
    {
        $orangTua = OrangTua::where('user_id', $userId)->first();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'nama_lengkap' => $orangTua->nama,
                'email' => $orangTua->email,
                'no_hp' => $orangTua->no_telp,
                'alamat' => $orangTua->alamat,
            ]
        ]);
    }
    
    public function updateProfileLengkap(Request $request, $userId)
    {
        $orangTua = OrangTua::where('user_id', $userId)->first();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }
        
        // Update tabel orang_tua
        DB::table('orang_tua')
            ->where('user_id', $userId)
            ->update([
                'nama' => $request->nama_lengkap,
                'email' => $request->email,
                'no_telp' => $request->no_hp,
                'alamat' => $request->alamat,
            ]);
        
        // UPDATE TABEL USERS
        DB::table('users')
            ->where('user_id', $userId)
            ->update([
                'nama' => $request->nama_lengkap,
                'email' => $request->email,
            ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diupdate'
        ]);
    }
}