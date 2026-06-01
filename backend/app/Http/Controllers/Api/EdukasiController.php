<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EdukasiController extends Controller
{
    public function index()
    {
        $edukasi = DB::table('edukasi')->get();
        
        return response()->json([
            'success' => true,
            'data' => $edukasi
        ]);
    }
    
    public function show($id)
    {
        $edukasi = DB::table('edukasi')->where('edukasi_id', $id)->first();
        
        return response()->json([
            'success' => true,
            'data' => $edukasi
        ]);
    }
}