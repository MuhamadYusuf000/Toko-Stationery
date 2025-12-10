/* =====================================================
   PROJECT UAS - DATABASE TOKO STATIONERY
   Disesuaikan dengan materi Query Pertemuan 9–14
   ===================================================== */

/* -----------------------------------------------------
   0. BUAT DATABASE
   ----------------------------------------------------- */
DROP DATABASE IF EXISTS toko_stationery;
CREATE DATABASE toko_stationery;
USE toko_stationery;

/* -----------------------------------------------------
   1. TABEL MASTER
   ----------------------------------------------------- */

-- Tabel Pelanggan
CREATE TABLE pelanggan (
    id_pelanggan    VARCHAR(10) PRIMARY KEY,
    nama_pelanggan  VARCHAR(50) NOT NULL,
    alamat          VARCHAR(100),
    nomor_hp        VARCHAR(20)
);

-- Tabel Produk
-- harga disimpan sebagai INT (satuan rupiah) agar bisa dipakai MIN, MAX, AVG
CREATE TABLE produk (
    id_produk   VARCHAR(10) PRIMARY KEY,
    nama_produk VARCHAR(100) NOT NULL,
    harga       INT NOT NULL,
    stok        INT NOT NULL
);

-- Tabel Metode Pembayaran
CREATE TABLE metode_pembayaran (
    id_metode   VARCHAR(10) PRIMARY KEY,
    nama_metode VARCHAR(50) NOT NULL,
    biaya_admin INT NOT NULL
);

-- Tabel Pemesanan (header transaksi)
CREATE TABLE pemesanan (
    id_pemesanan        VARCHAR(10) PRIMARY KEY,
    id_pelanggan        VARCHAR(10),
    tanggal_pemesanan   DATETIME,
    total_item          INT,
    total_harga         INT,
    status_pemesanan    ENUM('baru','diproses','dikirim','selesai','batal') DEFAULT 'baru',
    CONSTRAINT fk_pemesanan_pelanggan
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan)
);

-- Tabel Detail Pemesanan (detail barang per pesanan)
CREATE TABLE detail_pemesanan (
    id_pemesanan    VARCHAR(10),
    id_produk       VARCHAR(10),
    jumlah          INT,
    harga_satuan    INT,
    subtotal        INT,
    PRIMARY KEY (id_pemesanan, id_produk),
    CONSTRAINT fk_detail_pemesanan
        FOREIGN KEY (id_pemesanan) REFERENCES pemesanan(id_pemesanan),
    CONSTRAINT fk_detail_produk
        FOREIGN KEY (id_produk) REFERENCES produk(id_produk)
);

-- Tabel Pembayaran
CREATE TABLE pembayaran (
    id_pembayaran       VARCHAR(10) PRIMARY KEY,
    id_pemesanan        VARCHAR(10),
    id_metode           VARCHAR(10),
    tanggal_bayar       DATETIME,
    total_bayar         INT,
    status_pembayaran   ENUM('Belum Lunas','Lunas') DEFAULT 'Belum Lunas',
    CONSTRAINT fk_pembayaran_pemesanan
        FOREIGN KEY (id_pemesanan) REFERENCES pemesanan(id_pemesanan),
    CONSTRAINT fk_pembayaran_metode
        FOREIGN KEY (id_metode) REFERENCES metode_pembayaran(id_metode)
);

-- Tabel Pengiriman
CREATE TABLE pengiriman (
    id_pengiriman       VARCHAR(10) PRIMARY KEY,
    id_pemesanan        VARCHAR(10),
    jasa_pengiriman     VARCHAR(50),
    no_resi             VARCHAR(30),
    tanggal_kirim       DATETIME,
    ongkir              INT,
    status_pengiriman   ENUM('Belum Dikirim','Dikirim','Terkirim') DEFAULT 'Belum Dikirim',
    CONSTRAINT fk_pengiriman_pemesanan
        FOREIGN KEY (id_pemesanan) REFERENCES pemesanan(id_pemesanan)
);

-- Tabel Ulasan
CREATE TABLE ulasan (
    id_ulasan       INT AUTO_INCREMENT PRIMARY KEY,
    id_pemesanan    VARCHAR(10),
    rating          TINYINT,
    komentar        VARCHAR(255),
    tanggal_ulasan  DATETIME,
    CONSTRAINT fk_ulasan_pemesanan
        FOREIGN KEY (id_pemesanan) REFERENCES pemesanan(id_pemesanan)
);

/* -----------------------------------------------------
   2. INSERT DATA AWAL (SEEDING)
   ----------------------------------------------------- */

-- Data Pelanggan
INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, alamat, nomor_hp) VALUES
('P001', 'Andi',  'Jl. Merdeka 1',  '081234567890'),
('P002', 'Budi',  'Jl. Mawar 2',    '082234567891'),
('P003', 'Citra', 'Jl. Melati 3',   '083234567892');

-- Data Produk (disesuaikan dengan web)
INSERT INTO produk (id_produk, nama_produk, harga, stok) VALUES
('A001', 'Pulpen Pilot',        5000, 50),
('A002', 'Pensil 2B',           3000, 40),
('A003', 'Penggaris 30cm',      7000, 20),
('A004', 'Buku Tulis 58 Lbr',  10000, 30),
('A005', 'Penghapus Faber',     2000, 60),
('A006', 'Spidol Whiteboard',  12000, 15),
('A007', 'Stabilo Boss',        8000, 25),
('A008', 'Pensil Warna 12',    15000, 10);

-- Data Metode Pembayaran
INSERT INTO metode_pembayaran (id_metode, nama_metode, biaya_admin) VALUES
('M001', 'QRIS',         1000),
('M002', 'Transfer',     0),
('M003', 'COD',          0);

-- Data Pemesanan
INSERT INTO pemesanan (id_pemesanan, id_pelanggan, tanggal_pemesanan, total_item, total_harga, status_pemesanan) VALUES
('T001', 'P001', '2025-10-01 10:00:00', 2, 10000, 'selesai'),
('T002', 'P002', '2025-10-02 11:30:00', 1, 3000,  'diproses'),
('T003', 'P003', '2025-10-03 14:00:00', 3, 21000, 'selesai');

-- Data Detail Pemesanan
INSERT INTO detail_pemesanan (id_pemesanan, id_produk, jumlah, harga_satuan, subtotal) VALUES
('T001', 'A001', 2, 5000, 10000),
('T002', 'A002', 1, 3000, 3000),
('T003', 'A003', 3, 7000, 21000);

-- Data Pembayaran
INSERT INTO pembayaran (id_pembayaran, id_pemesanan, id_metode, tanggal_bayar, total_bayar, status_pembayaran) VALUES
('E001', 'T001', 'M002', '2025-10-01 10:05:00', 10000, 'Lunas'),
('E002', 'T002', 'M003', NULL,                  0,      'Belum Lunas'),
('E003', 'T003', 'M001', '2025-10-03 14:05:00', 21000, 'Lunas');

-- Data Pengiriman
INSERT INTO pengiriman (id_pengiriman, id_pemesanan, jasa_pengiriman, no_resi, tanggal_kirim, ongkir, status_pengiriman) VALUES
('G001', 'T001', 'JNE',  'R001', '2025-10-01 16:00:00', 10000, 'Terkirim'),
('G002', 'T002', 'TIKI', 'R002', NULL,                   10000, 'Belum Dikirim'),
('G003', 'T003', 'POS',  'R003', '2025-10-03 18:00:00', 8000,  'Terkirim');

-- Data Ulasan
INSERT INTO ulasan (id_pemesanan, rating, komentar, tanggal_ulasan) VALUES
('T001', 4, 'Produk bagus dan pengiriman cepat',  '2025-10-06 12:00:00'),
('T003', 5, 'Sangat puas, kualitas sesuai harga', '2025-10-08 15:30:00');

/* -----------------------------------------------------
   3. CONTOH ALTER TABLE (sesuai materi)
   ----------------------------------------------------- */

-- Menambah kolom email pada pelanggan
ALTER TABLE pelanggan
    ADD COLUMN email VARCHAR(100) AFTER nomor_hp;

-- Mengubah panjang nama_produk
ALTER TABLE produk
    MODIFY COLUMN nama_produk VARCHAR(150);

-- Menambah constraint unik (contoh: no_resi tidak boleh ganda)
ALTER TABLE pengiriman
    ADD CONSTRAINT unq_no_resi UNIQUE (no_resi);

/* -----------------------------------------------------
   4. QUERY AGREGAT (MIN, MAX, AVG, SUM)
   ----------------------------------------------------- */

-- Harga termurah, termahal, dan rata-rata harga produk
SELECT 
    MIN(harga) AS harga_termurah,
    MAX(harga) AS harga_termahal,
    AVG(harga) AS rata_rata_harga
FROM produk;

-- Total pendapatan dari pemesanan yang sudah Lunas
SELECT 
    SUM(total_harga) AS total_pendapatan_lunas
FROM pemesanan p
JOIN pembayaran bay ON p.id_pemesanan = bay.id_pemesanan
WHERE bay.status_pembayaran = 'Lunas';

/* -----------------------------------------------------
   5. CONTOH JOIN (2 TABEL & 3+ TABEL)
   ----------------------------------------------------- */

-- Join 2 tabel: nama pelanggan dan info pemesanan
SELECT 
    pel.nama_pelanggan,
    p.id_pemesanan,
    p.tanggal_pemesanan,
    p.total_harga
FROM pelanggan pel
JOIN pemesanan p ON pel.id_pelanggan = p.id_pelanggan;

-- Join 3+ tabel: pelanggan, pemesanan, detail, produk
SELECT 
    pel.nama_pelanggan,
    p.id_pemesanan,
    pr.nama_produk,
    dp.jumlah,
    dp.subtotal
FROM pelanggan pel
JOIN pemesanan p       ON pel.id_pelanggan = p.id_pelanggan
JOIN detail_pemesanan dp ON p.id_pemesanan = dp.id_pemesanan
JOIN produk pr         ON dp.id_produk = pr.id_produk;

/* -----------------------------------------------------
   6. VIEW (sesuai materi View1)
   ----------------------------------------------------- */

-- View data transaksi lengkap untuk keperluan laporan
CREATE OR REPLACE VIEW v_transaksi_lengkap AS
SELECT
    p.id_pemesanan,
    pel.nama_pelanggan,
    pel.alamat,
    pr.nama_produk,
    dp.jumlah,
    dp.subtotal,
    pm.nama_metode AS metode_pembayaran,
    bay.status_pembayaran,
    g.jasa_pengiriman,
    g.no_resi,
    u.rating,
    u.komentar
FROM pemesanan p
JOIN pelanggan pel       ON p.id_pelanggan = pel.id_pelanggan
JOIN detail_pemesanan dp ON p.id_pemesanan = dp.id_pemesanan
JOIN produk pr           ON dp.id_produk = pr.id_produk
LEFT JOIN pembayaran bay ON p.id_pemesanan = bay.id_pemesanan
LEFT JOIN metode_pembayaran pm ON bay.id_metode = pm.id_metode
LEFT JOIN pengiriman g    ON p.id_pemesanan = g.id_pemesanan
LEFT JOIN ulasan u        ON p.id_pemesanan = u.id_pemesanan;

-- Cek isi view
SELECT * FROM v_transaksi_lengkap;

/* -----------------------------------------------------
   7. TRIGGER (AFTER DELETE & AFTER INSERT) 
      UNTUK TABEL PRODUK
   ----------------------------------------------------- */

-- Tabel log produk yang dihapus
CREATE TABLE produk_hapus AS
SELECT * FROM produk WHERE 1 = 2;  -- hanya struktur

ALTER TABLE produk_hapus
    ADD COLUMN tgl_hapus DATE,
    ADD COLUMN nama_user VARCHAR(50);

-- Trigger AFTER DELETE
DELIMITER $$
CREATE TRIGGER trg_produk_hapus 
AFTER DELETE ON produk
FOR EACH ROW
BEGIN
    INSERT INTO produk_hapus (
        id_produk, nama_produk, harga, stok, tgl_hapus, nama_user
    )
    VALUES (
        OLD.id_produk,
        OLD.nama_produk,
        OLD.harga,
        OLD.stok,
        SYSDATE(),
        CURRENT_USER()
    );
END $$
DELIMITER ;

-- Tabel log produk yang ditambah
CREATE TABLE produk_tambah AS
SELECT * FROM produk WHERE 1 = 2;  -- hanya struktur

ALTER TABLE produk_tambah
    ADD COLUMN tgl_tambah DATE,
    ADD COLUMN nama_user VARCHAR(50);

-- Trigger AFTER INSERT
DELIMITER $$
CREATE TRIGGER trg_produk_tambah
AFTER INSERT ON produk
FOR EACH ROW
BEGIN
    INSERT INTO produk_tambah (
        id_produk, nama_produk, harga, stok, tgl_tambah, nama_user
    )
    VALUES (
        NEW.id_produk,
        NEW.nama_produk,
        NEW.harga,
        NEW.stok,
        CURDATE(),
        CURRENT_USER()
    );
END $$
DELIMITER ;

-- Contoh uji trigger INSERT
INSERT INTO produk (id_produk, nama_produk, harga, stok)
VALUES ('A009', 'Binder A5', 18000, 12);

SELECT * FROM produk_tambah;

-- Contoh uji trigger DELETE
DELETE FROM produk WHERE id_produk = 'A009';
SELECT * FROM produk_hapus;

/* -----------------------------------------------------
   8. STORED PROCEDURE (CREATE PROCEDURE)
   ----------------------------------------------------- */

-- Procedure untuk menambah produk baru
DELIMITER //
CREATE PROCEDURE tambah_produk (
    IN p_id_produk   VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_harga       INT,
    IN p_stok        INT
)
BEGIN
    INSERT INTO produk (id_produk, nama_produk, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_harga, p_stok);
END //
DELIMITER ;

-- Procedure untuk menghapus produk berdasarkan id_produk
DELIMITER //
CREATE PROCEDURE hapus_produk (
    IN p_id_produk VARCHAR(10)
)
BEGIN
    DELETE FROM produk
    WHERE id_produk = p_id_produk;
END //
DELIMITER ;

-- Contoh pemanggilan:
-- CALL tambah_produk('A010','Sticky Notes',6000,30);
-- CALL hapus_produk('A010');

/* -----------------------------------------------------
   9. DCL: CREATE USER & GRANT (INSERT, DELETE, ALTER)
   ----------------------------------------------------- */

-- User admin database (untuk web admin)
CREATE USER 'stationery_admin'@'127.0.0.1' IDENTIFIED BY 'admin_db123';

-- User pembeli database (untuk web pembeli / aplikasi publik)
CREATE USER 'stationery_pembeli'@'127.0.0.1' IDENTIFIED BY 'pembeli_db123';

-- Hak akses admin: boleh apa saja di database toko_stationery
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER, CREATE, DROP
ON toko_stationery.*
TO 'stationery_admin'@'127.0.0.1';

-- Hak akses pembeli:
-- - boleh lihat produk
-- - boleh membuat pemesanan & ulasan
-- - TIDAK boleh ALTER, DROP, dll
GRANT SELECT
ON toko_stationery.produk
TO 'stationery_pembeli'@'127.0.0.1';

GRANT INSERT, SELECT
ON toko_stationery.pemesanan
TO 'stationery_pembeli'@'127.0.0.1';

GRANT INSERT, SELECT
ON toko_stationery.detail_pemesanan
TO 'stationery_pembeli'@'127.0.0.1';

GRANT INSERT, SELECT
ON toko_stationery.ulasan
TO 'stationery_pembeli'@'127.0.0.1';

FLUSH PRIVILEGES;

/* -----------------------------------------------------
   10. TRANSAKSI (START TRANSACTION, ROLLBACK, COMMIT)
   ----------------------------------------------------- */

-- Contoh transaksi: penghapusan data ulasan (testing)
START TRANSACTION;

    DELETE FROM ulasan WHERE rating <= 3;

    -- Cek data sementara (belum permanen)
    SELECT * FROM ulasan;

-- Batalkan perubahan
ROLLBACK;

-- Contoh lain: commit perubahan stok
START TRANSACTION;

    UPDATE produk
    SET stok = stok - 2
    WHERE id_produk = 'A001';

    SELECT * FROM produk WHERE id_produk = 'A001';

COMMIT;

/* =====================================================
   SELESAI - DATABASE TOKO STATIONERY
   ===================================================== */
