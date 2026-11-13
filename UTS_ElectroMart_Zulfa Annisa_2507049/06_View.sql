-- ============================================================================
-- TUGAS 6: IMPLEMENTASI SQL VIEW (PERTEMUAN 6 - MySQL / MariaDB)
-- ============================================================================

USE db_electromart;

-- 1. View dari Satu Tabel (Proyeksi kolom tanpa menampilkan stok internal)
CREATE VIEW View_Produk AS
SELECT id_produk, nama_produk, kategori, harga
FROM produk;

-- 2. View dengan JOIN Beberapa Tabel (Informasi transaksi beserta nama pelanggan & pegawai)
CREATE VIEW View_Transaksi AS
SELECT p.id_penjualan, p.tanggal, pl.nama_pelanggan,
       pg.nama_pegawai, p.total_harga, p.diskon, p.total_bayar
FROM penjualan p
JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
JOIN pegawai pg ON p.id_pegawai = pg.id_pegawai;

-- 3. View dengan Fungsi Agregasi COUNT() dan SUM() serta GROUP BY
CREATE VIEW View_Laporan_Penjualan (kategori, jumlah_transaksi, total_unit, total_penjualan) AS
SELECT pr.kategori, COUNT(DISTINCT dp.id_penjualan), SUM(dp.jumlah), SUM(dp.subtotal)
FROM detail_penjualan dp
JOIN produk pr ON dp.id_produk = pr.id_produk
GROUP BY pr.kategori;

-- 4. View dengan WITH CHECK OPTION (Produk dengan stok di bawah 5 unit)
CREATE VIEW View_Stok_Rendah AS
SELECT id_produk, nama_produk, kategori, harga, stok
FROM produk
WHERE stok < 5
WITH CHECK OPTION;

-- ----------------------------------------------------------------------------
-- PENGUJIAN SQL VIEW
-- ----------------------------------------------------------------------------

-- 1. Menguji setiap View menggunakan SELECT
SELECT * FROM View_Produk;
SELECT * FROM View_Transaksi;
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;

-- 2. Pengujian WITH CHECK OPTION pada View_Stok_Rendah
-- Pembaruan VALID (stok = 4 masih memenuhi syarat stok < 5) -> BERHASIL
UPDATE View_Stok_Rendah
SET stok = 4
WHERE id_produk = 'PRD003';

-- Pembaruan TIDAK VALID (stok = 10 melanggar syarat stok < 5) -> DITOLAK (CHECK OPTION failed)
UPDATE View_Stok_Rendah
SET stok = 10
WHERE id_produk = 'PRD003';

-- Kembalikan stok PRD003 ke semula (3)
UPDATE View_Stok_Rendah
SET stok = 3
WHERE id_produk = 'PRD003';

-- 3. Menghapus Salah Satu View Menggunakan DROP VIEW
DROP VIEW View_Produk;

-- ============================================================================
-- INTEGRASI SELURUH MATERI DALAM SATU PROSES PENJUALAN (PERTEMUAN 1-6)
-- ============================================================================

USE db_electromart;

-- Stored Procedure terpadu untuk mencatat penjualan
DELIMITER $$
CREATE PROCEDURE SP_Catat_Penjualan(
    p_id_penjualan VARCHAR(10),
    p_id_pelanggan VARCHAR(10),
    p_id_pegawai VARCHAR(10),
    p_id_produk VARCHAR(10),
    p_jumlah INT,
    p_harga_satuan DECIMAL(12,2)
)
BEGIN
    INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
    VALUES (p_id_penjualan, NOW(), p_id_pelanggan, p_id_pegawai);

    -- Saat INSERT ke detail_penjualan dijalankan:
    -- Trigger validasi_penjualan memeriksa stok & menghitung subtotal via hitung_total()
    -- Trigger update_stok_penjualan mengurangi stok, mencatat log_stok, & menghitung diskon via hitung_diskon()
    INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
    VALUES (p_id_penjualan, p_id_produk, p_jumlah, p_harga_satuan, 0);
END$$
DELIMITER ;

-- Alur Eksekusi Integrasi Proses Penjualan:
-- 1. Pencarian produk berdasarkan kategori (menggunakan indeks kategori)
SELECT id_produk, nama_produk, harga, stok
FROM produk
WHERE kategori = 'Audio';

-- 2. Menjalankan transaksi penjualan melalui Stored Procedure
START TRANSACTION;
CALL SP_Catat_Penjualan('TRX011', 'PLG001', 'PGW002', 'PRD007', 1, 4499000.00);
COMMIT;

-- 3. Manajemen memantau hasil penjualan dan persediaan melalui View
SELECT * FROM View_Transaksi WHERE id_penjualan = 'TRX011';
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;