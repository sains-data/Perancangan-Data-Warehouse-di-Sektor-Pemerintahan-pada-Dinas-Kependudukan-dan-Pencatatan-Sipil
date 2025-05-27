# 🏛️ Perancangan Data Warehouse Disdukcapil 🇮🇩
**Kabinet Data Bersatu** - Sains Data ITERA | 2025  
📁 Proyek Akademik | 🗃️ SQL Server • SSMS • Power BI • SSRS


---

## 📚 Ringkasan Proyek

Repositori ini berisi dokumentasi lengkap proyek perancangan **Data Warehouse (DW)** untuk instansi **Dinas Kependudukan dan Pencatatan Sipil (Disdukcapil)** yang bertujuan untuk meningkatkan efisiensi, transparansi, dan akurasi layanan publik berbasis data.

---

## 🎯 Tujuan Sistem

- 📌 Integrasi data antar wilayah
- 📊 Analisis multidimensi penduduk dan layanan
- ⏱️ Pengambilan keputusan real-time
- 📈 Visualisasi interaktif via Power BI

---

## 🧩 Ruang Lingkup

- **Sumber Data**: SIAK, sistem pelayanan online, input manual kecamatan, laporan bulanan
- **Fakta**: Population, Document Requests, Service Performance, Migration
- **Dimensi**: Time, Wilayah, Gender, Age_Group, Jenis_Dokumen, Status, Jenis_Layanan, Pegawai, Alasan_Pindah
- **Visualisasi**: Power BI dashboard & SSRS reporting

## 🧱 Arsitektur Sistem - Three-Tier Architecture

```mermaid
graph TD
    A[Sumber Data] --> B[Staging Area]
    B --> C[Data Warehouse - Star Schema]
    C --> D[Presentation Layer - Power BI & SSRS]
```

## 🔄 ETL Pipeline
###  ⚠️ Semua proses ETL dilakukan secara manual menggunakan SQL Query di SSMS.
Salah satu contoh skrip ETL manual via SSMS
1. **Extract**: Data diambil dari berbagai sumber (CSV, API, input manual)
2. **Transform**: Proses pembersihan, standarisasi, dan penggabungan
3. **Load**: Data dimuat ke tabel dimensi dan fakta sesuai skema bintang

## 📥 Dataset Sumber

- `Aplikasi SIAK` - Data registrasi penduduk (real-time)
- `Sistem Pelayanan Online` - Permohonan dokumen (harian)
- `Manual Input Kecamatan` - Migrasi penduduk (mingguan)
- `Laporan Statistik Bulanan` - Agregasi jumlah penduduk & performa layanan


## 📁 Struktur Data Warehouse

### 📊 Tabel Fakta

| Nama Tabel | Deskripsi |
|------------|-----------|
| `fakta_population` | Jumlah penduduk |
| `fakta_document` | Permohonan dokumen |
| `fakta_service` | Evaluasi pelayanan publik |
| `fakta_migration` | Data perpindahan penduduk |

### 🧩 Tabel Dimensi

| Nama Dimensi | Atribut Utama |
|-------------|---------------|
| `dim_waktu` | Tahun, Bulan, Hari |
| `dim_wilayah` | Provinsi, Kab/Kota, Kecamatan |
| `dim_gender` | Jenis Kelamin |
| `dim_jenis_dokumen` | KTP, KK, Akta, dll |
| `dim_status` | Status permohonan |
| `dim_pegawai` | Nama Pegawai, Jabatan |
| `dim_alasan_pindah` | Alasan migrasi (kerja, pendidikan) |

---

## 🛠️ Tools & Teknologi

| Komponen | Tools |
|----------|-------|
| **Database** | Microsoft SQL Server |
| **ETL** | **Manual SQL Query via SSMS** |
| **Modeling** | SSMS |
| **Visualisasi** | Power BI, SSRS |
| **Pemantauan** | SQL Profiler, DMV |

---
## 🧪 Contoh Skrip SQL

Proyek ini mencakup ratusan baris skrip SQL untuk membangun dan mengelola Data Warehouse, mulai dari definisi tabel hingga analisis data. Karena banyaknya skrip yang digunakan, hanya **beberapa potongan kode** yang ditampilkan di bawah sebagai contoh.

### 📌 Contoh DDL: Tabel Dimensi Waktu

```sql
CREATE TABLE dim_time ( 
    time_id INT PRIMARY KEY, 
    tanggal DATE, 
    hari INT, 
    bulan INT, 
    tahun INT, 
    kuartal INT, 
    semester INT 
);
```

### 📌 Contoh BULK INSERT: Staging Aplikasi SIAK
```sql
BULK INSERT staging_siak
FROM 'C:\path\to\Dataset Aplikasi SIAK.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
```

### 📌 Contoh Transformasi: Isi dim_age_group
```sql
INSERT INTO dim_age_group (rentang_usia)
SELECT DISTINCT
    CASE 
        WHEN Usia BETWEEN 0 AND 10 THEN '0-10'
        WHEN Usia BETWEEN 11 AND 20 THEN '11-20'
        -- dst...
        ELSE 'Tidak Diketahui'
    END
FROM staging_siak
WHERE Usia IS NOT NULL;
```

### 📌 Contoh Analitik: Distribusi Penduduk
```sql
SELECT dag.rentang_usia, dg.gender, 
       SUM(fp.jumlah_penduduk) AS jumlah_penduduk
FROM fact_population fp
JOIN dim_age_group dag ON fp.age_group_id = dag.age_group_id
JOIN dim_gender dg ON fp.gender_id = dg.gender_id
GROUP BY dag.rentang_usia, dg.gender
ORDER BY dag.rentang_usia;
```

## 📊 Tampilan Visualisasi

### 📌 Dashboard Interaktif - Power BI
### 📄 Laporan Formal - SSRS

#### 🧭 Fitur Visualisasi:
- Persebaran & pertumbuhan penduduk
- Status permohonan dokumen  
- Kinerja pelayanan publik
- Tren migrasi penduduk


---



## 🧠 Evaluasi & Rencana Pengembangan

### ✅ Yang Berhasil
- ✅ ETL otomatis dan terjadwal
- ✅ Konsolidasi data dari 4 sumber utama
- ✅ Visualisasi responsif dan informatif

### ⚠️ Perlu Ditingkatkan
- Validasi data pasca-ETL
- Optimasi performa query besar
- Penambahan sumber data baru (e.g. survei)

---

## 👨‍💻 Tim Proyek – Kabinet Data Bersatu

| Nama | NIM | Role |
|------|-----|------|
| 🧠 **Baruna Abirawa** | 122450097 | **Ketua** |
| Sesilia Putri Subandi | 122450012 | Anggota |
| Oktavia Nurwinda Puspitasari | 122450041 | Anggota |
| Safitri | 122450071 | Anggota |
| Dinda Nababan | 122450120 | Anggota |

---

## 📂 Struktur Repositori

```
📦Disdukcapil-DW
 ┣ 📁 Dataset/
 ┃ ┣ 📄 Dataset Aplikasi SIAK.csv
 ┃ ┣ 📄 Dataset Kepindahan.csv
 ┃ ┗ 📄 Dataset Pelayanan Online.csv
 ┣ 📁 misi 1/
 ┃ ┗ 📄 Misi1_Kelompok 10_DW_RB.pdf
 ┣ 📁 misi 2/
 ┃ ┗ 📄 Misi2_Kelompok 10_DW_RB.pdf
 ┣ 📁 misi 3/
 ┃ ┣ 📄 DW_DISDUKCAPIL.sql
 ┃ ┗ 📄 Misi3_Kelompok 10_DW_RB.pdf
 ┗ 📄 README.md
```

---

## 📃 Lisensi

Repositori ini dibuat untuk kepentingan akademik di **Institut Teknologi Sumatera** dan tidak diperuntukkan untuk distribusi komersial.

---

<div align="center">

**Dibuat dengan 💡 oleh Kabinet Data Bersatu | Sains Data ITERA 2025**

</div>
