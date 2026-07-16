<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class AkunBaruMail extends Mailable
{
    use Queueable, SerializesModels;

    public $nama;
    public $email;
    public $password;
    public $namaAnak;

    public function __construct($nama, $email, $password, $namaAnak = null)
    {
        $this->nama = $nama;
        $this->email = $email;
        $this->password = $password;
        $this->namaAnak = $namaAnak;
    }

    public function build()
    {
        return $this->from(env('MAIL_FROM_ADDRESS', 'noreply@situmbuh.com'), 'SiTumbuh')
                    ->subject('Selamat! Akun SiTumbuh Anda Telah Dibuat')
                    ->view('emails.akun_baru');
    }
}