-- 1. Cek sesi pengguna aktif (Hasil harus: admin_andi)
SELECT current_user;

-- 2. Uji Operasi VALID: Melihat seluruh data tabel (HARUS BERHASIL)
SELECT * FROM produk;
SELECT * FROM pegawai;
SELECT * FROM penjualan;