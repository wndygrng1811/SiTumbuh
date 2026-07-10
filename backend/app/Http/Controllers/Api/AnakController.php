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
                    'orang_tua.nama as nama_ortu',
                    'orang_tua.orangtua_id',
                    'orang_tua.email',
                    'orang_tua.no_telp',
                    'orang_tua.alamat'
                )
                ->where('anak.anak_id', $anakId)
                ->first();
            
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }
            
            // Konversi jenis kelamin untuk response
            if ($anak->jenis_kelamin == 'L') {
                $anak->jenis_kelamin = 'Laki-laki';
            } elseif ($anak->jenis_kelamin == 'P') {
                $anak->jenis_kelamin = 'Perempuan';
            }
            
            return response()->json([
                'success' => true,
                'data' => $anak
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
                    'orang_tua.nama as nama_ortu'
                )
                ->where('anak.orangtua_id', $orangtuaId)
                ->get();
            
            foreach ($anak as $a) {
                if ($a->jenis_kelamin == 'L') {
                    $a->jenis_kelamin = 'Laki-laki';
                } elseif ($a->jenis_kelamin == 'P') {
                    $a->jenis_kelamin = 'Perempuan';
                }
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
                'orangtua_id' => 'required|integer|exists:orang_tua,orangtua_id',
                'nama' => 'required|string|max:255',
                'jenis_kelamin' => 'required|string',
                'tanggal_lahir' => 'required|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
                'status_gizi' => 'nullable|string',
            ]);

            $jk = $validatedData['jenis_kelamin'];
            if ($jk == 'Laki-laki' || $jk == 'L') {
                $jk = 'L';
            } elseif ($jk == 'Perempuan' || $jk == 'P') {
                $jk = 'P';
            } else {
                $jk = 'L';
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

            $jk = $validatedData['jenis_kelamin'];
            if ($jk == 'Laki-laki' || $jk == 'L') {
                $jk = 'L';
            } elseif ($jk == 'Perempuan' || $jk == 'P') {
                $jk = 'P';
            } else {
                $jk = 'L';
            }

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
            $anak = DB::table('anak')->where('anak_id', $anakId)->first();
            
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }
            
            DB::table('pertumbuhan')->where('anak_id', $anakId)->delete();
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

    // GET semua anak
    public function getAllAnak()
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
                    'orang_tua.nama as nama_ortu',
                    'anak.orangtua_id'
                )
                ->get();

            foreach ($anak as $a) {
                if ($a->jenis_kelamin == 'L') {
                    $a->jenis_kelamin = 'Laki-laki';
                } elseif ($a->jenis_kelamin == 'P') {
                    $a->jenis_kelamin = 'Perempuan';
                }
            }

            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            Log::error('Error getAllAnak: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}