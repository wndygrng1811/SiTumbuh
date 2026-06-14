<?php

namespace App\Http\Controllers\Api\kader;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PertumbuhanController extends Controller
{
    /**
     * GET riwayat pertumbuhan berdasarkan anak_id
     */
    public function getRiwayat($anakId)
    {
        try {
            $riwayat = DB::table('pertumbuhan')
                ->where('anak_id', $anakId)
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Data riwayat berhasil diambil',
                'data' => $riwayat
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * SIMPAN data pertumbuhan baru
     */
    public function simpanPertumbuhan(Request $request)
    {
        try {
            $request->validate([
                'anak_id' => 'required|integer',
                'orangtua_id' => 'nullable|integer',
                'jadwal_id' => 'nullable|integer',
                'berat_badan' => 'required|numeric|min:0|max:50',
                'tinggi_badan' => 'required|numeric|min:0|max:200',
                'lingkar_kepala' => 'nullable|numeric|min:0|max:100',
                'status_gizi' => 'required|string|max:20',
                'tanggal_pengukuran' => 'nullable|date'
            ]);

            $data = [
                'anak_id' => $request->anak_id,
                'berat_badan' => $request->berat_badan,
                'tinggi_badan' => $request->tinggi_badan,
                'lingkar_kepala' => $request->lingkar_kepala ?? null,
                'status_gizi' => $request->status_gizi,
                'created_at' => $request->tanggal_pengukuran ?: now()
            ];

            if ($request->has('orangtua_id')) {
                $data['orangtua_id'] = $request->orangtua_id;
            }
            if ($request->has('jadwal_id')) {
                $data['jadwal_id'] = $request->jadwal_id;
            }

            $tumbuhId = DB::table('pertumbuhan')->insertGetId($data);

            if ($tumbuhId) {
                // 🔥 KIRIM NOTIFIKASI OTOMATIS KE ORANG TUA
                if ($request->has('orangtua_id')) {
                    $this->sendNotifikasiPertumbuhan(
                        $request->anak_id,
                        $request->orangtua_id,
                        $request->status_gizi
                    );
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Data pertumbuhan berhasil disimpan',
                    'data' => [
                        'tumbuh_id' => $tumbuhId,
                        'anak_id' => $data['anak_id'],
                        'berat_badan' => $data['berat_badan'],
                        'tinggi_badan' => $data['tinggi_badan'],
                        'lingkar_kepala' => $data['lingkar_kepala'],
                        'status_gizi' => $data['status_gizi'],
                        'created_at' => $data['created_at']
                    ]
                ], 201);
            }

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data'
            ], 500);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * KIRIM NOTIFIKASI OTOMATIS KE ORANG TUA
     */
    private function sendNotifikasiPertumbuhan($anakId, $orangtuaId, $statusGizi)
    {
        try {
            // Ambil data anak
            $anak = DB::table('anak')->where('anak_id', $anakId)->first();
            if (!$anak) return;

            // Ambil data orang tua
            $orangTua = DB::table('orang_tua')->where('orangtua_id', $orangtuaId)->first();
            if (!$orangTua) return;

            // Ambil user_id dari orang tua
            $user = DB::table('users')->where('user_id', $orangTua->user_id)->first();
            if (!$user) return;

            // Buat pesan notifikasi berdasarkan status gizi
            if ($statusGizi == 'Normal') {
                $judul = "Pertumbuhan Normal 🎉";
                $isi = "Hasil pemeriksaan posyandu: pertumbuhan anak Anda ({$anak->nama}) dalam kondisi normal. Pertahankan ya!";
            } elseif ($statusGizi == 'Stunting') {
                $judul = "Perhatian! Risiko Stunting ⚠️";
                $isi = "Hasil pemeriksaan posyandu menunjukkan anak Anda ({$anak->nama}) berisiko stunting. Segera konsultasikan ke posyandu terdekat.";
            } elseif ($statusGizi == 'Kurang' || $statusGizi == 'Underweight') {
                $judul = "Perhatian! Gizi Kurang ⚠️";
                $isi = "Hasil pemeriksaan posyandu menunjukkan anak Anda ({$anak->nama}) mengalami kekurangan gizi. Perhatikan asupan makanannya.";
            } elseif ($statusGizi == 'Obese' || $statusGizi == 'Obesitas') {
                $judul = "Perhatian! Kelebihan Gizi ⚠️";
                $isi = "Hasil pemeriksaan posyandu menunjukkan anak Anda ({$anak->nama}) mengalami kelebihan gizi. Perhatikan pola makannya.";
            } else {
                $judul = "Hasil Pemeriksaan Baru 📋";
                $isi = "Telah dilakukan pemeriksaan posyandu untuk anak Anda ({$anak->nama}) dengan status: $statusGizi.";
            }

            // Simpan notifikasi ke database
            $notifikasiId = DB::table('notifikasi')->insertGetId([
                'judul' => $judul,
                'isi' => $isi,
                'jenis' => 'pemeriksaan',
                'target_role' => 'orang_tua',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Tandai untuk user orang tua (belum dibaca)
            DB::table('notifikasi_user')->insert([
                'notifikasi_id' => $notifikasiId,
                'user_id' => $user->user_id,
                'is_read' => 0,
                'created_at' => now(),
            ]);

        } catch (\Exception $e) {
            // Log error tapi jangan gagalkan proses simpan data
            \Log::error('Gagal kirim notifikasi: ' . $e->getMessage());
        }
    }

    /**
     * GET semua anak (untuk kader) - JOIN dengan orang_tua
     */
    public function getAllAnak(Request $request)
    {
        try {
            $anak = DB::table('anak')
                ->join('orang_tua', 'anak.orangtua_id', '=', 'orang_tua.orangtua_id')
                ->select(
                    'anak.anak_id',
                    'anak.nama as nama_anak',
                    'anak.jenis_kelamin',
                    'anak.tanggal_lahir',
                    'orang_tua.orangtua_id',
                    'orang_tua.nama as nama_ortu'
                )
                ->orderBy('orang_tua.nama')
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

    /**
     * GET semua orang tua
     */
    public function getAllOrangTua(Request $request)
    {
        try {
            $orangTua = DB::table('orang_tua')
                ->select('orangtua_id', 'nama', 'email', 'alamat', 'no_telp')
                ->orderBy('nama')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $orangTua
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * KMS endpoint
     */
    public function kms(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'KMS endpoint'
        ]);
    }

    /**
     * Store method alias
     */
    public function store(Request $request)
    {
        return $this->simpanPertumbuhan($request);
    }
}