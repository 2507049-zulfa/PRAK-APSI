-- TUGAS 1: KONFIGURASI INDEXING (PERTEMUAN 1 - PostgreSQL)

-- 1. Menampilkan databse yang sudah di buat
SELECT current_database();

-- 2. Membuat Struktur Tabel Basis Data ElectroMart
CREATE TABLE produk (
    id_produk VARCHAR(10) PRIMARY KEY NOT NULL,
    nama_produk VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    harga DECIMAL(12,2) NOT NULL,
    stok INT NOT NULL DEFAULT 0
);

CREATE TABLE pelanggan (
    id_pelanggan VARCHAR(10) PRIMARY KEY NOT NULL,
    nama_pelanggan VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_hp VARCHAR(20) NULL,
    alamat TEXT NULL
);

CREATE TABLE pegawai (
    id_pegawai VARCHAR(10) PRIMARY KEY NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    peran VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_hp VARCHAR(20) NULL
);

CREATE TABLE penjualan (
    id_penjualan VARCHAR(10) PRIMARY KEY NOT NULL,
    tanggal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_pelanggan VARCHAR(10) NOT NULL,
    id_pegawai VARCHAR(10) NOT NULL,
    total_harga DECIMAL(12,2) NOT NULL DEFAULT 0,
    diskon DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_bayar DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_penjualan_pelanggan
        FOREIGN KEY (id_pelanggan)
        REFERENCES pelanggan(id_pelanggan),
    CONSTRAINT fk_penjualan_pegawai
        FOREIGN KEY (id_pegawai)
        REFERENCES pegawai(id_pegawai)
);

CREATE TABLE detail_penjualan (
    id_detail SERIAL PRIMARY KEY,
    id_penjualan VARCHAR(10) NOT NULL,
    id_produk VARCHAR(10) NOT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_detail_penjualan
        FOREIGN KEY (id_penjualan)
        REFERENCES penjualan(id_penjualan),
    CONSTRAINT fk_detail_produk
        FOREIGN KEY (id_produk)
        REFERENCES produk(id_produk)
);

CREATE TABLE log_stok (
    id_log SERIAL PRIMARY KEY,
    id_produk VARCHAR(10) NOT NULL,
    jumlah_perubahan INT NOT NULL,
    tipe_transaksi VARCHAR(20) NOT NULL,
    keterangan VARCHAR(255) NULL,
    tanggal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_produk
        FOREIGN KEY (id_produk)
        REFERENCES produk(id_produk)
);

-- 3. Memasukkan Dataset Produk, Pelanggan, dan Transaksi
INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok)
VALUES
('PRD001', 'Laptop Asus ZenBook 14', 'Laptop', 14500000.00, 15),
('PRD002', 'Mouse Wireless Logitech M330', 'Aksesoris', 250000.00, 50),
('PRD003', 'Keyboard Mekanikal Keychron K2', 'Aksesoris', 1200000.00, 3),
('PRD004', 'Monitor LG 27 Inch IPS', 'Monitor', 3200000.00, 8),
('PRD005', 'Smartphone Samsung Galaxy S23', 'Smartphone', 12999000.00, 10),
('PRD006', 'Smart TV Sony 55 Inch 4K', 'TV', 8500000.00, 2),
('PRD007', 'Headphone Sony WH-1000XM5', 'Audio', 4499000.00, 12),
('PRD008', 'Flashdisk SanDisk 64GB', 'Aksesoris', 85000.00, 100),
('PRD009', 'Printer Epson EcoTank L3210', 'Periferal', 2400000.00, 4),
('PRD010', 'Webcam Logitech C920', 'Aksesoris', 950000.00, 25);

select * from produk;

INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, email, no_hp, alamat)
VALUES
('PLG001', 'Budi Santoso', 'budi.santoso@email.com', '085611223344', 'Jl. Merdeka No. 12, Jakarta'),
('PLG002', 'Siti Aminah', 'siti.aminah@email.com', '085622334455', 'Jl. Mawar No. 5, Bandung'),
('PLG003', 'Rian Hidayat', 'rian.hidayat@email.com', '085633445566', 'Jl. Pemuda No. 88, Surabaya'),
('PLG004', 'Dewi Lestari', 'dewi.lestari@email.com', '085644556677', 'Jl. Diponegoro No. 45, Semarang'),
('PLG005', 'Ahmad Fauzi', 'ahmad.fauzi@email.com', '085655667788', 'Jl. Gajah Mada No. 20, Yogyakarta');

select * from pelanggan;

INSERT INTO pegawai (id_pegawai, nama_pegawai, peran, email, no_hp)
VALUES
('PGW001', 'Andi Wijaya', 'role_admin', 'andi.admin@electromart.com', '081234567890'),
('PGW002', 'Maya Putri', 'role_penjualan', 'maya.sales@electromart.com', '081234567891'),
('PGW003', 'Eko Prasetyo', 'role_gudang', 'eko.gudang@electromart.com', '081234567892'),
('PGW004', 'Hendra Gunawan', 'role_manajer', 'hendra.manager@electromart.com', '081234567893');

select * from pegawai;

INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES
('TRX001', '2026-11-01 10:15:00', 'PLG001', 'PGW002', 15000000.00, 1500000.00, 13500000.00),
('TRX002', '2026-11-03 14:30:00', 'PLG002', 'PGW002', 850000.00, 0.00, 850000.00),
('TRX003', '2026-11-05 11:00:00', 'PLG003', 'PGW002', 4400000.00, 440000.00, 3960000.00),
('TRX004', '2026-11-08 16:45:00', 'PLG004', 'PGW002', 12999000.00, 1299900.00, 11699100.00);

select * from penjualan;

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX001', 'PRD001', 1, 14500000.00, 14500000.00),
('TRX001', 'PRD002', 2, 250000.00, 500000.00),
('TRX002', 'PRD008', 10, 85000.00, 850000.00),
('TRX003', 'PRD003', 1, 1200000.00, 1200000.00),
('TRX003', 'PRD004', 1, 3200000.00, 3200000.00),
('TRX004', 'PRD005', 1, 12999000.00, 12999000.00);

select * from detail_penjualan;

INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan, tanggal)
VALUES
('PRD001', 16, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD001', -1, 'KELUAR', 'Pengurangan stok dari TRX001', '2026-11-01 10:15:00'),
('PRD002', 52, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD002', -2, 'KELUAR', 'Pengurangan stok dari TRX001', '2026-11-01 10:15:00'),
('PRD008', 110, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD008', -10, 'KELUAR', 'Pengurangan stok dari TRX002', '2026-11-03 14:30:00'),
('PRD003', 4, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD003', -1, 'KELUAR', 'Pengurangan stok dari TRX003', '2026-11-05 11:00:00'),
('PRD004', 9, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD004', -1, 'KELUAR', 'Pengurangan stok dari TRX003', '2026-11-05 11:00:00'),
('PRD005', 11, 'MASUK', 'Stok awal barang masuk dari distributor', '2026-10-25 08:00:00'),
('PRD005', -1, 'KELUAR', 'Pengurangan stok dari TRX004', '2026-11-08 16:45:00');

select * from log_stok;

-- Verifikasi Dataset
SELECT COUNT(*) AS jumlah_produk FROM produk;
SELECT COUNT(*) AS jumlah_pelanggan FROM pelanggan;
SELECT COUNT(*) AS jumlah_pegawai FROM pegawai;
SELECT COUNT(*) AS jumlah_penjualan FROM penjualan;
SELECT COUNT(*) AS jumlah_detail_penjualan FROM detail_penjualan;
SELECT COUNT(*) AS jumlah_log_stok FROM log_stok;

-- 4. Membuat Single-Column Index (Minimal 2)
CREATE INDEX idx_produk_kategori
ON produk(kategori);

CREATE INDEX idx_penjualan_tanggal
ON penjualan(tanggal);

-- 5. Membuat Composite Index (Minimal 1)
CREATE INDEX idx_penjualan_pelanggan_tanggal
ON penjualan(id_pelanggan, tanggal);

-- 6. Memeriksa Index Menggunakan Katalog pg_indexes
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'produk';
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'penjualan';

-- 7. Pengujian Query Pencarian
SELECT * FROM produk
WHERE kategori = 'Aksesoris';

SELECT * FROM penjualan
WHERE id_pelanggan = 'PLG001'
AND tanggal BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';