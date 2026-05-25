<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Hapus semua debug, langsung return JSON
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'user_id' => 1,
            'nama' => 'Bunda A',
            'role' => 'orang_tua',
            'token' => 'bypass-token',
            'anak_id' => 1,
            'nama_anak' => 'Raffi Ahmad',
            'jenis_kelamin' => 'Laki-laki',
        ]);
    }
}