USE DW_Disdukcapil;
GO

DECLARE @SnapshotDate DATE = GETDATE();
-- Pastikan tanggal snapshot ini ada di dim_time
INSERT INTO dim_time (time_id, tanggal, hari, bulan, tahun, kuartal, semester)
SELECT DISTINCT
    CONVERT(INT, FORMAT(@SnapshotDate, 'yyyyMMdd')),
    @SnapshotDate,
    DAY(@SnapshotDate),
    MONTH(@SnapshotDate),
    YEAR(@SnapshotDate),
    DATEPART(QUARTER, @SnapshotDate),
    CASE WHEN MONTH(@SnapshotDate) <= 6 THEN 1 ELSE 2 END
WHERE NOT EXISTS (SELECT 1 FROM dim_time WHERE tanggal = @SnapshotDate);

-- Mengisi fact_population
INSERT INTO fact_population (time_id, wilayah_id, gender_id, age_group_id, jumlah_penduduk)
SELECT
    dt.time_id,
    dp.wilayah_id,
    dp.gender_id,
    dp.age_group_id,
    COUNT(dp.penduduk_id) AS jumlah_penduduk
FROM dim_penduduk dp
JOIN dim_time dt ON dt.tanggal = @SnapshotDate 
GROUP BY dt.time_id, dp.wilayah_id, dp.gender_id, dp.age_group_id;


– Mengisi fact_document_requests
USE DW_Disdukcapil;
GO

-- Mengisi fact_document_requests UNTUK PERTAMA KALI
INSERT INTO fact_document_requests (time_id, penduduk_id, jenis_dokumen_id, status_id, lama_proses_hari, original_source_nik)
SELECT
    dt.time_id,
    dp.penduduk_id, 
    djd.jenis_dokumen_id,
    ds.status_id,
    DATEDIFF(DAY, TRY_CONVERT(DATE, spo.Tanggal_Permohonan, 101), TRY_CONVERT(DATE, spo.Tanggal_Selesai, 101)) AS lama_proses_hari,
    TRIM(spo.NIK) AS original_source_nik 
FROM staging_pelayanan_online spo
JOIN dim_time dt ON dt.tanggal = TRY_CONVERT(DATE, spo.Tanggal_Permohonan, 101)
LEFT JOIN dim_penduduk dp ON TRIM(spo.NIK) = TRIM(dp.NIK) 
JOIN dim_jenis_dokumen djd ON TRIM(spo.Jenis_Dokumen) = TRIM(djd.nama_dokumen)
JOIN dim_status ds ON TRIM(spo.Status) = TRIM(ds.status)
WHERE
    TRY_CONVERT(DATE, spo.Tanggal_Permohonan, 101) IS NOT NULL
    AND TRY_CONVERT(DATE, spo.Tanggal_Selesai, 101) IS NOT NULL
    AND DATEDIFF(DAY, TRY_CONVERT(DATE, spo.Tanggal_Permohonan, 101), TRY_CONVERT(DATE, spo.Tanggal_Selesai, 101)) IS NOT NULL
    AND NOT EXISTS ( 
        SELECT 1 FROM fact_document_requests fdr_check
        WHERE fdr_check.original_source_nik = TRIM(spo.NIK)
          AND fdr_check.time_id = dt.time_id
          AND fdr_check.jenis_dokumen_id = djd.jenis_dokumen_id
    );

USE DW_Disdukcapil;
GO

-- Mengisi fact_migration
INSERT INTO fact_migration (time_id, penduduk_id, wilayah_id_asal, wilayah_id_tujuan, alasan_id, jumlah_penduduk_migrasi)
SELECT
    dt.time_id,
    dp.penduduk_id,
    dwa.wilayah_id AS wilayah_id_asal,
    dwt.wilayah_id AS wilayah_id_tujuan,
    dap.alasan_id,
    1 -- Setiap baris di staging_kepindahan merepresentasikan 1 orang yang pindah
FROM staging_kepindahan sk
JOIN dim_time dt ON dt.tanggal = TRY_CONVERT(DATE, sk.Tanggal_Kepindahan, 101)
LEFT JOIN dim_penduduk dp ON TRIM(sk.NIK) = TRIM(dp.NIK) -- LEFT JOIN karena mungkin ada NIK di kepindahan yang belum ada di dim_penduduk
LEFT JOIN dim_alasan_pindah dap ON TRIM(sk.Alasan_Kepindahan) = TRIM(dap.alasan)
LEFT JOIN dim_wilayah dwa ON
    TRIM(SUBSTRING(sk.Alamat_Asal,
                   CHARINDEX('Kota ', sk.Alamat_Asal) + 5,
                   CHARINDEX(',', sk.Alamat_Asal, CHARINDEX('Kota ', sk.Alamat_Asal) + 5) - (CHARINDEX('Kota ', sk.Alamat_Asal) + 5))) = TRIM(dwa.kabupaten_kota)
    AND TRIM(SUBSTRING(sk.Alamat_Asal,
                        CHARINDEX(', ', sk.Alamat_Asal, CHARINDEX('Kota ', sk.Alamat_Asal) + 5) + 2,
                        LEN(sk.Alamat_Asal) - (CHARINDEX(', ', sk.Alamat_Asal, CHARINDEX('Kota ', sk.Alamat_Asal) + 5) + 1))) = TRIM(dwa.provinsi)
LEFT JOIN dim_wilayah dwt ON
    TRIM(SUBSTRING(sk.Alamat_Tujuan,
                   CHARINDEX('Kota ', sk.Alamat_Tujuan) + 5,
                   CHARINDEX(',', sk.Alamat_Tujuan, CHARINDEX('Kota ', sk.Alamat_Tujuan) + 5) - (CHARINDEX('Kota ', sk.Alamat_Tujuan) + 5))) = TRIM(dwt.kabupaten_kota)
    AND TRIM(SUBSTRING(sk.Alamat_Tujuan,
                        CHARINDEX(', ', sk.Alamat_Tujuan, CHARINDEX('Kota ', sk.Alamat_Tujuan) + 5) + 2,
                        LEN(sk.Alamat_Tujuan) - (CHARINDEX(', ', sk.Alamat_Tujuan, CHARINDEX('Kota ', sk.Alamat_Tujuan) + 5) + 1))) = TRIM(dwt.provinsi)
WHERE TRY_CONVERT(DATE, sk.Tanggal_Kepindahan, 101) IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM fact_migration fm_check
    WHERE fm_check.time_id = dt.time_id
      AND fm_check.penduduk_id = dp.penduduk_id
      AND fm_check.wilayah_id_asal = dwa.wilayah_id
      AND fm_check.wilayah_id_tujuan = dwt.wilayah_id
      AND fm_check.alasan_id = dap.alasan_id
);

USE DW_Disdukcapil;
GO

-- Mengisi wilayah_id_asal di fact_migration
UPDATE fm
SET fm.wilayah_id_asal = dwa.wilayah_id
FROM fact_migration fm
JOIN dim_penduduk dp ON fm.penduduk_id = dp.penduduk_id -- Bergabung dengan dim_penduduk
JOIN staging_kepindahan sk ON dp.NIK = sk.NIK -- Bergabung dengan staging_kepindahan berdasarkan NIK
LEFT JOIN dim_wilayah dwa ON
    -- Pastikan Alamat_Asal memiliki format yang benar dan kode pos ada
    LEN(TRIM(sk.Alamat_Asal)) >= 5
    AND ISNUMERIC(RIGHT(TRIM(sk.Alamat_Asal), 5)) = 1
    AND RIGHT(LTRIM(RTRIM(sk.Alamat_Asal)), 5) = CAST(dwa.kode_wilayah AS VARCHAR)
WHERE fm.wilayah_id_asal IS NULL;

-- Mengisi wilayah_id_tujuan di fact_migration
UPDATE fm
SET fm.wilayah_id_tujuan = dwt.wilayah_id
FROM fact_migration fm
JOIN dim_penduduk dp ON fm.penduduk_id = dp.penduduk_id -- Bergabung dengan dim_penduduk
JOIN staging_kepindahan sk ON dp.NIK = sk.NIK -- Bergabung dengan staging_kepindahan berdasarkan NIK
LEFT JOIN dim_wilayah dwt ON
    -- Pastikan Alamat_Tujuan memiliki format yang benar dan kode pos ada
    LEN(TRIM(sk.Alamat_Tujuan)) >= 5
    AND ISNUMERIC(RIGHT(TRIM(sk.Alamat_Tujuan), 5)) = 1
    AND RIGHT(LTRIM(RTRIM(sk.Alamat_Tujuan)), 5) = CAST(dwt.kode_wilayah AS VARCHAR)
WHERE fm.wilayah_id_tujuan IS NULL;
