<?php

namespace App\Http\Controllers;

use App\Models\Kandidat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KandidatController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $kandidats = Kandidat::all();
        return view('kandidat.index', compact('kandidats'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('kandidat.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nip' => 'required|unique:kandidats|max:20',
            'nama' => 'required|max:255',
            'jenis_kelamin' => 'required|in:L,P',
            'pendidikan_terakhir' => 'required|max:255',
            'pengalaman_mengajar' => 'required|integer',
            'foto' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'alamat' => 'nullable|string',
            'no_telp' => 'nullable|string|max:15',
        ]);

        $data = $request->except('foto');

        if ($request->hasFile('foto')) {
            $data['foto'] = $request->file('foto')->store('fotos', 'public');
        }

        Kandidat::create($data);

        return redirect()->route('kandidat.index')
            ->with('success', 'Kandidat created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Kandidat $kandidat)
    {
        return view('kandidat.show', compact('kandidat'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Kandidat $kandidat)
    {
        return view('kandidat.edit', compact('kandidat'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Kandidat $kandidat)
    {
        $request->validate([
            'nip' => 'required|max:20|unique:kandidats,nip,' . $kandidat->id,
            'nama' => 'required|max:255',
            'jenis_kelamin' => 'required|in:L,P',
            'pendidikan_terakhir' => 'required|max:255',
            'pengalaman_mengajar' => 'required|integer',
            'foto' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'alamat' => 'nullable|string',
            'no_telp' => 'nullable|string|max:15',
        ]);

        $data = $request->except('foto');

        if ($request->hasFile('foto')) {
            if ($kandidat->foto) {
                Storage::disk('public')->delete($kandidat->foto);
            }
            $data['foto'] = $request->file('foto')->store('fotos', 'public');
        }

        $kandidat->update($data);

        return redirect()->route('kandidat.index')
            ->with('success', 'Kandidat updated successfully');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Kandidat $kandidat)
    {
        if ($kandidat->foto) {
            Storage::disk('public')->delete($kandidat->foto);
        }
        
        $kandidat->delete();

        return redirect()->route('kandidat.index')
            ->with('success', 'Kandidat deleted successfully');
    }
}
