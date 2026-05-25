<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pertumbuhan extends Model
{
    protected $table = 'pertumbuhan';

    protected $primaryKey = 'tumbuh_id';

    public $timestamps = false;

    protected $fillable = [
        'anak_id',
        'orangtua_id',
        'jadwal_id',
        'berat_badan',
        'tinggi_badan',
        'lingkar_kepala',
        'status_gizi'
    ];
}