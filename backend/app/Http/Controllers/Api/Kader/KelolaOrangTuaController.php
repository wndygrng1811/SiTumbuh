<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use App\Mail\AkunBaruMail;

class KelolaOrangTuaController extends Controller
{
    // GET - Ambil semua data orang tua
    public function index()
    {
        try {
            Log::info('=== KelolaOrangTuaController@index dipanggil ===');

            $data = DB::table('orang_tua')
                ->select('orangtua_id', 'nama', 'email', 'no_telp', 'alamat')
                ->orderBy('nama')
                ->get();

            Log::info('Data orang tua ditemukan: ' . count($data));

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil diambil',
                'data' => $data
            ], 200);
        } catch (\Exception $e) {
            Log::error('Error KelolaOrangTuaController@index: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // POST - Tambah orang tua baru
    public function store(Request $request)
    {
        Log::info('=== KelolaOrangTuaController@store dipanggil ===');
        Log::info('Request data: ' . json_encode($request->all()));

        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:100',
            'email' => 'required|email|unique:orang_tua,email|unique:users,email',
            'telepon' => 'nullable|string|max:15',
            'alamat' => 'nullable|string',
            'password' => 'nullable|string|min:6',
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

            $plainPassword = $request->password ?? '123456';

            $userId = DB::table('users')->insertGetId([
                'nama' => $request->nama,
                'email' => $request->email,
                'password' => bcrypt($plainPassword),
                'role' => 'orang_tua'
            ]);

            $id = DB::table('orang_tua')->insertGetId([
                'nama' => $request->nama,
                'email' => $request->email,
                'no_telp' => $request->telepon,
                'alamat' => $request->alamat,
                'user_id' => $userId
            ]);

            DB::commit();

            // Kirim email notifikasi
            try {
                Mail::to($request->email)->send(new AkunBaruMail(
                    $request->nama,
                    $request->email,
                    $plainPassword,
                    null
                ));
            } catch (\Exception $mailError) {
                Log::error('Email gagal dikirim: ' . $mailError->getMessage());
            }

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil ditambahkan. Email notifikasi telah dikirim.',
                'data' => DB::table('orang_tua')->where('orangtua_id', $id)->first()
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error KelolaOrangTuaController@store: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan data: ' . $e->getMessage()
            ], 500);
        }
    }

    // PUT - Update data orang tua
    public function update(Request $request, $id)
    {
        Log::info('=== KelolaOrangTuaController@update dipanggil ===');
        Log::info('ID: ' . $id);
        Log::info('Request data: ' . json_encode($request->all()));

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

            DB::table('orang_tua')
                ->where('orangtua_id', $id)
                ->update([
                    'nama' => $request->nama,
                    'email' => $request->email,
                    'no_telp' => $request->telepon,
                    'alamat' => $request->alamat
                ]);

            if ($orangTua->user_id) {
                DB::table('users')
                    ->where('user_id', $orangTua->user_id)
                    ->update([
                        'nama' => $request->nama,
                        'email' => $request->email
                    ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil diubah'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error KelolaOrangTuaController@update: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah data: ' . $e->getMessage()
            ], 500);
        }
    }

    // DELETE - Hapus data orang tua
    public function destroy($id)
    {
        Log::info('=== KelolaOrangTuaController@destroy dipanggil ===');
        Log::info('ID: ' . $id);

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

            DB::table('orang_tua')->where('orangtua_id', $id)->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Data orang tua berhasil dihapus'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error KelolaOrangTuaController@destroy: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data: ' . $e->getMessage()
            ], 500);
        }
    }
}