-- Staging table for Dataset Aplikasi SIAK.csv
CREATE TABLE staging_siak (
    NIK NVARCHAR(20),
    Nama NVARCHAR(255),
    Jenis_Kelamin NVARCHAR(10),
    Usia INT,
    Alamat_Bersih NVARCHAR(500)
);

-- Staging table for Dataset Pelayanan Online.csv
CREATE TABLE staging_pelayanan_online (
    Nama NVARCHAR(255),
    Email NVARCHAR(255),
    NIK NVARCHAR(20),
    Jenis_Dokumen NVARCHAR(100),
    Tanggal_Permohonan NVARCHAR(50), 
    Status NVARCHAR(50),
    Tanggal_Selesai NVARCHAR(50) 
);

-- Staging table for Dataset Kepindahan.csv
CREATE TABLE staging_kepindahan (
    NIK NVARCHAR(20),
    Nama NVARCHAR(255),
    Alamat_Asal NVARCHAR(500),
    Alamat_Tujuan NVARCHAR(500),
    Alasan_Kepindahan NVARCHAR(100),
    Tanggal_Kepindahan NVARCHAR(50) 
);
