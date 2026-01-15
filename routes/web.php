<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\KriteriaController;
use App\Http\Controllers\KandidatController;
use App\Http\Controllers\GapMappingController;
use App\Http\Controllers\SubKriteriaController;
use App\Http\Controllers\PenilaianController;
use App\Http\Controllers\PerhitunganController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PublicSurveyController;

Route::get('/', function () {
    return view('auth.login');
});

Route::get('/dashboard', [DashboardController::class, 'index'])->middleware(['auth', 'verified'])->name('dashboard');

// Public Survey Routes
Route::get('survey/thankyou', function () {
    return view('survey.thankyou');
})->name('public.survey.thankyou');
Route::get('survey/{kandidat}', [PublicSurveyController::class, 'create'])->name('public.survey.create');
Route::post('survey/{kandidat}', [PublicSurveyController::class, 'store'])->name('public.survey.store');


Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::resource('kriteria', KriteriaController::class);
    Route::resource('kandidat', KandidatController::class);
    Route::resource('gap-mapping', GapMappingController::class)->only(['index']);
    Route::resource('sub-kriteria', SubKriteriaController::class)->except(['index', 'show', 'create', 'edit']);
    // Removed Penilaian Resource and candidta/{kandidat}/penilaian route
    // Route::resource('penilaian', PenilaianController::class);
    // Route::get('kandidat/{kandidat}/penilaian', [PenilaianController::class, 'create'])->name('kandidat.penilaian.create');

    Route::get('perhitungan', [PerhitunganController::class, 'index'])->name('perhitungan.index');
    Route::post('perhitungan/calculate', [PerhitunganController::class, 'calculate'])->name('perhitungan.calculate');
    Route::get('perhitungan/pdf', [PerhitunganController::class, 'downloadPDF'])->name('perhitungan.pdf');
});

require __DIR__.'/auth.php';
