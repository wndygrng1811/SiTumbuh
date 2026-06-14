<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotifikasiController extends Controller
{
    public function index(Request $request)
    {
        // 🔥 AMBIL DARI PARAMETER URL
        $userId = $request->query('user_id', 1);
        
        $notifikasi = DB::table('notifikasi as n')
            ->leftJoin('notifikasi_user as nu', function($join) use ($userId) {
                $join->on('n.id', '=', 'nu.notifikasi_id')
                     ->where('nu.user_id', '=', $userId);
            })
            ->select(
                'n.id',
                'n.judul',
                'n.isi',
                'n.jenis',
                'n.gambar',
                'n.link',
                'n.created_at',
                DB::raw('COALESCE(nu.is_read, 0) as is_read')
            )
            ->orderBy('n.created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifikasi
        ]);
    }
    
    public function markAsRead(Request $request, $id)
    {
        $userId = $request->query('user_id', 1);
        
        DB::table('notifikasi_user')->updateOrInsert(
            ['notifikasi_id' => $id, 'user_id' => $userId],
            ['is_read' => 1, 'read_at' => now()]
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sebagai sudah dibaca'
        ]);
    }
    
    public function markAllAsRead(Request $request)
    {
        $userId = $request->query('user_id', 1);
        
        $notifikasiIds = DB::table('notifikasi')->pluck('id');
        
        foreach ($notifikasiIds as $id) {
            DB::table('notifikasi_user')->updateOrInsert(
                ['notifikasi_id' => $id, 'user_id' => $userId],
                ['is_read' => 1, 'read_at' => now()]
            );
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai sebagai sudah dibaca'
        ]);
    }
}