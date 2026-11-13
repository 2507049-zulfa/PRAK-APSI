-- 1. Cek sesi pengguna aktif (Hasil harus: manajer_hendra)
SELECT current_user;

-- 2. Uji Operasi VALID: Melihat informasi produk dan laporan penjualan (HARUS BERHASIL)
SELECT id_produk, nama_produk, kategori, harga, stok FROM produk;
SELECT * FROM penjualan;

-- 3. Uji Operasi DITOLAK 1: Menghapus data penjualan (HARUS ERROR)
-- Output Error: ERROR: permission denied for table penjualan
DELETE FROM penjualan WHERE id_penjualan = 'TRX001';

-- 4. Uji Operasi DITOLAK 2: Mengubah harga produk (HARUS ERROR)
-- Output Error: ERROR: permission denied for table produk
UPDATE produk SET harga = 5000000.00 WHERE id_produk = 'PRD001';