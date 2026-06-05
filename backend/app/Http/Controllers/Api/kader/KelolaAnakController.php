<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KelolaAnakController extends Controller
{
    // GET SEMUA ANAK (untuk kader)
    public function index()
    {
        try {
            $anak = DB::table('anak')
                ->join('orang_tua', 'anak.orangtua_id', '=', 'orang_tua.orangtua_id')
                ->select(
                    'anak.anak_id',
                    'anak.nama as nama_anak',
                    'anak.jenis_kelamin',
                    'anak.tanggal_lahir',
                    'anak.berat_badan',
                    'anak.tinggi_badan',
                    'anak.lingkar_kepala',
                    'anak.status_gizi',
                    'orang_tua.orangtua_id',
                    'orang_tua.nama as nama_ortu'
                )
                ->orderBy('anak.nama')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // GET DETAIL ANAK BY ID
    public function show($id)
    {
        try {
            $anak = DB::table('anak')
                ->join('orang_tua', 'anak.orangtua_id', '=', 'orang_tua.orangtua_id')
                ->select(
                    'anak.anak_id',
                    'anak.nama as nama_anak',
                    'anak.jenis_kelamin',
                    'anak.tanggal_lahir',
                    'anak.berat_badan',
                    'anak.tinggi_badan',
                    'anak.lingkar_kepala',
                    'anak.status_gizi',
                    'orang_tua.orangtua_id',
                    'orang_tua.nama as nama_ortu'
                )
                ->where('anak.anak_id', $id)
                ->first();

            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // TAMBAH ANAK
    public function store(Request $request)
    {
        try {
            $request->validate([
                'orangtua_id' => 'required|integer',
                'nama' => 'required|string|max:100',
                'jenis_kelamin' => 'required|in:L,P',
                'tanggal_lahir' => 'required|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
            ]);

            $anakId = DB::table('anak')->insertGetId([
                'orangtua_id' => $request->orangtua_id,
                'nama' => $request->nama,
                'jenis_kelamin' => $request->jenis_kelamin,
                'tanggal_lahir' => $request->tanggal_lahir,
                'berat_badan' => $request->berat_badan ?? 0,
                'tinggi_badan' => $request->tinggi_badan ?? 0,
                'lingkar_kepala' => $request->lingkar_kepala ?? 0,
                'status_gizi' => 'Normal',
                'created_at' => now()
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil ditambahkan',
                'data' => ['anak_id' => $anakId]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // UPDATE ANAK
    public function update(Request $request, $id)
    {
        try {
            $request->validate([
                'nama' => 'sometimes|string|max:100',
                'jenis_kelamin' => 'sometimes|in:L,P',
                'tanggal_lahir' => 'sometimes|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
                'status_gizi' => 'nullable|string|max:20'
            ]);

            $updateData = [];
            if ($request->has('nama')) $updateData['nama'] = $request->nama;
            if ($request->has('jenis_kelamin')) $updateData['jenis_kelamin'] = $request->jenis_kelamin;
            if ($request->has('tanggal_lahir')) $updateData['tanggal_lahir'] = $request->tanggal_lahir;
            if ($request->has('berat_badan')) $updateData['berat_badan'] = $request->berat_badan;
            if ($request->has('tinggi_badan')) $updateData['tinggi_badan'] = $request->tinggi_badan;
            if ($request->has('lingkar_kepala')) $updateData['lingkar_kepala'] = $request->lingkar_kepala;
            if ($request->has('status_gizi')) $updateData['status_gizi'] = $request->status_gizi;
            
            $updateData['updated_at'] = now();

            $updated = DB::table('anak')
                ->where('anak_id', $id)
                ->update($updateData);

            if ($updated) {
                return response()->json([
                    'success' => true,
                    'message' => 'Data anak berhasil diupdate'
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Gagal update data'
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // HAPUS ANAK
    public function destroy($id)
    {
        try {
            // Hapus data pertumbuhan terkait dulu
            DB::table('pertumbuhan')->where('anak_id', $id)->delete();
            
            // Hapus data anak
            DB::table('anak')->where('anak_id', $id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil dihapus'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    // GET ANAK BY ORANGTUA ID
    public function getByOrangtua($orangtuaId)
    {
        try {
            $anak = DB::table('anak')
                ->where('orangtua_id', $orangtuaId)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}