<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Anak extends Model
{
    protected $table = 'anak';
    protected $primaryKey = 'anak_id';
    public $timestamps = false;
    
    protected $fillable = [
        'orangtua_id', 'nama', 'jenis_kelamin', 'tanggal_lahir',
        'berat_badan', 'tinggi_badan', 'lingkar_kepala', 'status_gizi'
    ];
}