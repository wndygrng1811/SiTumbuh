<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PertumbuhanController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AnakController;
use App\Http\Controllers\Api\EdukasiController;

Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'SiTumbuh API Ready'
    ]);
});

// API Routes
Route::post('/login', [AuthController::class, 'login']);

// Orang Tua & Kader
Route::get('/pertumbuhan/{anakId}', [PertumbuhanController::class, 'getRiwayat']);
Route::get('/kms', [PertumbuhanController::class, 'kms']);

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

// 🔥 EDUKASI - PASTIKAN INI ADA
Route::get('/edukasi', [EdukasiController::class, 'index']);
Route::get('/edukasi/{id}', [EdukasiController::class, 'show']);

// Kader
Route::post('/pertumbuhan', [PertumbuhanController::class, 'store']);