# Rencana Implementasi Sistem Website CDC / UPA. PKK Politeknik Negeri Lhokseumawe (PNL)
## Struktur Sistem Terpadu: Portal Institusi CDC & Agenda Khusus PNL Job Fair 2026

Dokumentasi ini telah disesuaikan dengan arsitektur berjenjang yang rapi:
1. **Landing Page Institusi**: Berada di tingkat utama Career Development Center (CDC) / UPA. Pengembangan Karir dan Kewirausahaan (PKK) Politeknik Negeri Lhokseumawe (PNL).
2. **Pembuatan Akun (Register & Login)**: Registrasi akun CDC terpadu bagi Mahasiswa PNL (NIM), Alumni PNL, dan Pencari Kerja Umum.
3. **Dashboard Pengguna Terotentikasi**: Dasbor personal pengguna yang memuat agenda resmi **PNL Job Fair 2026**, pendaftaran kehadiran, dan penerbitan **E-Tiket QR Code**.

---

### 1. Struktur Halaman & Alur Pengguna

#### A. Landing Page CDC / UPA. PKK PNL (`/`)
- **Navigasi Utama**: Logo resmi PNL & CDC, Menu Layanan Karir & Kewirausahaan, Kontak, dan Tombol **Masuk / Daftar Akun**.
- **Hero Section**: Profil resmi UPA PKK PNL sebagai gerbang karir sivitas akademika vokasi PNL.
- **Highlight Card Event**: Banner pengumuman khusus **"Agenda Mendatang: PNL Job Fair 2026"** dengan tanggal, lokasi di Gedung PNL, dan hitung mundur (*countdown*).
- **Layanan Karir & Inkubasi**: Pelatihan kerja, bursa karir, serta inkubator wirausaha mahasiswa PNL.

#### B. Pembuatan Akun & Masuk CDC (`/auth/register` & `/auth/login`)
- **Pilihan Kategori**:
  - `Mahasiswa Aktif PNL` (NIM & Jurusan/Prodi).
  - `Alumni PNL` (NIM & Tahun Kelulusan).
  - `Umum` (NIK / Asal Instansi).
- **Form Data**: Nama Lengkap, Email, Nomor WhatsApp, Kata Sandi, dan Bidang Keahlian.

#### C. Dashboard Pengguna (`/dashboard`)
Setelah pengguna login, dashboard menampilkan:
1. **Profil Pengguna**: Nama, Kategori (Mahasiswa/Alumni/Umum), dan NIM/Jurusan.
2. **Card Utama: Agenda PNL Job Fair 2026**:
   - Status Pendaftaran: [Belum Mendaftar / Sudah Terdaftar].
   - Informasi Acara: Jadwal, Sesi (Pagi/Siang), Lokasi Gedung/Auditorium PNL, dan daftar perusahaan mitra yang hadir.
   - Tombol Aksi: **"Daftar Event Job Fair 2026"** (1-klik konfirmasi).
3. **Widget E-Tiket & QR Code**:
   - Menampilkan kode tiket unik (`PNL-JF26-XXXX`).
   - QR Code aktif untuk ditunjukkan di pintu masuk saat hari pelaksanaan.
   - Tombol **"Download / Simpan E-Tiket"**.

#### D. Modul Tambahan Operasional Hari-H
- **Gate Scanner Panitia (`/scanner`)**: Pemindai QR kamera cepat di gerbang pintu masuk untuk verifikasi kehadiran.
- **Admin CDC (`/admin`)**: Monitoring statistik pendaftar dan ekspor data ke Excel.

---

### 2. Roadmap Pengerjaan (3 Sprint Cepat)
- **Sprint 1**: Desain Landing Page resmi CDC PNL & Form Pembuatan Akun/Login.
- **Sprint 2**: Dashboard Pengguna, Widget Agenda PNL Job Fair 2026, dan E-Tiket QR Code.
- **Sprint 3**: Scanner Pintu Masuk Panitia, Rekapitulasi Data Admin, & Uji Coba.
