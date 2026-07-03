<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    protected $table = 'kategori';
    
    protected $fillable = [
        'nama',
        'deskripsi',
        'status'
    ];
    
    // Relasi ke Edukasi
    public function edukasis()
    {
        return $this->hasMany(Edukasi::class, 'kategori_id');
    }
}