-- DIMENSI
-- dim_time 
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    tanggal DATE,
    hari INT,
    bulan INT,
    tahun INT,
    kuartal INT,
    semester INT
);

-- dim_wilayah 
CREATE TABLE dim_wilayah (
    wilayah_id INT IDENTITY(1,1) PRIMARY KEY,
    kode_wilayah NVARCHAR(20), -- Akan diisi jika ada data kode wilayah
    provinsi NVARCHAR(50),
    kabupaten_kota NVARCHAR(50),
    kecamatan NVARCHAR(50),
    kelurahan NVARCHAR(50)
);

-- dim_gender 
CREATE TABLE dim_gender (
    gender_id INT IDENTITY(1,1) PRIMARY KEY,
    gender NVARCHAR(10)
);

-- dim_age_group 
CREATE TABLE dim_age_group (
    age_group_id INT IDENTITY(1,1) PRIMARY KEY,
    rentang_usia NVARCHAR(20)
);

-- dim_jenis_dokumen (Baru, dari Dataset Pelayanan Online)
CREATE TABLE dim_jenis_dokumen (
    jenis_dokumen_id INT IDENTITY(1,1) PRIMARY KEY,
    nama_dokumen NVARCHAR(100)
);

-- dim_status (Baru, dari Dataset Pelayanan Online)
CREATE TABLE dim_status (
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    status NVARCHAR(50)
);

-- dim_alasan_pindah (Baru, dari Dataset Kepindahan)
CREATE TABLE dim_alasan_pindah (
    alasan_id INT IDENTITY(1,1) PRIMARY KEY,
    alasan NVARCHAR(100)
);

-- dim_penduduk (Baru, untuk menghubungkan NIK ke dimensi lain seperti wilayah)
CREATE TABLE dim_penduduk (
    penduduk_id INT IDENTITY(1,1) PRIMARY KEY,
    NIK NVARCHAR(20) UNIQUE, -- NIK sebagai identifikasi unik penduduk
    Nama NVARCHAR(255),
    gender_id INT,
    age_group_id INT,
    wilayah_id INT,
    FOREIGN KEY (gender_id) REFERENCES dim_gender(gender_id),
    FOREIGN KEY (age_group_id) REFERENCES dim_age_group(age_group_id),
    FOREIGN KEY (wilayah_id) REFERENCES dim_wilayah(wilayah_id)
);

-- TABEL FAKTA
-- fact_population 
CREATE TABLE fact_population (
    population_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT,
    wilayah_id INT,
    gender_id INT,
    age_group_id INT,
    jumlah_penduduk INT,
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (wilayah_id) REFERENCES dim_wilayah(wilayah_id),
    FOREIGN KEY (gender_id) REFERENCES dim_gender(gender_id),
    FOREIGN KEY (age_group_id) REFERENCES dim_age_group(age_group_id)
);

-- fact_document_requests (Baru, dari Dataset Pelayanan Online)
CREATE TABLE fact_document_requests (
    permohonan_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT, -- Tanggal Permohonan
    penduduk_id INT, -- Untuk menghubungkan ke NIK dan wilayah
    jenis_dokumen_id INT,
    status_id INT,
    lama_proses_hari INT, -- Derived: Tanggal_Selesai - Tanggal_Permohonan
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (penduduk_id) REFERENCES dim_penduduk(penduduk_id),
    FOREIGN KEY (jenis_dokumen_id) REFERENCES dim_jenis_dokumen(jenis_dokumen_id),
    FOREIGN KEY (status_id) REFERENCES dim_status(status_id)
);

-- fact_migration (Baru, dari Dataset Kepindahan)
CREATE TABLE fact_migration (
    migration_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT, -- Tanggal Kepindahan
    penduduk_id INT, -- Untuk menghubungkan ke NIK
    wilayah_id_asal INT,
    wilayah_id_tujuan INT,
    alasan_id INT,
    jumlah_penduduk_migrasi INT DEFAULT 1, -- Setiap baris adalah 1 orang yang pindah
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (penduduk_id) REFERENCES dim_penduduk(penduduk_id),
    FOREIGN KEY (wilayah_id_asal) REFERENCES dim_wilayah(wilayah_id),
    FOREIGN KEY (wilayah_id_tujuan) REFERENCES dim_wilayah(wilayah_id),
    FOREIGN KEY (alasan_id) REFERENCES dim_alasan_pindah(alasan_id)
);

– Fact service_performance
USE DW_Disdukcapil;
GO

CREATE TABLE fact_service_performance (
    service_performance_id INT IDENTITY(1,1) PRIMARY KEY,
    time_id INT NOT NULL,
    wilayah_id INT NOT NULL,
    jenis_dokumen_id INT NOT NULL, -- Diubah dari jenis_layanan_id
    
    jumlah_layanan_selesai INT,
    rata_waktu_layanan_hari DECIMAL(10, 2),
    
    -- Foreign Keys
    CONSTRAINT FK_FactService_Time FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    CONSTRAINT FK_FactService_Wilayah FOREIGN KEY (wilayah_id) REFERENCES dim_wilayah(wilayah_id),
    CONSTRAINT FK_FactService_JenisDokumen FOREIGN KEY (jenis_dokumen_id) REFERENCES dim_jenis_dokumen(jenis_dokumen_id)
);
GO
