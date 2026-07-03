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
            'email' => $user->email,
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

    public function register(Request $request)
    {
        try {
            $validated = $request->validate([
                'nama_orangtua' => [
                    'required',
                    'string',
                    'min:3',
                    'max:100',
                    'regex:/^[A-Za-z\s]+$/'
                ],

                'email' => [
                    'required',
                    'email:rfc,dns',
                    'max:100',
                    'unique:users,email'
                ],

                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'max:20',
                    'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/'
                ],

                'alamat' => [
                    'required',
                    'string',
                    'min:10',
                    'max:255'
                ],

                'no_telp' => [
                    'required',
                    'digits_between:10,15',
                    'regex:/^08[0-9]+$/'
                ],

                'nama_anak' => [
                    'required',
                    'string',
                    'min:2',
                    'max:100',
                    'regex:/^[A-Za-z\s]+$/'
                ],

                'jenis_kelamin' => 'required|in:Laki-laki,Perempuan,L,P',

                'tanggal_lahir' => [
                    'required',
                    'date',
                    'before:today'
                ],
            ], [
                'nama_orangtua.required' => 'Nama orang tua harus diisi.',
                'nama_orangtua.regex' => 'Nama orang tua hanya boleh berisi huruf.',
                'nama_orangtua.min' => 'Nama orang tua minimal 3 karakter.',
                'nama_orangtua.max' => 'Nama orang tua maksimal 100 karakter.',

                'email.required' => 'Email harus diisi.',
                'email.email' => 'Format email tidak valid.',
                'email.unique' => 'Email sudah terdaftar.',
                'email.max' => 'Email maksimal 100 karakter.',

                'password.required' => 'Password harus diisi.',
                'password.min' => 'Password minimal 8 karakter.',
                'password.max' => 'Password maksimal 20 karakter.',
                'password.regex' => 'Password harus mengandung huruf besar, huruf kecil, dan angka.',

                'alamat.required' => 'Alamat harus diisi.',
                'alamat.min' => 'Alamat minimal 10 karakter.',
                'alamat.max' => 'Alamat maksimal 255 karakter.',

                'no_telp.required' => 'Nomor telepon harus diisi.',
                'no_telp.digits_between' => 'Nomor telepon harus terdiri dari 10 sampai 15 digit.',
                'no_telp.regex' => 'Nomor telepon harus diawali dengan 08.',

                'nama_anak.required' => 'Nama anak harus diisi.',
                'nama_anak.regex' => 'Nama anak hanya boleh berisi huruf.',
                'nama_anak.min' => 'Nama anak minimal 2 karakter.',
                'nama_anak.max' => 'Nama anak maksimal 100 karakter.',

                'jenis_kelamin.required' => 'Jenis kelamin harus dipilih.',
                'jenis_kelamin.in' => 'Jenis kelamin tidak valid.',

                'tanggal_lahir.required' => 'Tanggal lahir harus diisi.',
                'tanggal_lahir.date' => 'Format tanggal lahir tidak valid.',
                'tanggal_lahir.before' => 'Tanggal lahir harus sebelum hari ini.',
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

    public function logout(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }
}