<?php

namespace App\Http\Controllers;

use App\Models\SubKriteria;
use Illuminate\Http\Request;

class SubKriteriaController extends Controller
{
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'kriteria_id' => 'required|exists:kriterias,id',
            'nilai' => 'required|integer',
            'keterangan' => 'required|string|max:255',
        ]);

        SubKriteria::create($request->all());

        return redirect()->route('kriteria.show', $request->kriteria_id)
            ->with('success', 'Sub Kriteria created successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(SubKriteria $subKriteria)
    {
        $kriteria_id = $subKriteria->kriteria_id;
        $subKriteria->delete();

        return redirect()->route('kriteria.show', $kriteria_id)
            ->with('success', 'Sub Kriteria deleted successfully');
    }
}
