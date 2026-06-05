<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProfileController extends Controller
{
    public function getProfile($userId)
    {
        try {
            $user = DB::table('orang_tua')->where('orangtua_id', $userId)->first();
            
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
    
    public function getProfileLengkap($userId)
    {
        try {
            $user = DB::table('orang_tua')->where('orangtua_id', $userId)->first();
            
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
    
    public function updateProfileLengkap(Request $request, $userId)
    {
        try {
            Log::info('Update profile request: ' . json_encode($request->all()));
            
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
            
            if (empty($dataToUpdate)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak ada data yang diupdate'
                ], 400);
            }
            
            $user = DB::table('orang_tua')->where('orangtua_id', $userId)->first();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan'
                ], 404);
            }
            
            $updated = DB::table('orang_tua')
                ->where('orangtua_id', $userId)
                ->update($dataToUpdate);
            
            if ($updated) {
                return response()->json([
                    'success' => true,
                    'message' => 'Profil berhasil diupdate',
                    'data' => [
                        'nama_lengkap' => $dataToUpdate['nama'] ?? '',
                        'email' => $dataToUpdate['email'] ?? '',
                        'no_hp' => $dataToUpdate['no_telp'] ?? '',
                        'alamat' => $dataToUpdate['alamat'] ?? '',
                    ]
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal mengupdate profil'
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('Error update profile: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}