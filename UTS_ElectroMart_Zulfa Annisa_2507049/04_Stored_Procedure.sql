-- ============================================================================
-- TUGAS 4: IMPLEMENTASI STORED PROCEDURE (PERTEMUAN 4 - MySQL / MariaDB)
-- ============================================================================

USE db_electromart;

-- 1. Membuat SP_Tampil_Produk: Menampilkan seluruh data produk
DELIMITER $$
CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT * FROM produk;
END$$
DELIMITER ;

-- 2. Membuat SP_Tambah_Produk: Menambahkan produk baru menggunakan parameter
DELIMITER $$
CREATE PROCEDURE SP_Tambah_Produk(
    p_id_produk VARCHAR(10),
    p_nama_produk VARCHAR(100),
    p_kategori VARCHAR(50),
    p_harga DECIMAL(12,2),
    p_stok INT
)
BEGIN
    INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_kategori, p_harga, p_stok);
    SELECT * FROM produk;
END$$
DELIMITER ;

-- 3. Membuat SP_Ubah_Harga: Mengubah harga produk berdasarkan ID produk dan harga baru
DELIMITER $$
CREATE PROCEDURE SP_Ubah_Harga(
    p_id_produk VARCHAR(10),
    p_harga_baru DECIMAL(12,2)
)
BEGIN
    UPDATE produk
    SET harga = p_harga_baru
    WHERE id_produk = p_id_produk;
    SELECT id_produk, nama_produk, harga FROM produk;
END$$
DELIMITER ;

-- 4. Memanggil dan Menguji Setiap Stored Procedure dengan Data Berbeda
CALL SP_Tampil_Produk();

CALL SP_Tambah_Produk('PRD011', 'SSD Samsung 1TB', 'Komponen', 1450000.00, 20);
CALL SP_Tambah_Produk('PRD012', 'Kabel HDMI 2M', 'Aksesoris', 120000.00, 35);

CALL SP_Ubah_Harga('PRD011', 1350000.00);
CALL SP_Ubah_Harga('PRD012', 110000.00);

-- Menampilkan daftar Stored Procedure yang tersimpan
SHOW PROCEDURE STATUS
WHERE Db = 'db_electromart';

-- 5. Menghapus Salah Satu Procedure Menggunakan DROP PROCEDURE
DROP PROCEDURE IF EXISTS SP_Ubah_Harga;

-- Memastikan SP_Ubah_Harga telah terhapus
SHOW PROCEDURE STATUS
WHERE Db = 'db_electromart';