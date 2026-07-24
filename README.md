# SiTumbuh

SiTumbuh merupakan aplikasi pemantauan tumbuh kembang anak yang dirancang untuk membantu orang tua dan kader posyandu dalam mengelola data anak, memantau pertumbuhan, melihat jadwal imunisasi, serta memperoleh informasi edukasi mengenai kesehatan anak.

## Fitur Utama

### Orang Tua
- Login dan autentikasi pengguna
- Mengelola profil
- Menambah dan mengelola data anak
- Melihat riwayat pertumbuhan anak
- Melihat status pertumbuhan
- Melihat jadwal imunisasi
- Membaca artikel edukasi

### Kader
- Login kader
- Mengelola data orang tua
- Mengelola data anak
- Menginput data pertumbuhan anak
- Mengelola jadwal imunisasi
- Mengelola artikel edukasi
- Mengelola kategori edukasi

## Teknologi yang Digunakan

### Backend
- Laravel
- PHP
- MySQL
- REST API

### Frontend
- Flutter
- Dart

## Struktur Repository

```
SiTumbuh
│
├── backend/      # Source code backend Laravel
├── frontend/     # Source code aplikasi Flutter
└── README.md
```

## Struktur Unit Testing

Seluruh file unit testing backend disimpan pada folder:

```
backend/tests/
├── Feature/
├── Unit/
└── TestCase.php
```

- **Feature** digunakan untuk pengujian fitur aplikasi.
- **Unit** digunakan untuk pengujian unit pada fungsi atau komponen tertentu.

## Cara Menjalankan Backend

1. Masuk ke folder backend

```bash
cd backend
```

2. Install dependency

```bash
composer install
```

3. Salin file environment

```bash
cp .env.example .env
```

4. Generate application key

```bash
php artisan key:generate
```

5. Atur konfigurasi database pada file `.env`

6. Jalankan migrasi

```bash
php artisan migrate
```

7. Jalankan server

```bash
php artisan serve
```

## Cara Menjalankan Frontend

1. Masuk ke folder frontend

```bash
cd frontend
```

2. Install dependency

```bash
flutter pub get
```

3. Jalankan aplikasi

```bash
flutter run
```

## Tim Pengembang

- Windy Yohana Gurning (3312401066)
- Jesica Kristina Manalu (3312401069)

## Lisensi

Project ini dibuat untuk keperluan akademik dan pengembangan sistem informasi pemantauan tumbuh kembang anak.
