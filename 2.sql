--1. [CREATE]--
INSERT INTO kamar (id_kamar, no_kamar) VALUES
    (1, 'A01'),
    (2, 'A02'),
    (3, 'B01'),
    (4, 'B02');

INSERT INTO penghuni (id_penghuni, nama_penghuni, no_whatsapp, id_kamar) VALUES
    (1, 'Riki', '081355501001', 1),
    (2, 'Fitri', '081355501002', 2),
    (3, 'David', '081355501003', 2),
    (4, 'Aceng', '081355501004', 3);

INSERT INTO tagihan
    (id_tagihan, id_pencatatan, total_tagihan, status_bayar, tanggal_bayar, id_kamar, id_penghuni) VALUES
    (1, 201, 165000.00, 'Lunas', '2026-10-05', 1, 1),
    (2, 202, 118500.00, 'Belum Bayar', NULL, 2, 2),
    (3, 203, 240000.00, 'Belum Bayar', NULL, 3, 4),
    (4, 204, 99000.00, 'Belum Bayar', NULL, 3, 4);

--2. [READ]--
SELECT * FROM kamar;

--3. [UPDATE]--
UPDATE tagihan
SET    status_bayar  = 'Lunas',
       tanggal_bayar = '2026-10-12'
WHERE  id_tagihan = 3;

--4. [DELETE]--
DELETE FROM tagihan
WHERE  id_tagihan = 4;
