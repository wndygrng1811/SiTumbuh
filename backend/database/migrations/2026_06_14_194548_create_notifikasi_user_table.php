<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasi_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('notifikasi_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('user_id');
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            
            $table->foreign('user_id')->references('user_id')->on('users')->onDelete('cascade');
            $table->unique(['notifikasi_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasi_user');
    }
};