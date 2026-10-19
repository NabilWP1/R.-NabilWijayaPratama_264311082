SELECT
    p.nama_penghuni,
    k.no_kamar,
    COUNT(t.id_tagihan)   AS jumlah_tagihan_lunas,
    SUM(t.total_tagihan)  AS total_dibayar
FROM tagihan t
JOIN penghuni p ON p.id_penghuni = t.id_penghuni
JOIN kamar    k ON k.id_kamar    = t.id_kamar
WHERE t.status_bayar = 'Lunas'
  AND t.tanggal_bayar BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY p.id_penghuni, p.nama_penghuni, k.no_kamar;
