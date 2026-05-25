<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\OrangTua;

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
                'nama_lengkap' => $orangTua->nama_lengkap,
                'email' => $orangTua->email,
                'no_hp' => $orangTua->no_hp,
                'alamat' => $orangTua->alamat,
            ]
        ]);
    }
}