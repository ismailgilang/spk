<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Perhitungan extends Model
{
    protected $fillable = [
        'kandidat_id',
        'ncf',
        'nsf',
        'nilai_total',
        'ranking',
        'periode',
    ];

    public function kandidat(): BelongsTo
    {
        return $this->belongsTo(Kandidat::class);
    }
}
