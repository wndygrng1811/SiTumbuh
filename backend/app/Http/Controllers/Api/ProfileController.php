<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class ProfileController extends Controller
{
    /**
     * Get profile by orangtua_id or user_id
     */
    public function getProfile($id)
    {
        try {
            $user = DB::table('orang_tua')->where('orangtua_id', $id)->first();
            
            if (!$user) {
                $user = DB::table('orang_tua')->where('user_id', $id)->first();
            }
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'nama_lengkap' => $user->nama ?? '',
                    'email' => $user->email ?? '',
                    'no_hp' => $user->no_telp ?? '',
                    'alamat' => $user->alamat ?? '',
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get profile lengkap by orangtua_id or user_id
     */
    public function getProfileLengkap($id)
    {
        try {
            $user = DB::table('orang_tua')->where('orangtua_id', $id)->first();
            
            if (!$user) {
                $user = DB::table('orang_tua')->where('user_id', $id)->first();
            }
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'nama_lengkap' => $user->nama ?? '',
                    'email' => $user->email ?? '',
                    'no_hp' => $user->no_telp ?? '',
                    'alamat' => $user->alamat ?? '',
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Update profile lengkap (termasuk password dengan hash)
     */
    public function updateProfileLengkap(Request $request, $id)
    {
        try {
            Log::info('Update profile request: ' . json_encode($request->all()));
            
            // ============ CARI USER ============
            $user = DB::table('orang_tua')->where('orangtua_id', $id)->first();
            
            if (!$user) {
                $user = DB::table('orang_tua')->where('user_id', $id)->first();
            }
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan'
                ], 404);
            }
            
            $orangtuaId = $user->orangtua_id;
            $userId = $user->user_id;
            
            // ============ VALIDASI ============
            if ($request->has('email')) {
                $existingUser = DB::table('users')
                    ->where('email', $request->email)
                    ->where('user_id', '!=', $userId)
                    ->first();
                    
                if ($existingUser) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Email sudah digunakan oleh user lain'
                    ], 422);
                }
            }
            
            // ============ UPDATE TABEL ORANG_TUA ============
            $dataToUpdate = [];
            
            if ($request->has('nama_lengkap')) {
                $dataToUpdate['nama'] = $request->nama_lengkap;
            }
            if ($request->has('email')) {
                $dataToUpdate['email'] = $request->email;
            }
            if ($request->has('no_hp')) {
                $dataToUpdate['no_telp'] = $request->no_hp;
            }
            if ($request->has('alamat')) {
                $dataToUpdate['alamat'] = $request->alamat;
            }
            
            if (!empty($dataToUpdate)) {
                DB::table('orang_tua')
                    ->where('orangtua_id', $orangtuaId)
                    ->update($dataToUpdate);
            }
            
            // ============ UPDATE TABEL USERS (TERMASUK PASSWORD) ============
            $userDataToUpdate = [];
            
            if ($request->has('nama_lengkap')) {
                $userDataToUpdate['nama'] = $request->nama_lengkap;
            }
            
            if ($request->has('email')) {
                $userDataToUpdate['email'] = $request->email;
            }
            
            // ============ UPDATE PASSWORD DENGAN HASH ============
            if ($request->has('password') && !empty($request->password)) {
                $userDataToUpdate['password'] = Hash::make($request->password);
                Log::info('Password updated with hash');
            }
            
            if (!empty($userDataToUpdate)) {
                DB::table('users')
                    ->where('user_id', $userId)
                    ->update($userDataToUpdate);
            }
            
            Log::info('Profile updated successfully', [
                'orangtua_id' => $orangtuaId,
                'user_id' => $userId
            ]);
            
            // ============ AMBIL DATA TERBARU ============
            $updatedUser = DB::table('orang_tua')
                ->where('orangtua_id', $orangtuaId)
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diupdate',
                'data' => [
                    'nama_lengkap' => $updatedUser->nama ?? '',
                    'email' => $updatedUser->email ?? '',
                    'no_hp' => $updatedUser->no_telp ?? '',
                    'alamat' => $updatedUser->alamat ?? '',
                ]
            ]);
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error update profile: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}