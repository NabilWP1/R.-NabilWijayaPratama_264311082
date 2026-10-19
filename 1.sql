CREATE TABLE kamar_penghuni (
    no_kamar       VARCHAR(5)   NOT NULL,
    nama_penghuni  VARCHAR(100) NOT NULL,
    no_hp          VARCHAR(15)  NOT NULL,
    PRIMARY KEY (no_kamar)
) ENGINE=InnoDB;

CREATE TABLE tagihan (
    id_tagihan     VARCHAR(10)  NOT NULL,
    pemakaian_kwh  INT          NOT NULL,
    tgl_bayar      DATE         NULL,
    PRIMARY KEY (id_tagihan)
) ENGINE=InnoDB;

