<?php

namespace App\Http\Controllers;

use App\Models\Kandidat;
use App\Models\Kriteria;
use App\Models\Penilaian; // Still needed if Penilaian model still exists, but not used for input
use App\Models\SurveyResponse; // Import the new model
use Illuminate\Http\Request;

class PenilaianController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $penilaians = SurveyResponse::with(['kandidat', 'kriteria'])->get(); // Fetch SurveyResponse
        return view('penilaian.index', compact('penilaians'));
    }

    // Removed create and store methods as they are no longer used for input
}
