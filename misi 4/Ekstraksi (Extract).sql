-- Contoh BULK INSERT untuk Dataset Aplikasi SIAK.csv
BULK INSERT staging_siak
FROM 'C:\path\to\Dataset Aplikasi SIAK.csv' 
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);

-- Contoh BULK INSERT untuk Dataset Pelayanan Online.csv
BULK INSERT staging_pelayanan_online
FROM 'C:\path\to\Dataset Pelayanan Online.csv' 
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Contoh BULK INSERT untuk Dataset Kepindahan.csv
BULK INSERT staging_kepindahan
FROM 'C:\Users\ASUS\Downloads\Dataset Kepindahan.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a', 
    FIRSTROW = 2,          
    CODEPAGE = '65001',   
    TABLOCK                 
);
