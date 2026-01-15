<?php

namespace App\Http\Controllers;

use App\Models\Kriteria;
use Illuminate\Http\Request;

class KriteriaController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $kriterias = Kriteria::all();
        return view('kriteria.index', compact('kriterias'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('kriteria.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'kode_kriteria' => 'required|unique:kriterias|max:10',
            'nama_kriteria' => 'required|max:255',
            'tipe' => 'required|in:core_factor,secondary_factor',
            'bobot' => 'required|numeric',
            'keterangan' => 'nullable|string',
        ]);

        Kriteria::create($request->all());

        return redirect()->route('kriteria.index')
            ->with('success', 'Kriteria created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Kriteria $kriterium)
    {
        return view('kriteria.show', compact('kriterium'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Kriteria $kriterium)
    {
        return view('kriteria.edit', compact('kriterium'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Kriteria $kriterium)
    {
        $request->validate([
            'kode_kriteria' => 'required|max:10|unique:kriterias,kode_kriteria,' . $kriterium->id,
            'nama_kriteria' => 'required|max:255',
            'tipe' => 'required|in:core_factor,secondary_factor',
            'bobot' => 'required|numeric',
            'keterangan' => 'nullable|string',
        ]);

        $kriterium->update($request->all());

        return redirect()->route('kriteria.index')
            ->with('success', 'Kriteria updated successfully');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Kriteria $kriterium)
    {
        $kriterium->delete();

        return redirect()->route('kriteria.index')
            ->with('success', 'Kriteria deleted successfully');
    }
}
