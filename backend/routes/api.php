<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PertumbuhanController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AnakController;
use App\Http\Controllers\Api\EdukasiController;
use App\Http\Controllers\Api\JadwalController;
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'SiTumbuh API Ready'
    ]);
});

// API Routes
Route::post('/login', [AuthController::class, 'login']);

// Profile
Route::get('/orangtua/profile/{userId}', [ProfileController::class, 'getProfile']);
Route::get('/orangtua/{userId}/profile-lengkap', [ProfileController::class, 'getProfileLengkap']);
Route::put('/orangtua/{userId}/profile-lengkap', [ProfileController::class, 'updateProfileLengkap']);

// Anak
Route::get('/anak/{anakId}', [AnakController::class, 'getDetail']);
Route::get('/orangtua/{orangtuaId}/anak', [AnakController::class, 'getDataAnak']);
Route::get('/anak/{anakId}/riwayat', [AnakController::class, 'getRiwayatKunjungan']);
Route::post('/anak', [AnakController::class, 'store']);
Route::put('/anak/{anakId}', [AnakController::class, 'update']);
Route::delete('/anak/{anakId}', [AnakController::class, 'destroy']);

// Edukasi
Route::get('/edukasi', [EdukasiController::class, 'index']);
Route::get('/edukasi/{id}', [EdukasiController::class, 'show']);

// Pertumbuhan
Route::get('/pertumbuhan/{anakId}', [PertumbuhanController::class, 'getRiwayat']);
Route::post('/pertumbuhan', [PertumbuhanController::class, 'store']);

// 🔥 JADWAL (tambah ini)
Route::get('/jadwal', [JadwalController::class, 'index']);
Route::post('/jadwal', [JadwalController::class, 'store']);
Route::put('/jadwal/{id}', [JadwalController::class, 'update']);
Route::delete('/jadwal/{id}', [JadwalController::class, 'destroy']);