# 📊 Data Warehouse Disdukcapil - Kabinet Data Bersatu

Repositori ini berisi dokumentasi proyek perancangan dan implementasi Data Warehouse untuk Dinas Kependudukan dan Pencatatan Sipil (Disdukcapil) sebagai bagian dari inisiatif transformasi digital sektor pemerintahan. Proyek ini dilakukan oleh tim **Kabinet Data Bersatu** dari Program Studi Sains Data, Institut Teknologi Sumatera.

## 🚀 Ringkasan Proyek

Data Warehouse ini dirancang untuk mengatasi berbagai tantangan seperti:
- Fragmentasi sistem informasi antar wilayah
- Keterlambatan pembaruan data
- Kualitas data rendah
- Akses data terbatas lintas sektor

Melalui penggunaan teknologi Microsoft SQL Server dan Power BI, sistem ini memungkinkan pengambilan keputusan real-time dan mendukung kebijakan nasional *Satu Data Indonesia*.

## 🎯 Tujuan Sistem

- Mengintegrasikan berbagai sumber data kependudukan
- Menyediakan platform pelaporan interaktif
- Mempercepat pembuatan laporan demografis
- Mendukung perencanaan strategis berbasis data

## 🧩 Ruang Lingkup

- **Sumber Data**: SIAK, sistem pelayanan online, input manual kecamatan, laporan bulanan
- **Fakta**: Population, Document Requests, Service Performance, Migration
- **Dimensi**: Time, Wilayah, Gender, Age_Group, Jenis_Dokumen, Status, Jenis_Layanan, Pegawai, Alasan_Pindah
- **Visualisasi**: Power BI dashboard & SSRS reporting

## 🏗️ Arsitektur Sistem - Three-Tier Architecture

Sistem ini dirancang menggunakan pendekatan **Three-Tier Architecture** untuk memisahkan proses dan meningkatkan skalabilitas:

1. **Tier 1 – Staging Layer**  
   Menyimpan data mentah hasil *extract* dari berbagai sumber (SIAK, laporan manual, dll). Validasi awal dan pengecekan kualitas dilakukan di sini.

2. **Tier 2 – Data Warehouse Layer**  
   Proses *transform* dan *load* data ke dalam model **Star Schema**. Data dibersihkan, distandarisasi, dan disimpan dalam bentuk tabel fakta dan dimensi.

3. **Tier 3 – Presentation Layer**  
   Menyediakan tampilan data melalui **Power BI** dan **SSRS** untuk analisis interaktif dan pelaporan formal yang mendukung pengambilan keputusan berbasis data.

Struktur ini membantu memastikan efisiensi proses ETL, kemudahan pemeliharaan jangka panjang, serta performa tinggi dalam eksekusi query analitik.

## 🛠️ Teknologi

- **Database**: Microsoft SQL Server
- **ETL Tools**: SQL Server Integration Services (SSIS)
- **Monitoring**: SQL Server Profiler, Dynamic Management Views
- **Visualisasi**: Power BI, SQL Server Reporting Services (SSRS)

## 🔄 ETL Pipeline

- **Extract**: Mengambil data dari sumber seperti API, CSV, Excel, dan database.
- **Transform**: Proses pembersihan, validasi, lookup foreign key, dan standarisasi format.
- **Load**: Data dimuat ke tabel dimensi terlebih dahulu, lalu ke tabel fakta. Semua proses dijalankan otomatis dan terjadwal menggunakan SQL Server Agent.

## 📈 Output Sistem

- Dashboard interaktif (Power BI)
- Laporan formal (SSRS)
- Query analitik untuk:
  - Persebaran dan pertumbuhan penduduk
  - Permohonan dan status dokumen
  - Evaluasi pelayanan publik
  - Analisis tren migrasi

## ✅ Evaluasi Proyek

**Keberhasilan:**
- Konsolidasi data dari berbagai sistem berhasil dilakukan
- Star Schema terimplementasi dengan baik
- Dashboard dan laporan formal tersedia sesuai kebutuhan

**Tantangan:**
- Perlu validasi kualitas data pasca-ETL
- Optimasi query untuk volume data besar
- Kelengkapan script ETL perlu ditinjau ulang

## 🔮 Rencana Pengembangan

- Penambahan fakta dan dimensi baru (e.g. survei kepuasan)
- Implementasi analisis prediktif dan machine learning
- Integrasi dengan data sektor lain (kesehatan, pendidikan)
- Peningkatan indexing dan partisi
- Tata kelola data dan penguatan keamanan akses

## 👥 Tim Proyek - Kabinet Data Bersatu

- **Ketua**: Baruna Abirawa – 122450097  
- **Anggota**:
  - Sesilia Putri Subandi – 122450012
  - Oktavia Nurwinda Puspitasari – 122450041
  - Safitri – 122450071
  - Dinda Nababan – 122450120

## 📚 Lisensi

Proyek ini dibuat untuk keperluan akademik di Institut Teknologi Sumatera dan tidak untuk distribusi komersial.

---

*Made with 💡 by Kabinet Data Bersatu @ Sains Data ITERA*
