<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class KelolaOrangTuaController extends Controller
{
    // GET - Ambil semua data orang tua
    public function index()
    {
        try {
            $data = DB::table('orang_tua')
                ->orderBy('orangtua_id', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil diambil',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // POST - Tambah orang tua baru
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:100',
            'email' => 'required|email|unique:orang_tua,email|unique:users,email',
            'telepon' => 'nullable|string|max:15',
            'alamat' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Buat user dengan nama juga
            $userId = DB::table('users')->insertGetId([
                'nama' => $request->nama,
                'email' => $request->email,
                'password' => bcrypt('password123'),
                'role' => 'orang_tua'
            ]);

            // Buat orang tua
            $id = DB::table('orang_tua')->insertGetId([
                'nama' => $request->nama,
                'email' => $request->email,
                'no_telp' => $request->telepon,
                'alamat' => $request->alamat,
                'user_id' => $userId
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil ditambahkan',
                'data' => DB::table('orang_tua')->where('orangtua_id', $id)->first()
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan data: ' . $e->getMessage()
            ], 500);
        }
    }

    // PUT - Update data orang tua
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:100',
            'email' => 'required|email',
            'telepon' => 'nullable|string|max:15',
            'alamat' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            $orangTua = DB::table('orang_tua')->where('orangtua_id', $id)->first();
            if (!$orangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data orang tua tidak ditemukan'
                ], 404);
            }

            // 1. Update orang tua
            DB::table('orang_tua')
                ->where('orangtua_id', $id)
                ->update([
                    'nama' => $request->nama,
                    'email' => $request->email,
                    'no_telp' => $request->telepon,
                    'alamat' => $request->alamat
                ]);

            // 2. Update users (nama dan email)
            $userUpdated = false;
            if ($orangTua->user_id) {
                $affected = DB::table('users')
                    ->where('user_id', $orangTua->user_id)
                    ->update([
                        'nama' => $request->nama,
                        'email' => $request->email
                    ]);
                
                $userUpdated = $affected > 0;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil diubah',
                'user_updated' => $userUpdated,
                'user_id' => $orangTua->user_id
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah data: ' . $e->getMessage()
            ], 500);
        }
    }

    // DELETE - Hapus data orang tua
    public function destroy($id)
    {
        try {
            DB::beginTransaction();

            $orangTua = DB::table('orang_tua')->where('orangtua_id', $id)->first();
            if (!$orangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data orang tua tidak ditemukan'
                ], 404);
            }

            // Hapus user jika ada
            if ($orangTua->user_id) {
                DB::table('users')->where('user_id', $orangTua->user_id)->delete();
            }

            // Hapus orang tua
            DB::table('orang_tua')->where('orangtua_id', $id)->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil dihapus'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data: ' . $e->getMessage()
            ], 500);
        }
    }
}