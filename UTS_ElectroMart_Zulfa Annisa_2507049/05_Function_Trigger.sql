-- ============================================================================
-- TUGAS 5: IMPLEMENTASI FUNCTION DAN TRIGGER (PERTEMUAN 5 - MySQL / MariaDB)
-- ============================================================================

USE db_electromart;

-- ----------------------------------------------------------------------------
-- A. MEMBUAT STORED FUNCTION
-- ----------------------------------------------------------------------------

-- 1. Function hitung_total(): Menghitung harga satuan dikalikan jumlah pembelian
DELIMITER //
CREATE FUNCTION hitung_total(
    p_harga DECIMAL(12,2),
    p_jumlah INT
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_harga * p_jumlah;
END //
DELIMITER ;

-- 2. Function hitung_diskon(): Diskon 10% apabila total transaksi >= Rp1.000.000
DELIMITER //
CREATE FUNCTION hitung_diskon(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total >= 1000000 THEN
        RETURN p_total * 0.10;
    ELSE
        RETURN 0;
    END IF;
END //
DELIMITER ;

-- Pengujian Function
SELECT hitung_total(250000, 2) AS total_harga;

SELECT
    1500000 AS total_transaksi,
    hitung_diskon(1500000) AS diskon,
    1500000 - hitung_diskon(1500000) AS total_bayar;

-- ----------------------------------------------------------------------------
-- B. MEMBUAT TRIGGER
-- ----------------------------------------------------------------------------

-- 1. Trigger validasi_penjualan (BEFORE INSERT pada detail_penjualan)
DELIMITER //
CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_ada INT DEFAULT 0;

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Jumlah pembelian harus lebih dari nol';
    END IF;

    IF NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harga satuan harus lebih dari nol';
    END IF;

    SELECT COUNT(*)
    INTO v_ada
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_ada = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;

    SELECT stok
    INTO v_stok
    FROM produk
    WHERE id_produk = NEW.id_produk
    FOR UPDATE;

    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
    END IF;

    SET NEW.subtotal = hitung_total(NEW.harga_satuan, NEW.jumlah);
END //
DELIMITER ;

select * from detail_penjualan;

-- 2. Trigger update_stok_penjualan (AFTER INSERT pada detail_penjualan)
DELIMITER //
CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_total_harga DECIMAL(14,2);
    DECLARE v_diskon DECIMAL(14,2);

    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (
        id_produk,
        jumlah_perubahan,
        tipe_transaksi,
        keterangan
    )
    VALUES (
        NEW.id_produk,
        -NEW.jumlah,
        'KELUAR',
        CONCAT('Pengurangan stok dari ', NEW.id_penjualan)
    );

    SELECT SUM(subtotal)
    INTO v_total_harga
    FROM detail_penjualan
    WHERE id_penjualan = NEW.id_penjualan;

    SET v_diskon = hitung_diskon(v_total_harga);

    UPDATE penjualan
    SET total_harga = v_total_harga,
        diskon = v_diskon,
        total_bayar = v_total_harga - v_diskon
    WHERE id_penjualan = NEW.id_penjualan;
END //
DELIMITER ;

-- Memeriksa Function dan Trigger yang telah dibuat
SHOW FUNCTION STATUS
WHERE Db = 'db_electromart';

SHOW TRIGGERS
FROM db_electromart;

-- ----------------------------------------------------------------------------
-- C. PENGUJIAN SISTEM (Jalankan satu per satu)
-- ----------------------------------------------------------------------------

-- Skenario 1 & 5: Pembelian stok tersedia & MEMENUHI syarat diskon (>= Rp1.000.000)
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX008', NOW(), 'PLG003', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX008', 'PRD004', 1, 3200000.00, 0);

-- Skenario 2 & 6: Pembelian stok tersedia & TIDAK MEMENUHI syarat diskon (< Rp1.000.000)
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX009', NOW(), 'PLG004', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX009', 'PRD002', 2, 250000.00, 0);

-- Siapkan header TRX010 untuk menguji transaksi tidak valid
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai)
VALUES ('TRX010', NOW(), 'PLG001', 'PGW002');

-- Skenario 3: Pembelian MELEBIHI stok (Harus Ditolak: Stok produk tidak mencukupi)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX010', 'PRD006', 100, 8500000.00, 0);

-- Skenario 4a: Pembelian dengan jumlah NOL (Harus Ditolak: Jumlah pembelian harus lebih dari nol)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX010', 'PRD008', 0, 85000.00, 0);

-- Skenario 4b: Pembelian dengan jumlah NEGATIF (Harus Ditolak: Jumlah pembelian harus lebih dari nol)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX010', 'PRD008', -2, 85000.00, 0);

-- Skenario 5 (Validasi Produk): Pembelian produk TIDAK TERDAFTAR (Harus Ditolak: Produk tidak ditemukan)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX010', 'PRD999', 1, 100000.00, 0);

-- Hapus header TRX010 yang tidak memiliki detail transaksi
DELETE FROM penjualan WHERE id_penjualan = 'TRX010';

-- Verifikasi hasil perhitungan diskon, perubahan stok otomatis, dan log_stok
SELECT * FROM penjualan WHERE id_penjualan IN ('TRX008', 'TRX009');
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD002', 'PRD004');
SELECT * FROM log_stok;