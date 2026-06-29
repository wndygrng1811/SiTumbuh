<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Tabel notifikasi
        if (!Schema::hasTable('notifikasi')) {
            Schema::create('notifikasi', function (Blueprint $table) {
                $table->id();
                $table->string('judul');
                $table->text('isi');
                $table->string('jenis')->nullable();
                $table->string('gambar')->nullable();
                $table->string('link')->nullable();
                $table->string('target_role')->nullable();
                $table->timestamps();
            });
        }

        // Tabel notifikasi_user
        if (!Schema::hasTable('notifikasi_user')) {
            Schema::create('notifikasi_user', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('notifikasi_id');
                $table->unsignedBigInteger('user_id');
                $table->boolean('is_read')->default(false);
                $table->timestamp('read_at')->nullable();
                $table->timestamps();
                
                $table->foreign('notifikasi_id')->references('id')->on('notifikasi')->onDelete('cascade');
                $table->foreign('user_id')->references('user_id')->on('users')->onDelete('cascade');
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('notifikasi_user');
        Schema::dropIfExists('notifikasi');
    }
};