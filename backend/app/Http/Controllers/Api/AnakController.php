<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Anak;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AnakController extends Controller
{
    // Get detail anak by ID
    public function getDetail($anakId)
    {
        try {
            $anak = DB::table('anak')->where('anak_id', $anakId)->first();
            
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }
            
            // Konversi jenis kelamin untuk response
            $jk = $anak->jenis_kelamin;
            if ($jk == 'L') $jk = 'Laki-laki';
            if ($jk == 'P') $jk = 'Perempuan';
            
            return response()->json([
                'success' => true,
                'data' => [
                    'anak_id' => $anak->anak_id,
                    'nama_anak' => $anak->nama,
                    'jenis_kelamin' => $jk,
                    'tanggal_lahir' => $anak->tanggal_lahir,
                    'berat_badan' => $anak->berat_badan,
                    'tinggi_badan' => $anak->tinggi_badan,
                    'lingkar_kepala' => $anak->lingkar_kepala,
                    'status_gizi' => $anak->status_gizi ?? 'Normal',
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Error getDetail: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Get all anak by orangtua_id
    public function getDataAnak($orangtuaId)
    {
        try {
            $anak = DB::table('anak')
                ->where('orangtua_id', $orangtuaId)
                ->get();
            
            // Konversi jenis kelamin untuk setiap anak
            foreach ($anak as $a) {
                if ($a->jenis_kelamin == 'L') $a->jenis_kelamin = 'Laki-laki';
                if ($a->jenis_kelamin == 'P') $a->jenis_kelamin = 'Perempuan';
            }
            
            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            Log::error('Error getDataAnak: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Get riwayat kunjungan by anak_id
    public function getRiwayatKunjungan($anakId)
    {
        try {
            $riwayat = DB::table('pertumbuhan')
                ->where('anak_id', $anakId)
                ->orderBy('created_at', 'desc')
                ->get();
            
            return response()->json([
                'success' => true,
                'data' => $riwayat
            ]);
        } catch (\Exception $e) {
            Log::error('Error getRiwayatKunjungan: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Create new anak
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'orangtua_id' => 'required|integer',
                'nama' => 'required|string|max:255',
                'jenis_kelamin' => 'required|string',
                'tanggal_lahir' => 'required|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
                'status_gizi' => 'nullable|string',
            ]);

            // Konversi jenis kelamin ke format database (L/P) - HANYA 1 KARAKTER
            $jk = $validatedData['jenis_kelamin'];
            if ($jk == 'Laki-laki' || $jk == 'L') {
                $jk = 'L';
            } elseif ($jk == 'Perempuan' || $jk == 'P') {
                $jk = 'P';
            } else {
                $jk = 'L'; // default
            }

            $anakId = DB::table('anak')->insertGetId([
                'orangtua_id' => $validatedData['orangtua_id'],
                'nama' => $validatedData['nama'],
                'jenis_kelamin' => $jk,
                'tanggal_lahir' => $validatedData['tanggal_lahir'],
                'berat_badan' => $validatedData['berat_badan'] ?? 0,
                'tinggi_badan' => $validatedData['tinggi_badan'] ?? 0,
                'lingkar_kepala' => $validatedData['lingkar_kepala'] ?? 0,
                'status_gizi' => $validatedData['status_gizi'] ?? 'Normal',
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil ditambahkan',
                'data' => ['anak_id' => $anakId]
            ], 201);
        } catch (\Exception $e) {
            Log::error('Error store: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Update anak
    public function update(Request $request, $anakId)
    {
        try {
            Log::info('=== UPDATE ANAK ===');
            Log::info('Anak ID: ' . $anakId);
            Log::info('Request data: ' . json_encode($request->all()));
            
            // Cek apakah anak ada
            $anak = DB::table('anak')->where('anak_id', $anakId)->first();
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }
            
            $validatedData = $request->validate([
                'nama' => 'required|string|max:255',
                'jenis_kelamin' => 'required|string',
                'tanggal_lahir' => 'required|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
                'status_gizi' => 'nullable|string',
            ]);

            // Konversi jenis kelamin ke format database (L/P) - HANYA 1 KARAKTER
            $jk = $validatedData['jenis_kelamin'];
            if ($jk == 'Laki-laki' || $jk == 'L') {
                $jk = 'L';
            } elseif ($jk == 'Perempuan' || $jk == 'P') {
                $jk = 'P';
            } else {
                $jk = 'L'; // default
            }

            Log::info('Converted jenis_kelamin to: ' . $jk);

            $updated = DB::table('anak')
                ->where('anak_id', $anakId)
                ->update([
                    'nama' => $validatedData['nama'],
                    'jenis_kelamin' => $jk,
                    'tanggal_lahir' => $validatedData['tanggal_lahir'],
                    'berat_badan' => $validatedData['berat_badan'] ?? $anak->berat_badan ?? 0,
                    'tinggi_badan' => $validatedData['tinggi_badan'] ?? $anak->tinggi_badan ?? 0,
                    'lingkar_kepala' => $validatedData['lingkar_kepala'] ?? $anak->lingkar_kepala ?? 0,
                    'status_gizi' => $validatedData['status_gizi'] ?? $anak->status_gizi ?? 'Normal',
                ]);
            
            Log::info('Update result: ' . ($updated ? 'success' : 'failed'));
            
            if ($updated) {
                return response()->json([
                    'success' => true,
                    'message' => 'Data anak berhasil diupdate'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal mengupdate data anak'
                ], 500);
            }
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error update: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Delete anak
    public function destroy($anakId)
    {
        try {
            // Cek apakah anak ada
            $anak = DB::table('anak')->where('anak_id', $anakId)->first();
            
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }
            
            // Hapus data pertumbuhan terkait terlebih dahulu
            DB::table('pertumbuhan')->where('anak_id', $anakId)->delete();
            
            // Hapus data anak
            DB::table('anak')->where('anak_id', $anakId)->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            Log::error('Error destroy: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}