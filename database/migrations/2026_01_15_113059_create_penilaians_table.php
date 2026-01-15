<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('penilaians', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kandidat_id')->constrained('kandidats')->onDelete('cascade');
            $table->foreignId('kriteria_id')->constrained('kriterias')->onDelete('cascade');
            $table->integer('nilai')->comment('Nilai penilaian dari kandidat');
            $table->integer('nilai_target')->default(5)->comment('Nilai target/profil ideal');
            $table->timestamps();
            
            // Prevent duplicate entry for same kandidat and kriteria
            $table->unique(['kandidat_id', 'kriteria_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('penilaians');
    }
};
