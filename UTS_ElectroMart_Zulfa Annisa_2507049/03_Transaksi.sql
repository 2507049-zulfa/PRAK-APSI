-- ============================================================================
-- TUGAS 3: PENGELOLAAN TRANSAKSI (PERTEMUAN 3 - MySQL / MariaDB)
-- ============================================================================

USE db_electromart;

-- ----------------------------------------------------------------------------
-- SKENARIO A: Transaksi Penjualan Berhasil (COMMIT)
-- Pelanggan membeli 1 unit Laptop (PRD001) dan 2 unit Mouse (PRD002)
-- ----------------------------------------------------------------------------

-- Periksa stok sebelum transaksi
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002');

START TRANSACTION;

INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX005', NOW(), 'PLG005', 'PGW002', 15000000.00, 1500000.00, 13500000.00);

select * from penjualan;

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX005', 'PRD001', 1, 14500000.00, 14500000.00),
('TRX005', 'PRD002', 2, 250000.00, 500000.00);

select * from detail_penjualan;

UPDATE produk
SET stok = stok - 1
WHERE id_produk = 'PRD001';

UPDATE produk
SET stok = stok - 2
WHERE id_produk = 'PRD002';

select * from produk;

INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES
('PRD001', -1, 'KELUAR', 'Pengurangan stok dari TRX005'),
('PRD002', -2, 'KELUAR', 'Pengurangan stok dari TRX005');

select * from log_stok;

-- Periksa perubahan sementara sebelum COMMIT
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002');

COMMIT;

-- Verifikasi setelah COMMIT
SELECT * FROM penjualan WHERE id_penjualan = 'TRX005';
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002');

-- ----------------------------------------------------------------------------
-- SKENARIO B: Transaksi Gagal - Pembelian Melebihi Stok (ROLLBACK)
-- Pelanggan membeli 5 unit Smart TV (PRD006), sedangkan stok tersedia hanya 2
-- ----------------------------------------------------------------------------

-- Catat stok saat ini
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk = 'PRD006';

START TRANSACTION;

INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX006', NOW(), 'PLG001', 'PGW002', 42500000.00, 4250000.00, 38250000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD006', 5, 8500000.00, 42500000.00);

select * from penjualan;
select * from detail_penjualan;

-- Periksa data sementara sebelum ROLLBACK
SELECT * FROM penjualan WHERE id_penjualan = 'TRX006';

-- Batalkan seluruh transaksi karena jumlah (5) melebihi stok tersedia (2)
ROLLBACK;

-- Verifikasi setelah ROLLBACK (TRX006 batal dan stok PRD006 tetap 2)
SELECT * FROM penjualan WHERE id_penjualan = 'TRX006';
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk = 'PRD006';

-- ----------------------------------------------------------------------------
-- SKENARIO C: Pembatalan Sebagian Transaksi (SAVEPOINT & RELEASE SAVEPOINT)
-- ----------------------------------------------------------------------------

-- Catat stok awal PRD004 (8) dan PRD003 (3)
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD003', 'PRD004');

START TRANSACTION;

INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX007', NOW(), 'PLG002', 'PGW002', 3200000.00, 320000.00, 2880000.00);

-- Perubahan 1 (Valid): Beli 1 unit Monitor LG (PRD004)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD004', 1, 3200000.00, 3200000.00);

UPDATE produk
SET stok = stok - 1
WHERE id_produk = 'PRD004';

INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD004', -1, 'KELUAR', 'Pengurangan stok dari TRX007');

-- Tandai titik aman setelah item pertama
SAVEPOINT setelah_item_pertama;

-- Perubahan 2 (Melebihi stok): Beli 5 unit Keyboard (PRD003, stok hanya 3)
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD003', 5, 1200000.00, 6000000.00);

-- Batalkan hanya perubahan setelah SAVEPOINT
ROLLBACK TO SAVEPOINT setelah_item_pertama;

-- Lepaskan penanda SAVEPOINT yang sudah tidak diperlukan
RELEASE SAVEPOINT setelah_item_pertama;

-- Simpan transaksi utama
commit;

-- Bukti hasil akhir menggunakan SELECT
SELECT * FROM penjualan WHERE id_penjualan = 'TRX007';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX007';
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD003', 'PRD004');