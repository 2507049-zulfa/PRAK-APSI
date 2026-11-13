-- 1. Cek sesi pengguna aktif (Hasil harus: sales_maya)
SELECT current_user;

-- 2. Uji Operasi VALID: Melihat data produk dan pelanggan (HARUS BERHASIL)
SELECT id_produk, nama_produk, kategori, harga, stok FROM produk;
SELECT id_pelanggan, nama_pelanggan, email FROM pelanggan;

-- 3. Uji Operasi VALID: Menginput transaksi penjualan baru (HARUS BERHASIL)
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX005', CURRENT_TIMESTAMP, 'PLG001', 'PGW002', 250000.00, 0.00, 250000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX005', 'PRD002', 1, 250000.00, 250000.00);

-- 4. Uji Operasi DITOLAK 1: Mengubah struktur tabel produk (HARUS ERROR)
-- Output Error: ERROR: must be owner of table produk
ALTER TABLE produk ADD COLUMN berat INT;

-- 5. Uji Operasi DITOLAK 2: Mengakses tabel log_stok yang dibatasi (HARUS ERROR)
-- Output Error: ERROR: permission denied for table log_stok
SELECT * FROM log_stok;

-- 6. Uji Operasi DITOLAK 3: Menghapus transaksi (HARUS ERROR akibat REVOKE DELETE)
-- Output Error: ERROR: permission denied for table penjualan
DELETE FROM penjualan WHERE id_penjualan = 'TRX005';