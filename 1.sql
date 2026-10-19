CREATE TABLE kamar (
    id_kamar INT NOT NULL AUTO_INCREMENT,
    no_kamar VARCHAR(10) NOT NULL,              
    PRIMARY KEY (id_kamar),
    UNIQUE KEY uq_no_kamar (no_kamar)        
) ENGINE=InnoDB;

CREATE TABLE penghuni (
    id_penghuni INT NOT NULL AUTO_INCREMENT,
    nama_penghuni VARCHAR(100) NOT NULL,
    no_whatsapp VARCHAR(15) NULL DEFAULT NULL,
    id_kamar INT NOT NULL,
    PRIMARY KEY (id_penghuni),
    KEY idx_nama_penghuni (nama_penghuni),
    CONSTRAINT fk_penghuni_kamar
        FOREIGN KEY (id_kamar)
        REFERENCES kamar (id_kamar)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE tagihan (
    id_tagihan INT NOT NULL AUTO_INCREMENT,
    id_pencatatan INT NOT NULL,
    total_tagihan  DECIMAL(12,2) NOT NULL,
    status_bayar   ENUM('Belum Bayar','Lunas') NOT NULL DEFAULT 'Belum Bayar',
    tanggal_bayar DATE NULL DEFAULT NULL,
    id_kamar INT NOT NULL,
    id_penghuni INT NOT NULL,
    PRIMARY KEY (id_tagihan),
    UNIQUE KEY id_pencatatan (id_pencatatan),
    KEY idx_status_bayar (status_bayar),
    CONSTRAINT fk_tagihan_kamar
        FOREIGN KEY (id_kamar)
        REFERENCES kamar (id_kamar)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_tagihan_penghuni
        FOREIGN KEY (id_penghuni)
        REFERENCES penghuni (id_penghuni)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
