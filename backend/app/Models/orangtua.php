<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrangTua extends Model
{
    protected $table = 'orang_tua';
    protected $primaryKey = 'orangtua_id';
    public $timestamps = false;
    
    protected $fillable = [
        'nama', 'email', 'alamat', 'no_telp', 'user_id'
    ];
}