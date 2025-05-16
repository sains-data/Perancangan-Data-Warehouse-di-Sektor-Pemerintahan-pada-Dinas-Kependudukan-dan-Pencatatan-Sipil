-- ============================
-- DATABASE & STAGING TABLES
-- ============================
CREATE DATABASE DW_Disdukcapil;
GO

USE DW_Disdukcapil;
GO

-- STAGING: Population (SIAK)
CREATE TABLE staging_population (
    tanggal DATE,
    kode_wilayah NVARCHAR(20),
    gender NVARCHAR(10),
    age_group NVARCHAR(20),
    jumlah_penduduk INT
);

-- STAGING: Document Requests (Sistem Pelayanan Online)
CREATE TABLE staging_document_requests (
    tanggal DATE,
    kode_wilayah NVARCHAR(20),
    jenis_dokumen NVARCHAR(50),
    status NVARCHAR(20),
    jumlah_permohonan INT
);

-- STAGING: Migration (Manual Kecamatan)
CREATE TABLE staging_migration (
    tanggal DATE,
    wilayah_asal NVARCHAR(20),
    wilayah_tujuan NVARCHAR(20),
    alasan NVARCHAR(50),
    jumlah_penduduk_migrasi INT
);

-- STAGING: Service Performance
CREATE TABLE staging_service_performance (
    tanggal DATE,
    kode_wilayah NVARCHAR(20),
    jenis_layanan NVARCHAR(50),
    nama_pegawai NVARCHAR(100),
    jabatan NVARCHAR(100),
    unit_kerja NVARCHAR(100),
    jumlah_layanan INT,
    rata_rata_waktu_layanan FLOAT
);

-- STAGING: Wilayah (dim_wilayah)
CREATE TABLE staging_wilayah (
    kode_wilayah NVARCHAR(20),
    provinsi NVARCHAR(50),
    kabupaten_kota NVARCHAR(50),
    kecamatan NVARCHAR(50),
    kelurahan NVARCHAR(50)
);
GO

-- ============================
-- DIMENSI
-- ============================
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    tanggal DATE,
    hari INT,
    bulan INT,
    tahun INT,
    kuartal INT,
    semester INT
);

CREATE TABLE dim_wilayah (
    wilayah_id INT IDENTITY(1,1) PRIMARY KEY,
    kode_wilayah NVARCHAR(20),
    provinsi NVARCHAR(50),
    kabupaten_kota NVARCHAR(50),
    kecamatan NVARCHAR(50),
    kelurahan NVARCHAR(50)
);

CREATE TABLE dim_gender (
    gender_id INT IDENTITY(1,1) PRIMARY KEY,
    gender NVARCHAR(10)
);

CREATE TABLE dim_age_group (
    age_group_id INT IDENTITY(1,1) PRIMARY KEY,
    rentang_usia NVARCHAR(20)
);

CREATE TABLE dim_jenis_dokumen (
    jenis_dokumen_id INT IDENTITY(1,1) PRIMARY KEY,
    nama_dokumen NVARCHAR(50)
);

CREATE TABLE dim_status (
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    status NVARCHAR(20)
);

CREATE TABLE dim_jenis_layanan (
    jenis_layanan_id INT IDENTITY(1,1) PRIMARY KEY,
    nama_layanan NVARCHAR(100)
);

CREATE TABLE dim_pegawai (
    pegawai_id INT IDENTITY(1,1) PRIMARY KEY,
    nama NVARCHAR(100),
    jabatan NVARCHAR(100),
    unit_kerja NVARCHAR(100)
);

CREATE TABLE dim_alasan_pindah (
    alasan_id INT IDENTITY(1,1) PRIMARY KEY,
    alasan NVARCHAR(100)
);

-- ============================
-- TABEL FAKTA
-- ============================
CREATE TABLE fact_population (
    population_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT,
    wilayah_id INT,
    gender_id INT,
    age_group_id INT,
    jumlah_penduduk INT
);

CREATE TABLE fact_document_requests (
    permohonan_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT,
    wilayah_id INT,
    jenis_dokumen_id INT,
    status_id INT,
    jumlah_permohonan INT
);

CREATE TABLE fact_migration (
    migration_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT,
    wilayah_id_asal INT,
    wilayah_id_tujuan INT,
    alasan_id INT,
    jumlah_penduduk_migrasi INT
);

CREATE TABLE fact_service_performance (
    performance_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT,
    wilayah_id INT,
    jenis_layanan_id INT,
    pegawai_id INT,
    jumlah_layanan INT,
    rata_rata_waktu_layanan FLOAT
);
GO

-- =======================
-- ETL Staging - Dimensi 
-- =======================

# dim_time
INSERT INTO dim_time (time_id, tanggal, hari, bulan, tahun, kuartal, semester)
SELECT DISTINCT 
    CONVERT(INT, FORMAT(tanggal, 'yyyyMMdd')),
    tanggal,
    DAY(tanggal),
    MONTH(tanggal),
    YEAR(tanggal),
    DATEPART(QUARTER, tanggal),
    CASE 
        WHEN MONTH(tanggal) <= 6 THEN 1
        ELSE 2
    END
FROM staging_population;

# dim_wilayah
INSERT INTO dim_wilayah (kode_wilayah, provinsi, kabupaten_kota, kecamatan, kelurahan)
SELECT DISTINCT kode_wilayah, provinsi, kabupaten_kota, kecamatan, kelurahan
FROM staging_wilayah;

# dim_gender, dim_age
INSERT INTO dim_gender (gender)
SELECT DISTINCT gender FROM staging_population;

INSERT INTO dim_age_group (rentang_usia)
SELECT DISTINCT age_group FROM staging_population;

#dim_jenis_dokumen, dim_status
INSERT INTO dim_jenis_dokumen (nama_dokumen)
SELECT DISTINCT jenis_dokumen FROM staging_document_requests;

INSERT INTO dim_status (status)
SELECT DISTINCT status FROM staging_document_requests;

# dim_jenis_layanan, dim_pegawai
INSERT INTO dim_jenis_layanan (nama_layanan)
SELECT DISTINCT jenis_layanan FROM staging_service_performance;

INSERT INTO dim_pegawai (nama, jabatan, unit_kerja)
SELECT DISTINCT nama_pegawai, jabatan, unit_kerja FROM staging_service_performance;


# dim_alasan_pindah
INSERT INTO dim_alasan_pindah (alasan)
SELECT DISTINCT alasan FROM staging_migration;



-- =======================
-- ETL Staging - Fakta 
-- =======================

# fact_population
INSERT INTO fact_population (time_id, wilayah_id, gender_id, age_group_id, jumlah_penduduk)
SELECT 
    CONVERT(INT, FORMAT(SP.tanggal, 'yyyyMMdd')),
    W.wilayah_id,
    G.gender_id,
    A.age_group_id,
    SP.jumlah_penduduk
FROM staging_population SP
JOIN dim_wilayah W ON SP.kode_wilayah = W.kode_wilayah
JOIN dim_gender G ON SP.gender = G.gender
JOIN dim_age_group A ON SP.age_group = A.rentang_usia;

# fact_document_requests
INSERT INTO fact_document_requests (time_id, wilayah_id, jenis_dokumen_id, status_id, jumlah_permohonan)
SELECT 
    CONVERT(INT, FORMAT(SD.tanggal, 'yyyyMMdd')),
    W.wilayah_id,
    D.jenis_dokumen_id,
    S.status_id,
    SD.jumlah_permohonan
FROM staging_document_requests SD
JOIN dim_wilayah W ON SD.kode_wilayah = W.kode_wilayah
JOIN dim_jenis_dokumen D ON SD.jenis_dokumen = D.nama_dokumen
JOIN dim_status S ON SD.status = S.status;

# fact_migration
INSERT INTO fact_migration (time_id, wilayah_id_asal, wilayah_id_tujuan, alasan_id, jumlah_penduduk_migrasi)
SELECT 
    CONVERT(INT, FORMAT(SM.tanggal, 'yyyyMMdd')),
    WA.wilayah_id,
    WT.wilayah_id,
    A.alasan_id,
    SM.jumlah_penduduk_migrasi
FROM staging_migration SM
JOIN dim_wilayah WA ON SM.wilayah_asal = WA.kode_wilayah
JOIN dim_wilayah WT ON SM.wilayah_tujuan = WT.kode_wilayah
JOIN dim_alasan_pindah A ON SM.alasan = A.alasan;

# fact_service_performance
INSERT INTO fact_service_performance (time_id, wilayah_id, jenis_layanan_id, pegawai_id, jumlah_layanan, rata_rata_waktu_layanan)
SELECT 
    CONVERT(INT, FORMAT(SS.tanggal, 'yyyyMMdd')),
    W.wilayah_id,
    L.jenis_layanan_id,
    P.pegawai_id,
    SS.jumlah_layanan,
    SS.rata_rata_waktu_layanan
FROM staging_service_performance SS
JOIN dim_wilayah W ON SS.kode_wilayah = W.kode_wilayah
JOIN dim_jenis_layanan L ON SS.jenis_layanan = L.nama_layanan
JOIN dim_pegawai P ON SS.nama_pegawai = P.nama AND SS.jabatan = P.jabatan AND SS.unit_kerja = P.unit_kerja;



-- =======================
-- Query Analitik
-- =======================
# Analisis Pertumbuhan dan Persebaran Penduduk
-- a. Pertumbuhan jumlah penduduk bulanan dan tahunan per kecamatan
SELECT T.year, T.month, W.nama_wilayah, SUM(F.jumlah) AS total_penduduk
FROM fact_population F
JOIN dim_time T ON F.time_id = T.time_id
JOIN dim_wilayah W ON F.wilayah_id = W.wilayah_id
GROUP BY T.year, T.month, W.nama_wilayah;

-- b. Distribusi penduduk berdasarkan kelompok umur, jenis kelamin
SELECT A.rentang_usia, G.gender, SUM(F.jumlah) AS total
FROM fact_population F
JOIN dim_age_group A ON F.age_group_id = A.age_group_id
JOIN dim_gender G ON F.gender_id = G.gender_id
GROUP BY A.rentang_usia, G.gender;

-- c. Tren migrasi masuk dan keluar antar wilayah
SELECT WA.nama_wilayah AS Asal, WT.nama_wilayah AS Tujuan, SUM(F.jumlah) AS total
FROM fact_migration F
JOIN dim_wilayah WA ON F.wilayah_asal_id = WA.wilayah_id
JOIN dim_wilayah WT ON F.wilayah_tujuan_id = WT.wilayah_id
GROUP BY WA.nama_wilayah, WT.nama_wilayah;


#  Evaluasi Pelayanan Publik
-- a. Waktu rata-rata penyelesaian layanan (diperluas jadi total skor kepuasan)
SELECT T.month, L.nama_layanan, AVG(S.skor) AS rata_skor
FROM fact_satisfaction S
JOIN dim_jenis_layanan L ON S.jenis_layanan_id = L.jenis_layanan_id
JOIN dim_time T ON S.time_id = T.time_id
GROUP BY T.month, L.nama_layanan;

-- b. Jumlah pengajuan layanan per jenis dokumen
SELECT D.nama_dokumen, COUNT(*) AS jumlah
FROM fact_document_requests F
JOIN dim_jenis_dokumen D ON F.jenis_dokumen_id = D.jenis_dokumen_id
GROUP BY D.nama_dokumen;

-- c. Kepuasan masyarakat berdasarkan wilayah
SELECT W.nama_wilayah, AVG(S.skor) AS rata_skor
FROM fact_satisfaction S
JOIN dim_wilayah W ON S.wilayah_id = W.wilayah_id
GROUP BY W.nama_wilayah;

#  Monitoring Data Vital
-- a. Jumlah peristiwa penting per bulan dan lokasi
SELECT T.month, V.jenis_peristiwa, W.nama_wilayah, SUM(V.jumlah) AS total
FROM fact_vital_event V
JOIN dim_time T ON V.time_id = T.time_id
JOIN dim_wilayah W ON V.wilayah_id = W.wilayah_id
GROUP BY T.month, V.jenis_peristiwa, W.nama_wilayah;

# Pengelolaan SDM dan Anggaran
-- a. Jumlah pegawai aktif berdasarkan jabatan dan lokasi
SELECT P.nama_jabatan, W.nama_wilayah, COUNT(*) AS jumlah
FROM fact_service_performance F
JOIN dim_pegawai P ON F.pegawai_id = P.pegawai_id
JOIN dim_wilayah W ON F.wilayah_id = W.wilayah_id
GROUP BY P.nama_jabatan, W.nama_wilayah;

-- b. Evaluasi beban kerja pegawai per layanan
SELECT L.nama_layanan, P.nama_jabatan, AVG(F.beban_kerja) AS rata_beban
FROM fact_service_performance F
JOIN dim_jenis_layanan L ON F.jenis_layanan_id = L.jenis_layanan_id
JOIN dim_pegawai P ON F.pegawai_id = P.pegawai_id
GROUP BY L.nama_layanan, P.nama_jabatan;

-- c. Efisiensi anggaran
SELECT unit_kerja, program, SUM(anggaran) AS total_anggaran,
       SUM(realisasi) AS total_realisasi,
       SUM(realisasi) / NULLIF(SUM(anggaran),0) AS rasio_efisiensi
FROM fact_budget
GROUP BY unit_kerja, program;