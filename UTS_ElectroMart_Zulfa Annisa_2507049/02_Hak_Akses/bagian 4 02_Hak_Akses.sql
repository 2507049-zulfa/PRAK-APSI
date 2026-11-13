-- 1. Cek sesi pengguna aktif (Hasil harus: gudang_eko)
SELECT current_user;

-- 2. Uji Operasi VALID: Membaca data produk dan memperbarui kolom stok (HARUS BERHASIL)
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk = 'PRD001';

UPDATE produk
SET stok = 16
WHERE id_produk = 'PRD001';

-- 3. Uji Operasi VALID: Mencatat perubahan stok ke tabel log_stok (HARUS BERHASIL)
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD001', 1, 'MASUK', 'Penambahan stok oleh staf gudang');

-- 4. Uji Operasi DITOLAK 1: Mengubah kolom harga produk (HARUS ERROR)
-- Output Error: ERROR: permission denied for table produk
UPDATE produk
SET harga = 10000000.00
WHERE id_produk = 'PRD001';

-- 5. Uji Operasi DITOLAK 2: Melihat data transaksi penjualan (HARUS ERROR)
-- Output Error: ERROR: permission denied for table penjualan
SELECT * FROM penjualan;