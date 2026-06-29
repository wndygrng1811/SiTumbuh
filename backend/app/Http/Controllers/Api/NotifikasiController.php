<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotifikasiController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('user_id', 1);
        $userRole = $request->query('role', '');
        
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
                'n.target_role',
                'n.created_at',
                DB::raw('COALESCE(nu.is_read, 0) as is_read')
            )
            ->when(!empty($userRole), function($query) use ($userRole) {
                return $query->where(function($q) use ($userRole) {
                    $q->where('n.target_role', $userRole)
                      ->orWhereNull('n.target_role')
                      ->orWhere('n.target_role', '');
                });
            })
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
        $userRole = $request->query('role', '');
        
        $notifikasiIds = DB::table('notifikasi')
            ->when(!empty($userRole), function($query) use ($userRole) {
                return $query->where(function($q) use ($userRole) {
                    $q->where('target_role', $userRole)
                      ->orWhereNull('target_role')
                      ->orWhere('target_role', '');
                });
            })
            ->pluck('id');
        
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
    
    public function sendNotification(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:255',
            'isi' => 'required|string',
            'jenis' => 'required|string',
            'target_role' => 'nullable|string|in:orang_tua,kader',
            'link' => 'nullable|string',
            'gambar' => 'nullable|string',
        ]);
        
        $notifikasiId = DB::table('notifikasi')->insertGetId([
            'judul' => $request->judul,
            'isi' => $request->isi,
            'jenis' => $request->jenis,
            'gambar' => $request->gambar,
            'link' => $request->link,
            'target_role' => $request->target_role,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        if ($request->target_role) {
            $users = DB::table('users')
                ->where('role', $request->target_role)
                ->get();
                
            foreach ($users as $user) {
                DB::table('notifikasi_user')->insert([
                    'notifikasi_id' => $notifikasiId,
                    'user_id' => $user->user_id,
                    'is_read' => 0,
                    'created_at' => now(),
                ]);
            }
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dikirim',
            'data' => ['id' => $notifikasiId]
        ]);
    }
}