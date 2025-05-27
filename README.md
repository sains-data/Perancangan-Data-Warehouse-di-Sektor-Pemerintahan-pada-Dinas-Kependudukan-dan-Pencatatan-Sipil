# 🏛️ Perancangan Data Warehouse Disdukcapil 🇮🇩
**Kabinet Data Bersatu** - Sains Data ITERA | 2025  
📁 Proyek Akademik | 🗃️ SQL Server • SSMS • Power BI • SSRS

## 📚 Ringkasan Proyek

Repositori ini berisi dokumentasi lengkap proyek perancangan **Data Warehouse (DW)** untuk instansi **Dinas Kependudukan dan Pencatatan Sipil (Disdukcapil)** yang bertujuan untuk meningkatkan efisiensi, transparansi, dan akurasi layanan publik berbasis data.

---

## 🎯 Tujuan Sistem

- 📌 Integrasi data antar wilayah
- 📊 Analisis multidimensi penduduk dan layanan
- ⏱️ Pengambilan keputusan real-time
- 📈 Visualisasi interaktif via Power BI

---

## 🧱 Arsitektur Sistem - Three-Tier Architecture

```mermaid
graph TD
    A[Sumber Data] --> B[Staging Area]
    B --> C[Data Warehouse (Star Schema)]
    C --> D[Presentation Layer (Power BI, SSRS)]
