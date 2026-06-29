<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Intervention\Image\Facades\Image;

class JadwalController extends Controller
{
    public function index()
    {
        $jadwal = DB::table('jadwal')
            ->orderBy('tanggal', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $jadwal
        ]);
    }

    public function store(Request $request)
    {
        try {
            Log::info('Store jadwal called', $request->all());

            $request->validate([
                'nama_posyandu' => 'required|string|max:255',
                'tanggal' => 'required|date',
                'waktu' => 'required|string',
                'alamat' => 'required|string',
                'template' => 'nullable|string',
            ]);

            // Generate poster otomatis
            $posterPath = $this->generatePosterImage($request);

            $jadwalId = DB::table('jadwal')->insertGetId([
                'nama_posyandu' => $request->nama_posyandu,
                'tanggal' => $request->tanggal,
                'waktu' => $request->waktu,
                'alamat' => $request->alamat,
                'template' => $posterPath,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            Log::info('Jadwal created with ID: ' . $jadwalId);

            // Kirim notifikasi ke Orang Tua
            $this->sendNotifikasi([
                'judul' => 'Jadwal Posyandu Baru',
                'isi' => 'Jadwal posyandu "' . $request->nama_posyandu . '" akan dilaksanakan pada tanggal ' . $request->tanggal . ' jam ' . $request->waktu,
                'jenis' => 'jadwal_baru',
                'target_role' => 'orang_tua',
                'link' => '/jadwal/' . $jadwalId,
            ]);

            // Kirim notifikasi ke Kader
            $this->sendNotifikasi([
                'judul' => 'Jadwal Baru Dibuat',
                'isi' => 'Kader telah membuat jadwal posyandu "' . $request->nama_posyandu . '" pada tanggal ' . $request->tanggal,
                'jenis' => 'kader_tugas',
                'target_role' => 'kader',
                'link' => '/jadwal/' . $jadwalId,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Jadwal berhasil dibuat',
                'data' => [
                    'jadwal_id' => $jadwalId,
                    'template' => $posterPath
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Error store jadwal: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan jadwal: ' . $e->getMessage()
            ], 500);
        }
    }

    private function generatePosterImage($request)
    {
        try {
            if (!class_exists('Intervention\Image\Facades\Image')) {
                Log::warning('Intervention Image not installed, using default template');
                return $request->template ?? 'assets/templatekuning.jpg';
            }

            $templateFile = $request->template ?? 'assets/templatekuning.jpg';
            $templatePath = public_path($templateFile);

            Log::info('Template path: ' . $templatePath);

            if (!file_exists($templatePath)) {
                Log::warning('Template not found: ' . $templatePath);
                $templatePath = public_path('assets/templatekuning.jpg');
                if (!file_exists($templatePath)) {
                    Log::error('Default template not found');
                    return 'assets/templatekuning.jpg';
                }
            }

            $img = Image::make($templatePath);
            $formattedDate = $this->formatTanggal($request->tanggal);

            $img->text($request->nama_posyandu, 170, 50, function($font) {
                $font->size(28);
                $font->color('#2D2D2D');
                $font->align('center');
                $font->valign('top');
            });

            $img->text($formattedDate, 170, 100, function($font) {
                $font->size(16);
                $font->color('#5C6BC0');
                $font->align('center');
                $font->valign('top');
            });

            $img->text('Jam: ' . $request->waktu, 170, 130, function($font) {
                $font->size(14);
                $font->color('#F57C00');
                $font->align('center');
                $font->valign('top');
            });

            $img->text('Alamat: ' . $request->alamat, 170, 160, function($font) {
                $font->size(12);
                $font->color('#666666');
                $font->align('center');
                $font->valign('top');
            });

            $img->text('Yuk ke Posyandu!', 170, 240, function($font) {
                $font->size(18);
                $font->color('#25D366');
                $font->align('center');
                $font->valign('top');
            });

            $filename = 'poster_' . time() . '_' . uniqid() . '.jpg';
            $path = 'assets/posters/' . $filename;
            $fullPath = public_path($path);

            Log::info('Saving poster to: ' . $fullPath);

            if (!is_dir(public_path('assets/posters'))) {
                mkdir(public_path('assets/posters'), 0777, true);
            }

            $img->save($fullPath, 80);

            Log::info('Poster saved: ' . $path);
            return $path;

        } catch (\Exception $e) {
            Log::error('Error generate poster: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            return $request->template ?? 'assets/templatekuning.jpg';
        }
    }

    private function formatTanggal($dateStr)
    {
        try {
            $date = new \DateTime($dateStr);
            $days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
            $months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                       'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
            return $days[$date->format('N') - 1] . ', ' . $date->format('d') . ' ' . 
                   $months[$date->format('n') - 1] . ' ' . $date->format('Y');
        } catch (\Exception $e) {
            return $dateStr;
        }
    }

    private function sendNotifikasi($data)
    {
        try {
            $notifikasiId = DB::table('notifikasi')->insertGetId([
                'judul' => $data['judul'],
                'isi' => $data['isi'],
                'jenis' => $data['jenis'],
                'link' => $data['link'],
                'target_role' => $data['target_role'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $users = DB::table('users')
                ->where('role', $data['target_role'])
                ->get();

            if ($users->isEmpty()) {
                Log::info('No users found for role: ' . $data['target_role']);
                return;
            }

            foreach ($users as $user) {
                DB::table('notifikasi_user')->insert([
                    'notifikasi_id' => $notifikasiId,
                    'user_id' => $user->user_id,
                    'is_read' => 0,
                    'created_at' => now(),
                ]);
            }

            Log::info('Notifikasi sent to ' . $users->count() . ' users');

        } catch (\Exception $e) {
            Log::error('Error send notifikasi: ' . $e->getMessage());
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $request->validate([
                'nama_posyandu' => 'required|string|max:255',
                'tanggal' => 'required|date',
                'waktu' => 'required|string',
                'alamat' => 'required|string',
                'template' => 'nullable|string',
            ]);

            DB::table('jadwal')
                ->where('jadwal_id', $id)
                ->update([
                    'nama_posyandu' => $request->nama_posyandu,
                    'tanggal' => $request->tanggal,
                    'waktu' => $request->waktu,
                    'alamat' => $request->alamat,
                    'template' => $request->template,
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Jadwal berhasil diupdate'
            ]);

        } catch (\Exception $e) {
            Log::error('Error update jadwal: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal update jadwal: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            DB::table('jadwal')->where('jadwal_id', $id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Jadwal berhasil dihapus'
            ]);

        } catch (\Exception $e) {
            Log::error('Error delete jadwal: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal hapus jadwal: ' . $e->getMessage()
            ], 500);
        }
    }
}