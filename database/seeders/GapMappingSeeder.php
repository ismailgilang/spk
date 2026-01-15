<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class GapMappingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $gapMappings = [
            ['gap' => 0, 'bobot' => 5.0, 'keterangan' => 'Tidak ada selisih (kompetensi sesuai dengan yang dibutuhkan)'],
            ['gap' => 1, 'bobot' => 4.5, 'keterangan' => 'Kompetensi individu kelebihan 1 tingkat/level'],
            ['gap' => -1, 'bobot' => 4.0, 'keterangan' => 'Kompetensi individu kekurangan 1 tingkat/level'],
            ['gap' => 2, 'bobot' => 3.5, 'keterangan' => 'Kompetensi individu kelebihan 2 tingkat/level'],
            ['gap' => -2, 'bobot' => 3.0, 'keterangan' => 'Kompetensi individu kekurangan 2 tingkat/level'],
            ['gap' => 3, 'bobot' => 2.5, 'keterangan' => 'Kompetensi individu kelebihan 3 tingkat/level'],
            ['gap' => -3, 'bobot' => 2.0, 'keterangan' => 'Kompetensi individu kekurangan 3 tingkat/level'],
            ['gap' => 4, 'bobot' => 1.5, 'keterangan' => 'Kompetensi individu kelebihan 4 tingkat/level'],
            ['gap' => -4, 'bobot' => 1.0, 'keterangan' => 'Kompetensi individu kekurangan 4 tingkat/level'],
        ];
        DB::table('gap_mappings')->insert($gapMappings);
    }
}
