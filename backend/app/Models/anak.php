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
    
    protected $casts = [
        'berat_badan' => 'float',
        'tinggi_badan' => 'float',
        'lingkar_kepala' => 'float',
    ];
    
    // Accessor untuk jenis kelamin
    public function getJenisKelaminAttribute($value)
    {
        if ($value == 'L') return 'Laki-laki';
        if ($value == 'P') return 'Perempuan';
        return $value;
    }
    
    // Mutator untuk jenis kelamin
    public function setJenisKelaminAttribute($value)
    {
        if ($value == 'Laki-laki') $this->attributes['jenis_kelamin'] = 'L';
        elseif ($value == 'Perempuan') $this->attributes['jenis_kelamin'] = 'P';
        else $this->attributes['jenis_kelamin'] = $value;
    }
}