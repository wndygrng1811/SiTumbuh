<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = DB::table('users')
            ->where('email', $request->email)
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 401);
        }

        if ($user->password != $request->password) {
            return response()->json([
                'success' => false,
                'message' => 'Password salah'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'user_id' => $user->user_id,
            'nama' => $user->nama,
            'email' => $user->email,
            'role' => $user->role,
            'token' => 'login-token-' . $user->user_id
        ]);
    }
}
