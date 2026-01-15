<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class KriteriaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $kriteria = [
            [
                'kode_kriteria' => 'K001',
                'nama_kriteria' => 'Kepemimpinan',
                'tipe' => 'core_factor',
                'bobot' => 60.00,
                'keterangan' => 'Kemampuan memimpin dan mengarahkan tim',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kode_kriteria' => 'K002',
                'nama_kriteria' => 'Manajerial',
                'tipe' => 'core_factor',
                'bobot' => 60.00,
                'keterangan' => 'Kemampuan mengelola dan mengorganisir sekolah',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kode_kriteria' => 'K003',
                'nama_kriteria' => 'Kerjasama',
                'tipe' => 'secondary_factor',
                'bobot' => 40.00,
                'keterangan' => 'Kemampuan bekerjasama dengan stakeholder',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kode_kriteria' => 'K004',
                'nama_kriteria' => 'Komunikasi',
                'tipe' => 'secondary_factor',
                'bobot' => 40.00,
                'keterangan' => 'Kemampuan berkomunikasi secara efektif',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kode_kriteria' => 'K005',
                'nama_kriteria' => 'Inovasi dan Kreativitas',
                'tipe' => 'core_factor',
                'bobot' => 60.00,
                'keterangan' => 'Kemampuan berinovasi dalam pengembangan sekolah',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];
        DB::table('kriterias')->insert($kriteria);
    }
}
