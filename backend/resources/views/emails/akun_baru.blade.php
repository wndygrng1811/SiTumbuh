<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Akun SiTumbuh Anda</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background-color: #E85D75;
            padding: 24px;
            text-align: center;
        }
        .header h1 {
            color: white;
            margin: 0;
            font-size: 24px;
        }
        .content {
            padding: 24px;
        }
        .greeting {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 16px;
        }
        .message {
            color: #555;
            line-height: 1.6;
            margin-bottom: 24px;
        }
        .credentials {
            background-color: #FFF5F7;
            padding: 16px;
            border-radius: 12px;
            margin: 20px 0;
            border-left: 4px solid #E85D75;
        }
        .credentials p {
            margin: 8px 0;
        }
        .credentials .label {
            font-weight: bold;
            color: #E85D75;
            width: 80px;
            display: inline-block;
        }
        .button {
            display: block;
            width: fit-content;
            margin: 24px auto 0;
            padding: 12px 28px;
            background-color: #E85D75;
            color: white;
            text-decoration: none;
            border-radius: 30px;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            padding: 16px;
            font-size: 12px;
            color: #999;
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌸 SiTumbuh</h1>
        </div>
        <div class="content">
            <div class="greeting">Halo, {{ $nama }}! 👋</div>
            <div class="message">
                Kader Posyandu telah mendaftarkan Anda sebagai pengguna <strong>SiTumbuh</strong>. 
                Aplikasi ini membantu Anda memantau tumbuh kembang buah hati.
            </div>

            <div class="credentials">
                <p><span class="label">📧 Email:</span> {{ $email }}</p>
                <p><span class="label">🔑 Password:</span> {{ $password }}</p>
            </div>

            @if($namaAnak)
            <div class="message">
                Data anak <strong>{{ $namaAnak }}</strong> sudah terdaftar dalam sistem.
            </div>
            @endif

            <div class="message">
                🔐 <strong>Tips Keamanan:</strong> Segera ganti password Anda setelah login pertama kali.
            </div>

            <a href="{{ env('APP_URL', 'http://localhost:8000') }}" class="button">
                Login Sekarang →
            </a>
        </div>
        <div class="footer">
            © {{ date('Y') }} SiTumbuh - Aplikasi Pemantauan Tumbuh Kembang Anak<br>
            Email ini dikirim secara otomatis, mohon tidak membalas.
        </div>
    </div>
</body>
</html>