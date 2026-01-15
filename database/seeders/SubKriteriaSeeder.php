<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class SubKriteriaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $subKriteria = [];
        
        // Sub kriteria untuk semua kriteria (K001 - K005)
        // Setiap kriteria memiliki 5 tingkat nilai
        for ($kriteriaId = 1; $kriteriaId <= 5; $kriteriaId++) {
            $subKriteria[] = [
                'kriteria_id' => $kriteriaId,
                'nilai' => 1,
                'keterangan' => 'Sangat Kurang',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            $subKriteria[] = [
                'kriteria_id' => $kriteriaId,
                'nilai' => 2,
                'keterangan' => 'Kurang',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            $subKriteria[] = [
                'kriteria_id' => $kriteriaId,
                'nilai' => 3,
                'keterangan' => 'Cukup',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            $subKriteria[] = [
                'kriteria_id' => $kriteriaId,
                'nilai' => 4,
                'keterangan' => 'Baik',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            $subKriteria[] = [
                'kriteria_id' => $kriteriaId,
                'nilai' => 5,
                'keterangan' => 'Sangat Baik',
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        DB::table('sub_kriterias')->insert($subKriteria);
    }
}
