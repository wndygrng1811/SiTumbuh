<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Anak;

class AnakController extends Controller
{
    public function getDetail($anakId)
    {
        $anak = Anak::find($anakId);
        
        if (!$anak) {
            return response()->json([
                'success' => false,
                'message' => 'Data anak tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'nama_anak' => $anak->nama_anak,
                'jenis_kelamin' => $anak->jenis_kelamin,
                'tanggal_lahir' => $anak->tanggal_lahir,
                'berat_lahir' => $anak->berat_lahir,
                'tinggi_lahir' => $anak->tinggi_lahir,
                'lingkar_kepala_lahir' => $anak->lingkar_kepala_lahir,
                'status_gizi' => $anak->status_gizi,
            ]
        ]);
    }
}