<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\SurveyResponse;

class Kandidat extends Model
{
    protected $fillable = [
        'nip',
        'nama',
        'jenis_kelamin',
        'pendidikan_terakhir',
        'pengalaman_mengajar',
        'foto',
        'alamat',
        'no_telp',
    ];

    public function penilaian(): HasMany
    {
        return $this->hasMany(Penilaian::class);
    }

    public function perhitungan(): HasMany
    {
        return $this->hasMany(Perhitungan::class);
    }

    public function surveyResponses(): HasMany
    {
        return $this->hasMany(SurveyResponse::class);
    }
}
