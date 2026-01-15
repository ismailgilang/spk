<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Penilaian extends Model
{
    protected $fillable = [
        'kandidat_id',
        'kriteria_id',
        'nilai',
        'nilai_target',
    ];

    public function kandidat(): BelongsTo
    {
        return $this->belongsTo(Kandidat::class);
    }

    public function kriteria(): BelongsTo
    {
        return $this->belongsTo(Kriteria::class);
    }
}
