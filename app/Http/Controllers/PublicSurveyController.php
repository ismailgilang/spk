<?php

namespace App\Http\Controllers;

use App\Models\Kandidat;
use App\Models\Kriteria;
use App\Models\SurveyResponse;
use Illuminate\Http\Request;

class PublicSurveyController extends Controller
{
    public function create(Kandidat $kandidat)
    {
        $kriterias = Kriteria::with('subKriterias')->get();
        return view('survey.create', compact('kandidat', 'kriterias'));
    }

    public function store(Request $request, Kandidat $kandidat)
    {
        $request->validate([
            'surveyor_name' => 'nullable|string|max:255',
            'kandidat_id' => 'required|exists:kandidats,id',
            'penilaian' => 'required|array',
            'penilaian.*.kriteria_id' => 'required|exists:kriterias,id',
            'penilaian.*.nilai' => 'required|integer|min:1|max:5', // Assuming nilai is between 1 and 5
        ]);

        foreach ($request->penilaian as $penilaianData) {
            SurveyResponse::create([
                'kandidat_id' => $request->kandidat_id,
                'kriteria_id' => $penilaianData['kriteria_id'],
                'nilai' => $penilaianData['nilai'],
                'surveyor_name' => $request->surveyor_name,
            ]);
        }

        // Redirect to a thank you page or back to the candidate list
        return redirect()->route('public.survey.thankyou')
            ->with('success', 'Terima kasih atas partisipasi Anda dalam survey!');
    }
}
