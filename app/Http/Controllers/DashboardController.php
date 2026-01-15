<?php

namespace App\Http\Controllers;

use App\Models\Kandidat;
use App\Models\Kriteria;
use App\Models\Penilaian;
use App\Models\Perhitungan;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $jumlahKandidat = Kandidat::count();
        $jumlahKriteria = Kriteria::count();
        $jumlahPenilaian = Penilaian::count();
        $topKandidat = Perhitungan::with('kandidat')->where('ranking', 1)->first();

        return view('dashboard', compact(
            'jumlahKandidat',
            'jumlahKriteria',
            'jumlahPenilaian',
            'topKandidat'
        ));
    }
}
