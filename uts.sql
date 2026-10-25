CREATE TABLE kamar (
    no_kamar        VARCHAR(10)  NOT NULL,
    lokasi_meteran  VARCHAR(100) NULL,
    PRIMARY KEY (no_kamar)
) ENGINE=InnoDB;

CREATE TABLE penghuni (
    id_penghuni    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nama_penghuni  VARCHAR(100) NOT NULL,
    no_whatsapp    VARCHAR(15)  NULL,
    PRIMARY KEY (id_penghuni),
    UNIQUE KEY uq_penghuni_whatsapp (no_whatsapp),
    KEY idx_penghuni_nama (nama_penghuni),
    CONSTRAINT ck_penghuni_nama
        CHECK (CHAR_LENGTH(TRIM(nama_penghuni)) > 0),
    CONSTRAINT ck_penghuni_whatsapp
        CHECK (no_whatsapp IS NULL OR no_whatsapp REGEXP '^[0-9]{9,15}$')
) ENGINE=InnoDB;

CREATE TABLE hunian (
    id_hunian       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    no_kamar        VARCHAR(10)  NOT NULL,
    id_penghuni     INT UNSIGNED NOT NULL,
    tanggal_masuk   DATE         NOT NULL,
    tanggal_keluar  DATE         NULL,
    PRIMARY KEY (id_hunian),
    UNIQUE KEY uq_hunian_kamar (id_hunian, no_kamar),
    KEY idx_hunian_kamar_keluar (no_kamar, tanggal_keluar),
    KEY idx_hunian_penghuni (id_penghuni),
    CONSTRAINT fk_hunian_kamar
        FOREIGN KEY (no_kamar)    REFERENCES kamar (no_kamar),
    CONSTRAINT fk_hunian_penghuni
        FOREIGN KEY (id_penghuni) REFERENCES penghuni (id_penghuni),
    CONSTRAINT ck_hunian_tanggal
        CHECK (tanggal_keluar IS NULL OR tanggal_keluar >= tanggal_masuk)
) ENGINE=InnoDB;

CREATE TABLE pembacaan_meter (
    no_kamar      VARCHAR(10)   NOT NULL,
    waktu_catat   DATETIME      NOT NULL,
    angka_kwh     DECIMAL(10,2) NOT NULL,
    foto_meteran  VARCHAR(255)  NULL,
    pencatat      VARCHAR(50)   NOT NULL,
    jenis_catat   ENUM('Bulanan','Masuk','Keluar','Harian') NOT NULL DEFAULT 'Bulanan',
    sumber_catat  ENUM('Manual','Otomatis') NOT NULL DEFAULT 'Manual',
    PRIMARY KEY (no_kamar, waktu_catat),
    KEY idx_pembacaan_jenis (jenis_catat, waktu_catat),
    CONSTRAINT fk_pembacaan_kamar
        FOREIGN KEY (no_kamar) REFERENCES kamar (no_kamar),
    CONSTRAINT ck_pembacaan_angka
        CHECK (angka_kwh >= 0),
    CONSTRAINT ck_pembacaan_foto
        CHECK (sumber_catat = 'Otomatis' OR foto_meteran IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE tagihan (
    id_tagihan         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    id_hunian          INT UNSIGNED  NOT NULL,
    no_kamar           VARCHAR(10)   NOT NULL,
    waktu_catat_awal   DATETIME      NOT NULL,
    waktu_catat_akhir  DATETIME      NOT NULL,
    periode            DATE GENERATED ALWAYS AS
        (DATE_SUB(DATE(waktu_catat_awal), INTERVAL (DAYOFMONTH(waktu_catat_awal) - 1) DAY)) STORED,
    tarif_per_kwh      DECIMAL(10,2) NOT NULL DEFAULT 2000.00,
    tgl_bayar          DATE          NULL,
    metode_bayar       ENUM('Tunai','Transfer') NULL,
    PRIMARY KEY (id_tagihan),
    UNIQUE KEY uq_tagihan_hunian_periode (id_hunian, periode),
    UNIQUE KEY uq_tagihan_awal  (no_kamar, waktu_catat_awal),
    UNIQUE KEY uq_tagihan_akhir (no_kamar, waktu_catat_akhir),
    KEY idx_tagihan_periode (periode),
    CONSTRAINT fk_tagihan_hunian
        FOREIGN KEY (id_hunian, no_kamar)
        REFERENCES hunian (id_hunian, no_kamar),
    CONSTRAINT fk_tagihan_awal
        FOREIGN KEY (no_kamar, waktu_catat_awal)
        REFERENCES pembacaan_meter (no_kamar, waktu_catat),
    CONSTRAINT fk_tagihan_akhir
        FOREIGN KEY (no_kamar, waktu_catat_akhir)
        REFERENCES pembacaan_meter (no_kamar, waktu_catat),
    CONSTRAINT ck_tagihan_urutan
        CHECK (waktu_catat_awal < waktu_catat_akhir),
    CONSTRAINT ck_tagihan_tarif
        CHECK (tarif_per_kwh > 0),
    CONSTRAINT ck_tagihan_bayar
        CHECK ((tgl_bayar IS NULL AND metode_bayar IS NULL)
            OR (tgl_bayar IS NOT NULL AND metode_bayar IS NOT NULL))
) ENGINE=InnoDB;

CREATE TABLE peringatan_lonjakan (
    id_peringatan         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    no_kamar              VARCHAR(10)   NOT NULL,
    waktu_catat           DATETIME      NOT NULL,
    persen_kenaikan       DECIMAL(7,2)  NOT NULL,
    ambang_persen         DECIMAL(7,2)  NOT NULL DEFAULT 50.00,
    status_tindak_lanjut  ENUM('Baru','Diperiksa','Selesai') NOT NULL DEFAULT 'Baru',
    penyebab              ENUM('Alat berdaya besar','Salah baca','Gangguan instalasi','Lainnya') NULL,
    catatan               VARCHAR(255)  NULL,
    waktu_selesai         DATETIME      NULL,
    PRIMARY KEY (id_peringatan),
    UNIQUE KEY uq_peringatan_pembacaan (no_kamar, waktu_catat),
    KEY idx_peringatan_status (status_tindak_lanjut),
    CONSTRAINT fk_peringatan_pembacaan
        FOREIGN KEY (no_kamar, waktu_catat)
        REFERENCES pembacaan_meter (no_kamar, waktu_catat),
    CONSTRAINT ck_peringatan_ambang
        CHECK (ambang_persen > 0),
    CONSTRAINT ck_peringatan_persen
        CHECK (persen_kenaikan > ambang_persen),
    CONSTRAINT ck_peringatan_selesai
        CHECK ((status_tindak_lanjut = 'Selesai' AND penyebab IS NOT NULL
                AND waktu_selesai IS NOT NULL AND waktu_selesai >= waktu_catat)
            OR (status_tindak_lanjut <> 'Selesai' AND waktu_selesai IS NULL))
) ENGINE=InnoDB;

CREATE TABLE tagihan_pln (
    periode          DATE          NOT NULL,
    total_kwh_pln    DECIMAL(10,2) NOT NULL,
    total_biaya_pln  DECIMAL(14,2) NOT NULL,
    tgl_terbit       DATE          NULL,
    PRIMARY KEY (periode),
    CONSTRAINT ck_pln_periode CHECK (DAYOFMONTH(periode) = 1),
    CONSTRAINT ck_pln_kwh     CHECK (total_kwh_pln > 0),
    CONSTRAINT ck_pln_biaya   CHECK (total_biaya_pln >= 0)
) ENGINE=InnoDB;

CREATE TABLE izin_alat (
    id_izin        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_hunian      INT UNSIGNED NOT NULL,
    jenis_alat     VARCHAR(50)  NOT NULL,
    daya_watt      INT UNSIGNED NOT NULL,
    tgl_pengajuan  DATE         NOT NULL,
    status_izin    ENUM('Diajukan','Disetujui','Ditolak') NOT NULL DEFAULT 'Diajukan',
    tgl_keputusan  DATE         NULL,
    catatan        VARCHAR(255) NULL,
    PRIMARY KEY (id_izin),
    KEY idx_izin_hunian (id_hunian),
    KEY idx_izin_status (status_izin),
    CONSTRAINT fk_izin_hunian
        FOREIGN KEY (id_hunian) REFERENCES hunian (id_hunian),
    CONSTRAINT ck_izin_daya
        CHECK (daya_watt > 0),
    CONSTRAINT ck_izin_keputusan
        CHECK ((status_izin = 'Diajukan' AND tgl_keputusan IS NULL)
            OR (status_izin <> 'Diajukan' AND tgl_keputusan IS NOT NULL
                AND tgl_keputusan >= tgl_pengajuan))
) ENGINE=InnoDB;

CREATE TABLE keberatan_tagihan (
    id_keberatan      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_tagihan        INT UNSIGNED NOT NULL,
    tgl_pengajuan     DATE         NOT NULL,
    alasan            VARCHAR(255) NOT NULL,
    status_keberatan  ENUM('Diajukan','Diperiksa','Diterima','Ditolak') NOT NULL DEFAULT 'Diajukan',
    hasil_pengecekan  VARCHAR(255) NULL,
    tgl_selesai       DATE         NULL,
    PRIMARY KEY (id_keberatan),
    KEY idx_keberatan_tagihan (id_tagihan),
    KEY idx_keberatan_status (status_keberatan),
    CONSTRAINT fk_keberatan_tagihan
        FOREIGN KEY (id_tagihan) REFERENCES tagihan (id_tagihan),
    CONSTRAINT ck_keberatan_selesai
        CHECK ((status_keberatan IN ('Diterima','Ditolak')
                AND tgl_selesai IS NOT NULL AND hasil_pengecekan IS NOT NULL
                AND tgl_selesai >= tgl_pengajuan)
            OR (status_keberatan IN ('Diajukan','Diperiksa') AND tgl_selesai IS NULL))
) ENGINE=InnoDB;

CREATE VIEW v_status_kamar AS
SELECT k.no_kamar,
       CASE WHEN EXISTS (SELECT 1 FROM hunian h
                         WHERE h.no_kamar = k.no_kamar AND h.tanggal_keluar IS NULL)
            THEN 'Terisi' ELSE 'Kosong' END AS status_kamar
FROM kamar k;

CREATE VIEW v_tagihan_detail AS
SELECT t.id_tagihan,
       t.periode,
       t.no_kamar,
       p.nama_penghuni,
       (b2.angka_kwh - b1.angka_kwh)                      AS pemakaian_kwh,
       t.tarif_per_kwh,
       (b2.angka_kwh - b1.angka_kwh) * t.tarif_per_kwh    AS total_tagihan,
       CASE WHEN t.tgl_bayar IS NULL THEN 'Belum Lunas' ELSE 'Lunas' END AS status_bayar,
       t.tgl_bayar,
       t.metode_bayar
FROM tagihan t
JOIN hunian  h  ON h.id_hunian = t.id_hunian
JOIN penghuni p ON p.id_penghuni = h.id_penghuni
JOIN pembacaan_meter b1 ON b1.no_kamar = t.no_kamar AND b1.waktu_catat = t.waktu_catat_awal
JOIN pembacaan_meter b2 ON b2.no_kamar = t.no_kamar AND b2.waktu_catat = t.waktu_catat_akhir;

CREATE VIEW v_pemakaian_bulanan_kamar AS
SELECT x.no_kamar, x.periode, x.pemakaian_kwh
FROM (
    SELECT no_kamar,
           DATE_SUB(DATE(waktu_catat), INTERVAL (DAYOFMONTH(waktu_catat) - 1) DAY) AS periode,
           LEAD(angka_kwh) OVER (PARTITION BY no_kamar ORDER BY waktu_catat) - angka_kwh AS pemakaian_kwh
    FROM pembacaan_meter
    WHERE jenis_catat = 'Bulanan'
) x
WHERE x.pemakaian_kwh IS NOT NULL;

CREATE VIEW v_rekap_pln AS
SELECT pl.periode,
       pl.total_kwh_pln,
       SUM(u.pemakaian_kwh)                                   AS total_kwh_kamar,
       pl.total_kwh_pln - SUM(u.pemakaian_kwh)                AS selisih_kwh,
       pl.total_biaya_pln,
       ROUND(GREATEST(pl.total_kwh_pln - SUM(u.pemakaian_kwh), 0)
             * pl.total_biaya_pln / pl.total_kwh_pln, 2)      AS biaya_ditanggung_pemilik
FROM tagihan_pln pl
JOIN v_pemakaian_bulanan_kamar u ON u.periode = pl.periode
GROUP BY pl.periode, pl.total_kwh_pln, pl.total_biaya_pln;
