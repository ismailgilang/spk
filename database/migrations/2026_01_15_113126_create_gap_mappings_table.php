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
        Schema::create('gap_mappings', function (Blueprint $table) {
            $table->id();
            $table->integer('gap')->unique()->comment('Selisih nilai (Gap)');
            $table->decimal('bobot', 3, 1)->comment('Bobot konversi GAP');
            $table->string('keterangan');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gap_mappings');
    }
};
