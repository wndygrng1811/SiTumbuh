<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $email = $request->email;
        $password = $request->password;

        $user = User::where('email', $email)
            ->where('password', $password)
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        $anak = null;

        if ($user->role == 'orang_tua') {
            $anak = DB::table('anak')
                ->where('orangtua_id', $user->user_id)
                ->first();
        }

       return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'user_id' => $user->user_id,
            'nama' => $user->nama,
            'role' => $user->role,

            'anak_id' => $anak ? $anak->anak_id : null,
            'nama_anak' => $anak ? $anak->nama : null,  // ← pakai 'nama'
            'jenis_kelamin' => $anak ? $anak->jenis_kelamin : null,
        ]);
    }
}