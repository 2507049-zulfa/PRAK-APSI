-- Cek akun admin dan database aktif
SELECT current_user AS akun_aktif, current_database() AS database_aktif;

-- ============================================================================
-- 1. KONFIGURASI ROLE_ADMIN (Andi Wijaya)
-- ============================================================================

-- Membuat role_admin

CREATE ROLE role_admin;

-- Memberikan seluruh hak akses database, schema, tabel, dan sequence
GRANT CONNECT ON DATABASE db_electromart TO role_admin;
GRANT ALL PRIVILEGES ON DATABASE db_electromart TO role_admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

-- Membuat akun pengguna admin dan menghubungkannya ke role_admin
CREATE USER admin_andi WITH PASSWORD 'PasswordAdmin123';
GRANT role_admin TO admin_andi;

-- ============================================================================
-- 2. KONFIGURASI ROLE_PENJUALAN (Maya Putri)
-- ============================================================================

-- Membuat role_penjualan
CREATE ROLE role_penjualan;

-- Memberikan hak akses koneksi & schema
GRANT CONNECT ON DATABASE db_electromart TO role_penjualan;
GRANT USAGE ON SCHEMA public TO role_penjualan;

-- Memberikan hak baca (SELECT) pada tabel produk, pelanggan, dan pegawai
GRANT SELECT ON TABLE produk TO role_penjualan;
GRANT SELECT ON TABLE pelanggan TO role_penjualan;
GRANT SELECT ON TABLE pegawai TO role_penjualan;

-- Memberikan hak input & ubah transaksi pada penjualan dan detail_penjualan
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE penjualan TO role_penjualan;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE detail_penjualan TO role_penjualan;
GRANT USAGE, SELECT ON SEQUENCE detail_penjualan_id_detail_seq TO role_penjualan;

-- Mencabut hak DELETE agar kasir tidak dapat menghapus riwayat transaksi (REVOKE)
REVOKE DELETE ON TABLE penjualan FROM role_penjualan;
REVOKE DELETE ON TABLE detail_penjualan FROM role_penjualan;

-- Membuat akun pengguna sales dan menghubungkannya ke role_penjualan
CREATE USER sales_maya WITH PASSWORD 'PasswordSales123';
GRANT role_penjualan TO sales_maya;

-- ============================================================================
-- 3. KONFIGURASI ROLE_GUDANG (Eko Prasetyo)
-- ============================================================================

-- Membuat role_gudang
CREATE ROLE role_gudang;

-- Memberikan hak akses koneksi & schema
GRANT CONNECT ON DATABASE db_electromart TO role_gudang;
GRANT USAGE ON SCHEMA public TO role_gudang;

-- Memberikan hak baca produk & hak UPDATE khusus pada kolom stok saja
GRANT SELECT ON TABLE produk TO role_gudang;
GRANT UPDATE (stok) ON TABLE produk TO role_gudang;

-- Memberikan hak membaca dan mencatat riwayat stok pada tabel log_stok
GRANT SELECT, INSERT ON TABLE log_stok TO role_gudang;
GRANT USAGE, SELECT ON SEQUENCE log_stok_id_log_seq TO role_gudang;

-- Memastikan role_gudang tidak memiliki izin hapus pada tabel log_stok
REVOKE DELETE ON TABLE log_stok FROM role_gudang;

-- Membuat akun pengguna gudang dan menghubungkannya ke role_gudang
CREATE USER gudang_eko WITH PASSWORD 'PasswordGudang123!';
GRANT role_gudang TO gudang_eko;

-- ============================================================================
-- 4. KONFIGURASI ROLE_MANAJER (Hendra Gunawan)
-- ============================================================================

-- Membuat role_manajer
CREATE ROLE role_manajer;

-- Memberikan hak akses koneksi & schema
GRANT CONNECT ON DATABASE db_electromart TO role_manajer;
GRANT USAGE ON SCHEMA public TO role_manajer;

-- Memberikan hak baca (SELECT) pada seluruh tabel untuk kebutuhan laporan
GRANT SELECT ON TABLE produk TO role_manajer;
GRANT SELECT ON TABLE pelanggan TO role_manajer;
GRANT SELECT ON TABLE pegawai TO role_manajer;
GRANT SELECT ON TABLE penjualan TO role_manajer;
GRANT SELECT ON TABLE detail_penjualan TO role_manajer;
GRANT SELECT ON TABLE log_stok TO role_manajer;

-- Memastikan hak modifikasi dan hapus dicabut dari role_manajer (REVOKE)
REVOKE INSERT, UPDATE, DELETE ON TABLE penjualan FROM role_manajer;
REVOKE INSERT, UPDATE, DELETE ON TABLE produk FROM role_manajer;

-- Membuat akun pengguna manajer dan menghubungkannya ke role_manajer
CREATE USER manajer_hendra WITH PASSWORD 'PasswordManajer123';
GRANT role_manajer TO manajer_hendra;