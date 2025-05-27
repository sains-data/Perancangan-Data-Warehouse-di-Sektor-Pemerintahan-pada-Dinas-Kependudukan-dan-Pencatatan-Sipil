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
