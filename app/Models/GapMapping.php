<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GapMapping extends Model
{
    protected $fillable = [
        'gap',
        'bobot',
        'keterangan',
    ];
}
