<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Anak;
use Illuminate\Support\Facades\DB;

class AnakController extends Controller
{
    // Get detail anak by ID
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
                'nama_anak' => $anak->nama,
                'jenis_kelamin' => $anak->jenis_kelamin,
                'tanggal_lahir' => $anak->tanggal_lahir,
                'berat_lahir' => $anak->berat_badan,
                'tinggi_lahir' => $anak->tinggi_badan,
                'lingkar_kepala_lahir' => $anak->lingkar_kepala,
                'status_gizi' => $anak->status_gizi ?? 'Normal',
            ]
        ]);
    }
    
    // Get all anak by orangtua_id
    public function getDataAnak($orangtuaId)
    {
        $anak = DB::table('anak')
            ->where('orangtua_id', $orangtuaId)
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $anak
        ]);
    }
    
    // Get riwayat kunjungan by anak_id
    public function getRiwayatKunjungan($anakId)
    {
        $riwayat = DB::table('pertumbuhan')
            ->where('anak_id', $anakId)
            ->orderBy('created_at', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $riwayat
        ]);
    }
    
    // Create new anak
    public function store(Request $request)
    {
        $anakId = DB::table('anak')->insertGetId([
            'orangtua_id' => $request->orangtua_id,
            'nama' => $request->nama,
            'jenis_kelamin' => $request->jenis_kelamin,
            'tanggal_lahir' => $request->tanggal_lahir,
            'berat_badan' => $request->berat_badan,
            'tinggi_badan' => $request->tinggi_badan,
            'lingkar_kepala' => $request->lingkar_kepala,
            'status_gizi' => $request->status_gizi ?? 'Normal',
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Data anak berhasil ditambahkan',
            'data' => ['anak_id' => $anakId]
        ]);
    }
    
    // Update anak
    public function update(Request $request, $anakId)
    {
        DB::table('anak')
            ->where('anak_id', $anakId)
            ->update([
                'nama' => $request->nama,
                'jenis_kelamin' => $request->jenis_kelamin,
                'tanggal_lahir' => $request->tanggal_lahir,
                'berat_badan' => $request->berat_badan,
                'tinggi_badan' => $request->tinggi_badan,
                'lingkar_kepala' => $request->lingkar_kepala,
                'status_gizi' => $request->status_gizi,
            ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Data anak berhasil diupdate'
        ]);
    }
    
    // Delete anak
    public function destroy($anakId)
    {
        DB::table('anak')->where('anak_id', $anakId)->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Data anak berhasil dihapus'
        ]);
    }
}