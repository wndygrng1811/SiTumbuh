<?php

use App\Mail\AkunBaruMail;
use Illuminate\Support\Facades\Mail;

Route::get('/test-email', function () {
    Mail::to('tujuan@gmail.com')->send(new AkunBaruMail(
        'Nama Penerima',
        'tujuan@gmail.com',
        '123456',
        'Anak Test'
    ));
    return 'Email telah dikirim!';
});
