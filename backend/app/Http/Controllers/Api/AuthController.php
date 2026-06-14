<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

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

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password salah'
            ], 401);
        }

        $responseData = [
            'success' => true,
            'message' => 'Login berhasil',
            'user_id' => $user->user_id,
            'nama' => $user->nama,
            'email' => $user->email,  // ← PASTIKAN INI ADA
            'role' => $user->role,
            'token' => 'login-token-' . $user->user_id
        ];

        if ($user->role == 'orang_tua') {
            $orangTua = DB::table('orang_tua')
                ->where('user_id', $user->user_id)
                ->first();

            if ($orangTua) {
                $anak = DB::table('anak')
                    ->where('orangtua_id', $orangTua->orangtua_id)
                    ->first();

                if ($anak) {
                    $responseData['anak_id'] = $anak->anak_id;
                    $responseData['nama_anak'] = $anak->nama;
                    $responseData['jenis_kelamin'] = $anak->jenis_kelamin;
                }
            }
        }

        return response()->json($responseData);
    }

    // ============ REGISTER ============
    public function register(Request $request)
    {
        try {
            $validated = $request->validate([
                'nama_orangtua' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|min:6',
                'alamat' => 'required|string',
                'no_telp' => 'required|string|max:15',
                'nama_anak' => 'required|string|max:255',
                'jenis_kelamin' => 'required|in:Laki-laki,Perempuan,L,P',
                'tanggal_lahir' => 'required|date'
            ]);

            DB::beginTransaction();

            $jk = $request->jenis_kelamin;
            if ($jk == 'Laki-laki' || $jk == 'L') {
                $jk = 'L';
            } else {
                $jk = 'P';
            }

            $userId = DB::table('users')->insertGetId([
                'nama' => $request->nama_orangtua,
                'email' => $request->email,
                'password' => bcrypt($request->password),
                'role' => 'orang_tua',
                'created_at' => now()
            ]);

            $orangTuaId = DB::table('orang_tua')->insertGetId([
                'nama' => $request->nama_orangtua,
                'email' => $request->email,
                'alamat' => $request->alamat,
                'no_telp' => $request->no_telp,
                'user_id' => $userId,
                'created_at' => now()
            ]);

            DB::table('anak')->insert([
                'orangtua_id' => $orangTuaId,
                'nama' => $request->nama_anak,
                'jenis_kelamin' => $jk,
                'tanggal_lahir' => $request->tanggal_lahir,
                'created_at' => now()
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil! Silakan login.'
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}