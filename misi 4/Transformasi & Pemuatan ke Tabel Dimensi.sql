USE DW_Disdukcapil;
GO

-- Mengisi dim_time
INSERT INTO dim_time (time_id, tanggal, hari, bulan, tahun, kuartal, semester)
SELECT DISTINCT
    CONVERT(INT, FORMAT(tanggal_bersih, 'yyyyMMdd')),
    tanggal_bersih,
    DAY(tanggal_bersih),
    MONTH(tanggal_bersih),
    YEAR(tanggal_bersih),
    DATEPART(QUARTER, tanggal_bersih),
    CASE WHEN MONTH(tanggal_bersih) <= 6 THEN 1 ELSE 2 END
FROM (
    -- Gunakan TRY_CONVERT untuk semua kolom tanggal
    SELECT TRY_CONVERT(DATE, Tanggal_Permohonan, 101) AS tanggal_bersih FROM staging_pelayanan_online WHERE Tanggal_Permohonan IS NOT NULL
    UNION
    SELECT TRY_CONVERT(DATE, Tanggal_Selesai, 101) AS tanggal_bersih FROM staging_pelayanan_online WHERE Tanggal_Selesai IS NOT NULL
    UNION
    SELECT TRY_CONVERT(DATE, Tanggal_Kepindahan, 101) AS tanggal_bersih FROM staging_kepindahan WHERE Tanggal_Kepindahan IS NOT NULL
) AS all_dates
WHERE tanggal_bersih IS NOT NULL -- Pastikan hanya tanggal yang berhasil dikonversi (bukan NULL dari TRY_CONVERT)
AND CONVERT(INT, FORMAT(tanggal_bersih, 'yyyyMMdd')) NOT IN (SELECT time_id FROM dim_time);

-- Mengisi dim_gender
INSERT INTO dim_gender (gender)
SELECT DISTINCT Jenis_Kelamin
FROM staging_siak
WHERE Jenis_Kelamin NOT IN (SELECT gender FROM dim_gender);

-- Mengisi dim_age_group
INSERT INTO dim_age_group (rentang_usia)
SELECT DISTINCT
    CASE
        WHEN Usia BETWEEN 0 AND 10 THEN '0-10'
        WHEN Usia BETWEEN 11 AND 20 THEN '11-20'
        WHEN Usia BETWEEN 21 AND 30 THEN '21-30'
        WHEN Usia BETWEEN 31 AND 40 THEN '31-40'
        WHEN Usia BETWEEN 41 AND 50 THEN '41-50'
        WHEN Usia BETWEEN 51 AND 60 THEN '51-60'
        WHEN Usia BETWEEN 61 AND 70 THEN '61-70'
        WHEN Usia BETWEEN 71 AND 80 THEN '71-80'
        WHEN Usia BETWEEN 81 AND 90 THEN '81-90'
        WHEN Usia > 90 THEN '>90'
        ELSE 'Tidak Diketahui'
    END AS age_group_category
FROM staging_siak
WHERE Usia IS NOT NULL
AND CASE
        WHEN Usia BETWEEN 0 AND 10 THEN '0-10'
        WHEN Usia BETWEEN 11 AND 20 THEN '11-20'
        WHEN Usia BETWEEN 21 AND 30 THEN '21-30'
        WHEN Usia BETWEEN 31 AND 40 THEN '31-40'
        WHEN Usia BETWEEN 41 AND 50 THEN '41-50'
        WHEN Usia BETWEEN 51 AND 60 THEN '51-60'
        WHEN Usia BETWEEN 61 AND 70 THEN '61-70'
        WHEN Usia BETWEEN 71 AND 80 THEN '71-80'
        WHEN Usia BETWEEN 81 AND 90 THEN '81-90'
        WHEN Usia > 90 THEN '>90'
        ELSE 'Tidak Diketahui'
    END NOT IN (SELECT rentang_usia FROM dim_age_group);

    -- Mengisi dim_jenis_dokumen
INSERT INTO dim_jenis_dokumen (nama_dokumen)
SELECT DISTINCT Jenis_Dokumen
FROM staging_pelayanan_online
WHERE Jenis_Dokumen NOT IN (SELECT nama_dokumen FROM dim_jenis_dokumen);

-- Mengisi dim_status
INSERT INTO dim_status (status)
SELECT DISTINCT Status
FROM staging_pelayanan_online
WHERE Status NOT IN (SELECT status FROM dim_status);

-- Mengisi dim_alasan_pindah
INSERT INTO dim_alasan_pindah (alasan)
SELECT DISTINCT Alasan_Kepindahan
FROM staging_kepindahan
WHERE Alasan_Kepindahan NOT IN (SELECT alasan FROM dim_alasan_pindah);

INSERT INTO dim_wilayah (provinsi, kabupaten_kota, kecamatan, kelurahan)
SELECT DISTINCT
    provinsi_bersih,
    kabupaten_kota_bersih,
    NULL AS kecamatan, -- Tidak dapat diekstrak dari data yang ada
    NULL AS kelurahan -- Tidak dapat diekstrak dari data yang ada
FROM (
    SELECT
        CASE
            WHEN Alamat_Bersih LIKE '%Kota %' THEN SUBSTRING(Alamat_Bersih, CHARINDEX('Kota ', Alamat_Bersih) + 5, CHARINDEX(',', Alamat_Bersih, CHARINDEX('Kota ', Alamat_Bersih) + 5) - (CHARINDEX('Kota ', Alamat_Bersih) + 5))
            WHEN Alamat_Bersih LIKE '%Kabupaten %' THEN SUBSTRING(Alamat_Bersih, CHARINDEX('Kabupaten ', Alamat_Bersih) + 10, CHARINDEX(',', Alamat_Bersih, CHARINDEX('Kabupaten ', Alamat_Bersih) + 10) - (CHARINDEX('Kabupaten ', Alamat_Bersih) + 10))
            ELSE NULL
        END AS kabupaten_kota_bersih,
        CASE
            WHEN Alamat_Bersih LIKE '%Provinsi %' THEN SUBSTRING(Alamat_Bersih, CHARINDEX('Provinsi ', Alamat_Bersih) + 9, LEN(Alamat_Bersih) - (CHARINDEX('Provinsi ', Alamat_Bersih) + 8)) -- Ambil sampai akhir string jika Provinsi di akhir
            ELSE SUBSTRING(Alamat_Bersih, CHARINDEX(', ', Alamat_Bersih, CHARINDEX('Kota ', Alamat_Bersih) + 5) + 2, LEN(Alamat_Bersih) - (CHARINDEX(', ', Alamat_Bersih, CHARINDEX('Kota ', Alamat_Bersih) + 5) + 1))
        END AS provinsi_bersih
    FROM staging_siak
    UNION
    SELECT
        CASE
            WHEN Alamat_Asal LIKE '%Kota %' THEN SUBSTRING(Alamat_Asal, CHARINDEX('Kota ', Alamat_Asal) + 5, CHARINDEX(',', Alamat_Asal, CHARINDEX('Kota ', Alamat_Asal) + 5) - (CHARINDEX('Kota ', Alamat_Asal) + 5))
            WHEN Alamat_Asal LIKE '%Kabupaten %' THEN SUBSTRING(Alamat_Asal, CHARINDEX('Kabupaten ', Alamat_Asal) + 10, CHARINDEX(',', Alamat_Asal, CHARINDEX('Kabupaten ', Alamat_Asal) + 10) - (CHARINDEX('Kabupaten ', Alamat_Asal) + 10))
            ELSE NULL
        END AS kabupaten_kota_bersih,
        CASE
            WHEN Alamat_Asal LIKE '%Provinsi %' THEN SUBSTRING(Alamat_Asal, CHARINDEX('Provinsi ', Alamat_Asal) + 9, LEN(Alamat_Asal) - (CHARINDEX('Provinsi ', Alamat_Asal) + 8))
            ELSE SUBSTRING(Alamat_Asal, CHARINDEX(', ', Alamat_Asal, CHARINDEX('Kota ', Alamat_Asal) + 5) + 2, LEN(Alamat_Asal) - (CHARINDEX(', ', Alamat_Asal, CHARINDEX('Kota ', Alamat_Asal) + 5) + 1))
        END AS provinsi_bersih
    FROM staging_kepindahan
    UNION
    SELECT
        CASE
            WHEN Alamat_Tujuan LIKE '%Kota %' THEN SUBSTRING(Alamat_Tujuan, CHARINDEX('Kota ', Alamat_Tujuan) + 5, CHARINDEX(',', Alamat_Tujuan, CHARINDEX('Kota ', Alamat_Tujuan) + 5) - (CHARINDEX('Kota ', Alamat_Tujuan) + 5))
            WHEN Alamat_Tujuan LIKE '%Kabupaten %' THEN SUBSTRING(Alamat_Tujuan, CHARINDEX('Kabupaten ', Alamat_Tujuan) + 10, CHARINDEX(',', Alamat_Tujuan, CHARINDEX('Kabupaten ', Alamat_Tujuan) + 10) - (CHARINDEX('Kabupaten ', Alamat_Tujuan) + 10))
            ELSE NULL
        END AS kabupaten_kota_bersih,
        CASE
            WHEN Alamat_Tujuan LIKE '%Provinsi %' THEN SUBSTRING(Alamat_Tujuan, CHARINDEX('Provinsi ', Alamat_Tujuan) + 9, LEN(Alamat_Tujuan) - (CHARINDEX('Provinsi ', Alamat_Tujuan) + 8))
            ELSE SUBSTRING(Alamat_Tujuan, CHARINDEX(', ', Alamat_Tujuan, CHARINDEX('Kota ', Alamat_Tujuan) + 5) + 2, LEN(Alamat_Tujuan) - (CHARINDEX(', ', Alamat_Tujuan, CHARINDEX('Kota ', Alamat_Tujuan) + 5) + 1))
        END AS provinsi_bersih
    FROM staging_kepindahan
) AS all_addresses
WHERE provinsi_bersih IS NOT NULL AND kabupaten_kota_bersih IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM dim_wilayah dw WHERE dw.provinsi = all_addresses.provinsi_bersih AND dw.kabupaten_kota = all_addresses.kabupaten_kota_bersih);

-- Perbarui tabel dim_wilayah untuk memisahkan kode_wilayah dari provinsi

USE DW_Disdukcapil;
GO

-- Perbarui tabel dim_wilayah untuk memisahkan kode_wilayah dari provinsi
UPDATE dw
SET
    dw.kode_wilayah = LTRIM(RTRIM(SUBSTRING(dw.provinsi, CHARINDEX(',', dw.provinsi) + 1, LEN(dw.provinsi)))),
    dw.provinsi = LTRIM(RTRIM(LEFT(dw.provinsi, CHARINDEX(',', dw.provinsi) - 1)))
FROM
    dim_wilayah dw
WHERE
    dw.provinsi LIKE '%, %' -- Hanya proses baris di mana ada koma dan spasi (indikasi kode pos)
    AND ISNUMERIC(LTRIM(RTRIM(SUBSTRING(dw.provinsi, CHARINDEX(',', dw.provinsi) + 1, LEN(dw.provinsi))))) = 1; -- Pastikan bagian setelah koma adalah angka (kode pos)

– Mengisi dim_penduduk
INSERT INTO dim_penduduk (NIK, Nama, gender_id, age_group_id)
SELECT DISTINCT
    ss.NIK,
    ss.Nama,
    dg.gender_id,
    dag.age_group_id
FROM staging_siak ss
JOIN dim_gender dg ON ss.Jenis_Kelamin = dg.gender
JOIN dim_age_group dag ON
    ss.Usia BETWEEN 0 AND 10 AND dag.rentang_usia = '0-10' OR
    ss.Usia BETWEEN 11 AND 20 AND dag.rentang_usia = '11-20' OR
    ss.Usia BETWEEN 21 AND 30 AND dag.rentang_usia = '21-30' OR
    ss.Usia BETWEEN 31 AND 40 AND dag.rentang_usia = '31-40' OR
    ss.Usia BETWEEN 41 AND 50 AND dag.rentang_usia = '41-50' OR
    ss.Usia BETWEEN 51 AND 60 AND dag.rentang_usia = '51-60' OR
    ss.Usia BETWEEN 61 AND 70 AND dag.rentang_usia = '61-70' OR
    ss.Usia BETWEEN 71 AND 80 AND dag.rentang_usia = '71-80' OR
    ss.Usia BETWEEN 81 AND 90 AND dag.rentang_usia = '81-90' OR
    ss.Usia > 90 AND dag.rentang_usia = '>90' OR
    ss.Usia IS NULL AND dag.rentang_usia = 'Tidak Diketahui'
WHERE ss.NIK NOT IN (SELECT NIK FROM dim_penduduk);

– Mengisi kolom wilayah_id terpisah
UPDATE dp
SET dp.wilayah_id = dw.wilayah_id
FROM dim_penduduk dp
JOIN staging_siak ss ON dp.NIK = ss.NIK
JOIN dim_wilayah dw 
    ON RIGHT(LTRIM(RTRIM(ss.alamat_bersih)), 5) = CAST(dw.kode_wilayah AS VARCHAR)
WHERE dp.wilayah_id IS NULL;
