<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PertumbuhanController;

Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'SiTumbuh API Ready'
    ]);
});

// API Routes
Route::post('/login', [AuthController::class, 'login']);

// Orang Tua
Route::get(
    '/pertumbuhan/{anakId}',
    [PertumbuhanController::class, 'getRiwayat']
);
Route::get('/kms', [PertumbuhanController::class, 'kms']);
// Route::middleware('auth:sanctum')->group(function () {
//     // Profile Orang Tua
//     Route::get('/orangtua/profile/{userId}', [ProfileController::class, 'getProfile']);
//     
//     // Detail Anak
//     Route::get('/anak/{anakId}', [AnakController::class, 'getDetail']);
// });

// Kader
Route::post('/pertumbuhan', [PertumbuhanController::class, 'store']);