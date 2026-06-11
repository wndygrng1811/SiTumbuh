<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PertumbuhanController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AnakController;
use App\Http\Controllers\Api\EdukasiController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\Kader\DashboardKaderController;
use App\Http\Controllers\Api\kader\PertumbuhanController as KaderPertumbuhanController;
use App\Http\Controllers\Api\Kader\KelolaAnakController;
use App\Http\Controllers\Api\Kader\ProfilKaderController;  
use App\Http\Controllers\Api\Kader\KelolaOrangTuaController;
use App\Http\Controllers\Api\Kader\KehadiranController;
use App\Http\Controllers\Api\Kader\LaporanController;

// Health Check
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'SiTumbuh API Ready'
    ]);
});

// =============================================
// AUTH ROUTES
// =============================================
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// =============================================
// ORANG TUA - PROFILE
// =============================================
Route::get('/orangtua/profile/{userId}', [ProfileController::class, 'getProfile']);
Route::get('/orangtua/{userId}/profile-lengkap', [ProfileController::class, 'getProfileLengkap']);
Route::put('/orangtua/{userId}/profile-lengkap', [ProfileController::class, 'updateProfileLengkap']);

// =============================================
// ORANG TUA - ANAK
// =============================================
Route::get('/anak/{anakId}', [AnakController::class, 'getDetail']);
Route::get('/orangtua/{orangtuaId}/anak', [AnakController::class, 'getDataAnak']);
Route::get('/anak/{anakId}/riwayat', [AnakController::class, 'getRiwayatKunjungan']);
Route::post('/anak', [AnakController::class, 'store']);
Route::put('/anak/{anakId}', [AnakController::class, 'update']);
Route::delete('/anak/{anakId}', [AnakController::class, 'destroy']);

// =============================================
// EDUKASI
// =============================================
Route::get('/edukasi', [EdukasiController::class, 'index']);
Route::get('/edukasi/{id}', [EdukasiController::class, 'show']);

// =============================================
// PERTUMBUHAN (untuk Orang Tua)
// =============================================
Route::get('/pertumbuhan/{anakId}', [PertumbuhanController::class, 'getRiwayat']);
Route::post('/pertumbuhan', [PertumbuhanController::class, 'store']);

// =============================================
// JADWAL
// =============================================
Route::get('/jadwal', [JadwalController::class, 'index']);
Route::post('/jadwal', [JadwalController::class, 'store']);
Route::put('/jadwal/{id}', [JadwalController::class, 'update']);
Route::delete('/jadwal/{id}', [JadwalController::class, 'destroy']);

// =============================================
// KADER - DASHBOARD
// =============================================
Route::get('/kader/statistik', [DashboardKaderController::class, 'getStatistik']);
Route::get('/kader/jadwal-terdekat', [DashboardKaderController::class, 'getJadwalTerdekat']);
Route::get('/kader/profil-sederhana/{userId}', [DashboardKaderController::class, 'getProfilKader']);

// =============================================
// KADER - PERTUMBUHAN
// =============================================
Route::get('/kader/pertumbuhan/{anakId}', [KaderPertumbuhanController::class, 'getRiwayat']);
Route::post('/kader/pertumbuhan', [KaderPertumbuhanController::class, 'simpanPertumbuhan']);
Route::get('/kms', [KaderPertumbuhanController::class, 'kms']);
Route::get('/kader/semua-anak-data', [KaderPertumbuhanController::class, 'getAllAnak']);
Route::get('/kader/semua-ortu', [KaderPertumbuhanController::class, 'getAllOrangTua']);

// =============================================
// KADER - KELOLA ORANG TUA (CRUD)
// =============================================
Route::get('/kader/orangtua', [KelolaOrangTuaController::class, 'index']);
Route::post('/kader/tambah-orangtua', [KelolaOrangTuaController::class, 'store']);
Route::put('/kader/orangtua/{id}', [KelolaOrangTuaController::class, 'update']);
Route::delete('/kader/orangtua/{id}', [KelolaOrangTuaController::class, 'destroy']);

// =============================================
// KADER - KELOLA ANAK (CRUD)
// =============================================
Route::get('/kader/semua-anak', [KelolaAnakController::class, 'index']);
Route::get('/kader/anak/{id}', [KelolaAnakController::class, 'show']);
Route::post('/kader/anak', [KelolaAnakController::class, 'store']);
Route::put('/kader/anak/{id}', [KelolaAnakController::class, 'update']);
Route::delete('/kader/anak/{id}', [KelolaAnakController::class, 'destroy']);
Route::get('/kader/anak-by-ortu/{orangtuaId}', [KelolaAnakController::class, 'getByOrangtua']);

// =============================================
// KADER - PROFIL KADER
// =============================================
Route::get('/kader/profil/{userId}', [ProfilKaderController::class, 'getProfil']);
Route::put('/kader/profil/{userId}', [ProfilKaderController::class, 'updateProfil']);

// =============================================
// KADER - KEHADIRAN
// =============================================
Route::get('/kader/semua-jadwal', [KehadiranController::class, 'getAllJadwal']);
Route::get('/kehadiran/jadwal/{jadwalId}', [KehadiranController::class, 'getKehadiranByJadwal']);
Route::post('/kehadiran/simpan-semua', [KehadiranController::class, 'simpanSemuaKehadiran']);   

// =============================================
// KADER - LAPORAN
// =============================================
Route::get('/kader/semua-pertumbuhan', [LaporanController::class, 'getAllPertumbuhan']);

// =============================================
// LOGOUT
// =============================================
Route::post('/logout', [AuthController::class, 'logout']);