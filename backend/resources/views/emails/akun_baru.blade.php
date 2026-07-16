<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Akun SiTumbuh</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f7fc;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #E85D75, #D05A7E);
            padding: 30px 20px;
            text-align: center;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: 1px;
        }
        .header p {
            color: rgba(255,255,255,0.85);
            margin: 8px 0 0;
            font-size: 16px;
        }
        .content {
            padding: 40px 30px;
        }
        .content h2 {
            color: #2d3748;
            font-size: 22px;
            margin-top: 0;
            margin-bottom: 16px;
        }
        .content p {
            color: #4a5568;
            font-size: 16px;
            line-height: 1.7;
            margin-bottom: 16px;
        }
        .credentials {
            background-color: #f7fafc;
            border-radius: 12px;
            padding: 20px 24px;
            margin: 24px 0;
            border-left: 4px solid #E85D75;
        }
        .credentials .label {
            font-size: 14px;
            color: #718096;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .credentials .value {
            font-size: 18px;
            color: #2d3748;
            font-weight: 600;
            margin-bottom: 12px;
            word-break: break-all;
        }
        .credentials .value:last-child {
            margin-bottom: 0;
        }
        .btn {
            display: inline-block;
            background: linear-gradient(135deg, #E85D75, #D05A7E);
            color: #ffffff !important;
            text-decoration: none;
            padding: 14px 32px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 16px;
            margin-top: 8px;
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(232, 93, 117, 0.35);
        }
        .footer {
            text-align: center;
            padding: 24px 30px;
            border-top: 1px solid #e2e8f0;
            font-size: 14px;
            color: #a0aec0;
        }
        .footer a {
            color: #E85D75;
            text-decoration: none;
        }
        .footer a:hover {
            text-decoration: underline;
        }
        .warning {
            background-color: #fff5f5;
            border-radius: 8px;
            padding: 12px 16px;
            margin: 16px 0;
            border: 1px solid #feb2b2;
            font-size: 14px;
            color: #c53030;
        }
        .warning strong {
            display: block;
            margin-bottom: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- HEADER -->
        <div class="header">
            <h1>🌸 SiTumbuh</h1>
            <p>Pantau Tumbuh Kembang Anak Anda</p>
        </div>

        <!-- CONTENT -->
        <div class="content">
            <h2>Halo, {{ $nama }}! 👋</h2>

            <p>Selamat! Akun <strong>SiTumbuh</strong> Anda telah berhasil dibuat.</p>

            <p>Berikut adalah informasi akun Anda:</p>

            <div class="credentials">
                <div class="label">📧 Email</div>
                <div class="value">{{ $email }}</div>

                <div class="label">🔑 Password</div>
                <div class="value">{{ $password }}</div>
            </div>

            @if($namaAnak)
                <p><strong>👶 Data Anak:</strong> {{ $namaAnak }}</p>
            @endif

            <div class="warning">
                <strong>⚠️ Keamanan:</strong>
                Simpan password ini dengan baik. Jangan berikan kepada siapa pun.
            </div>

            <p style="margin-top: 24px;">
                <a href="{{ env('APP_URL', 'http://localhost') }}" class="btn">
                    🚀 Login Sekarang
                </a>
            </p>

            <p style="color: #718096; font-size: 15px; margin-top: 24px;">
                Jika Anda tidak merasa mendaftar, abaikan email ini.
            </p>
        </div>

        <!-- FOOTER -->
        <div class="footer">
            <p>
                &copy; {{ date('Y') }} <a href="{{ env('APP_URL', 'http://localhost') }}">SiTumbuh</a>.
                Dibuat dengan ❤️ untuk tumbuh kembang anak.
            </p>
        </div>
    </div>
</body>
</html>