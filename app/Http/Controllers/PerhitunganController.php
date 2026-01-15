<?php

namespace App\Http\Controllers;

use App\Models\Kandidat;
use App\Models\Kriteria;
use App\Models\GapMapping;
use App\Models\Perhitungan;
use App\Models\SurveyResponse; // Import the new model
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade\Pdf;

class PerhitunganController extends Controller
{
    public function index()
    {
        $perhitungans = Perhitungan::with('kandidat')->orderBy('ranking', 'asc')->get();
        return view('perhitungan.index', compact('perhitungans'));
    }

    public function calculate()
    {
        // 1. Kosongkan tabel perhitungan
        Perhitungan::truncate();

        // Fetch kandidat with their survey responses
        $kandidats = Kandidat::with('surveyResponses.kriteria')->get();
        $kriterias = Kriteria::all()->keyBy('id');
        $gapMappings = GapMapping::all()->pluck('bobot', 'gap');

        // Bobot persentase Core dan Secondary Factor dari total bobot kriteria
        $totalBobot = $kriterias->sum('bobot');
        $persentaseCore = $kriterias->where('tipe', 'core_factor')->sum('bobot') / $totalBobot;
        $persentaseSecondary = $kriterias->where('tipe', 'secondary_factor')->sum('bobot') / $totalBobot;

        foreach ($kandidats as $kandidat) {
            $nilaiBobot = [];
            
            // Group survey responses by kriteria for averaging
            $groupedResponses = $kandidat->surveyResponses->groupBy('kriteria_id');

            foreach ($groupedResponses as $kriteriaId => $responses) {
                // Calculate average nilai from survey responses for this kriteria
                $averageNilai = $responses->avg('nilai');
                $kriteria = $kriterias[$kriteriaId];

                // 2. Hitung GAP menggunakan nilai rata-rata dan nilai target kriteria
                $gap = $averageNilai - $kriteria->nilai_target; // Assuming Kriteria model has nilai_target

                // 3. Mapping GAP
                $bobotGap = $gapMappings[$gap] ?? 0;

                $nilaiBobot[$kriteriaId] = $bobotGap;
            }

            // 4. Hitung NCF dan NSF
            $coreFactors = [];
            $secondaryFactors = [];
            foreach ($nilaiBobot as $kriteriaId => $bobot) {
                if ($kriterias[$kriteriaId]->tipe == 'core_factor') {
                    $coreFactors[] = $bobot;
                } else {
                    $secondaryFactors[] = $bobot;
                }
            }

            $ncf = !empty($coreFactors) ? array_sum($coreFactors) / count($coreFactors) : 0;
            $nsf = !empty($secondaryFactors) ? array_sum($secondaryFactors) / count($secondaryFactors) : 0;
            
            // 5. Hitung Nilai Total
            $nilaiTotal = ($persentaseCore * $ncf) + ($persentaseSecondary * $nsf);

            // 6. Simpan hasil
            Perhitungan::create([
                'kandidat_id' => $kandidat->id,
                'ncf' => $ncf,
                'nsf' => $nsf,
                'nilai_total' => $nilaiTotal,
                'periode' => date('Y-m'),
            ]);
        }

        // 7. Lakukan perankingan
        $this->rank();

        return redirect()->route('perhitungan.index')->with('success', 'Perhitungan berhasil dilaksanakan.');
    }

    private function rank()
    {
        $perhitungans = Perhitungan::orderBy('nilai_total', 'desc')->get();
        $rank = 1;
        foreach ($perhitungans as $perhitungan) {
            $perhitungan->update(['ranking' => $rank++]);
        }
    }

    public function downloadPDF()
    {
        $perhitungans = Perhitungan::with('kandidat')->orderBy('ranking', 'asc')->get();
        
        // Fetch kandidat with their survey responses for detailed PDF
        $kandidats = Kandidat::with('surveyResponses.kriteria')->get();
        $gapMappings = GapMapping::all()->pluck('bobot', 'gap');
        $kriterias = Kriteria::all()->keyBy('id'); // Key by ID for easy lookup

        // Bobot persentase Core dan Secondary Factor
        $totalBobot = $kriterias->sum('bobot');
        $persentaseCore = $kriterias->where('tipe', 'core_factor')->sum('bobot') / $totalBobot;
        $persentaseSecondary = $kriterias->where('tipe', 'secondary_factor')->sum('bobot') / $totalBobot;

        $detailed_results = [];

        foreach ($kandidats as $kandidat) {
            $details = [
                'nama' => $kandidat->nama,
                'penilaian_detail' => [], // Changed key name for clarity in PDF view
                'factors' => [
                    'core' => [],
                    'secondary' => [],
                ],
                'ncf' => 0,
                'nsf' => 0,
                'total' => 0,
            ];
            
            $groupedResponses = $kandidat->surveyResponses->groupBy('kriteria_id');

            foreach ($groupedResponses as $kriteriaId => $responses) {
                $averageNilai = $responses->avg('nilai');
                $kriteria = $kriterias[$kriteriaId];
                
                $gap = $averageNilai - $kriteria->nilai_target;
                $bobot = $gapMappings[$gap] ?? 0;

                $details['penilaian_detail'][] = [
                    'kriteria' => $kriteria->nama_kriteria,
                    'rata_rata_nilai_survey' => $averageNilai,
                    'nilai_target' => $kriteria->nilai_target,
                    'gap' => $gap,
                    'bobot' => $bobot,
                ];

                if ($kriteria->tipe == 'core_factor') {
                    $details['factors']['core'][] = $bobot;
                } else {
                    $details['factors']['secondary'][] = $bobot;
                }
            }
            
            if (!empty($details['factors']['core'])) {
                $details['ncf'] = array_sum($details['factors']['core']) / count($details['factors']['core']);
            }
            if (!empty($details['factors']['secondary'])) {
                $details['nsf'] = array_sum($details['factors']['secondary']) / count($details['factors']['secondary']);
            }

            $details['total'] = ($persentaseCore * $details['ncf']) + ($persentaseSecondary * $details['nsf']);
            
            $detailed_results[] = $details;
        }

        $pdf = Pdf::loadView('perhitungan.pdf', compact('perhitungans', 'detailed_results'));
        return $pdf->stream('laporan-perhitungan.pdf');
    }
}
