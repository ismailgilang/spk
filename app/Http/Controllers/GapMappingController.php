<?php

namespace App\Http\Controllers;

use App\Models\GapMapping;
use Illuminate\Http\Request;

class GapMappingController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $gapMappings = GapMapping::all();
        return view('gap-mapping.index', compact('gapMappings'));
    }
}
