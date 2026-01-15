<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Kriteria extends Model
{
    protected $fillable = [
        'kode_kriteria',
        'nama_kriteria',
        'tipe',
        'bobot',
        'nilai_target',
        'keterangan',
    ];

    public function subKriterias(): HasMany
    {
        return $this->hasMany(SubKriteria::class);
    }

    public function penilaian(): HasMany
    {
        return $this->hasMany(Penilaian::class);
    }
}
