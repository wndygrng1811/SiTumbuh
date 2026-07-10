<?php

namespace App\Http\Controllers\Api\Kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class KelolaAnakController extends Controller
{
    // GET SEMUA ANAK (untuk kader)
    public function index()
    {
        try {
            Log::info('=== KelolaAnakController@index dipanggil ===');

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

            // Konversi jenis kelamin dari L/P ke Laki-laki/Perempuan
            foreach ($anak as $a) {
                if ($a->jenis_kelamin == 'L') {
                    $a->jenis_kelamin = 'Laki-laki';
                } elseif ($a->jenis_kelamin == 'P') {
                    $a->jenis_kelamin = 'Perempuan';
                }
            }

            Log::info('Data anak ditemukan: ' . count($anak) . ' data');

            return response()->json([
                'success' => true,
                'data' => $anak
            ]);
        } catch (\Exception $e) {
            Log::error('Error KelolaAnakController@index: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // GET DETAIL ANAK BY ID
    public function show($id)
    {
        try {
            Log::info('=== KelolaAnakController@show dipanggil ===');
            Log::info('Anak ID: ' . $id);

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

            // Konversi jenis kelamin
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
            Log::error('Error KelolaAnakController@show: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // TAMBAH ANAK
    public function store(Request $request)
    {
        try {
            Log::info('=== KelolaAnakController@store dipanggil ===');
            Log::info('Request data: ' . json_encode($request->all()));

            $validatedData = $request->validate([
                'orangtua_id' => 'required|integer|exists:orang_tua,orangtua_id',
                'nama' => 'required|string|max:100',
                'jenis_kelamin' => 'required|string|in:L,P,Laki-laki,Perempuan',
                'tanggal_lahir' => 'required|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
            ]);

            // Konversi jenis kelamin ke format database (L/P)
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
                'status_gizi' => 'Normal',
            ]);

            Log::info('Data anak berhasil ditambahkan dengan ID: ' . $anakId);

            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil ditambahkan',
                'data' => ['anak_id' => $anakId]
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validasi gagal: ' . json_encode($e->errors()));
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error KelolaAnakController@store: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // UPDATE ANAK
    public function update(Request $request, $id)
    {
        try {
            Log::info('=== KelolaAnakController@update dipanggil ===');
            Log::info('Anak ID: ' . $id);
            Log::info('Request data: ' . json_encode($request->all()));

            $anak = DB::table('anak')->where('anak_id', $id)->first();
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }

            $validatedData = $request->validate([
                'nama' => 'sometimes|string|max:100',
                'jenis_kelamin' => 'sometimes|string|in:L,P,Laki-laki,Perempuan',
                'tanggal_lahir' => 'sometimes|date',
                'berat_badan' => 'nullable|numeric',
                'tinggi_badan' => 'nullable|numeric',
                'lingkar_kepala' => 'nullable|numeric',
                'status_gizi' => 'nullable|string|max:20'
            ]);

            $updateData = [];
            if ($request->has('nama')) {
                $updateData['nama'] = $validatedData['nama'];
            }
            if ($request->has('jenis_kelamin')) {
                $jk = $validatedData['jenis_kelamin'];
                if ($jk == 'Laki-laki' || $jk == 'L') {
                    $jk = 'L';
                } elseif ($jk == 'Perempuan' || $jk == 'P') {
                    $jk = 'P';
                } else {
                    $jk = 'L';
                }
                $updateData['jenis_kelamin'] = $jk;
            }
            if ($request->has('tanggal_lahir')) {
                $updateData['tanggal_lahir'] = $validatedData['tanggal_lahir'];
            }
            if ($request->has('berat_badan')) {
                $updateData['berat_badan'] = $validatedData['berat_badan'] ?? 0;
            }
            if ($request->has('tinggi_badan')) {
                $updateData['tinggi_badan'] = $validatedData['tinggi_badan'] ?? 0;
            }
            if ($request->has('lingkar_kepala')) {
                $updateData['lingkar_kepala'] = $validatedData['lingkar_kepala'] ?? 0;
            }
            if ($request->has('status_gizi')) {
                $updateData['status_gizi'] = $validatedData['status_gizi'];
            }

            if (empty($updateData)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak ada data yang diupdate'
                ], 400);
            }

            $updated = DB::table('anak')
                ->where('anak_id', $id)
                ->update($updateData);

            Log::info('Update result: ' . ($updated ? 'success' : 'failed'));

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
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validasi gagal: ' . json_encode($e->errors()));
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error KelolaAnakController@update: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // HAPUS ANAK
    public function destroy($id)
    {
        try {
            Log::info('=== KelolaAnakController@destroy dipanggil ===');
            Log::info('Anak ID: ' . $id);

            $anak = DB::table('anak')->where('anak_id', $id)->first();
            if (!$anak) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data anak tidak ditemukan'
                ], 404);
            }

            DB::table('pertumbuhan')->where('anak_id', $id)->delete();
            DB::table('anak')->where('anak_id', $id)->delete();

            Log::info('Data anak berhasil dihapus');

            return response()->json([
                'success' => true,
                'message' => 'Data anak berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            Log::error('Error KelolaAnakController@destroy: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // GET ANAK BY ORANGTUA ID
    public function getByOrangtua($orangtuaId)
    {
        try {
            Log::info('=== KelolaAnakController@getByOrangtua dipanggil ===');
            Log::info('Orangtua ID: ' . $orangtuaId);

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
            Log::error('Error KelolaAnakController@getByOrangtua: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}