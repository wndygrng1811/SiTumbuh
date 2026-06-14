<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id();
            $table->string('judul');
            $table->text('isi');
            $table->enum('jenis', ['pemeriksaan', 'jadwal', 'edukasi', 'pengumuman'])->default('pengumuman');
            $table->string('gambar')->nullable();
            $table->string('link')->nullable();
            $table->enum('target_role', ['kader', 'orang_tua', 'semua'])->default('semua');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasi');
    }
};