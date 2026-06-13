const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");

const app = express();

app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "CBT_Point",
});

db.connect((err) => {
  if (err) {
    console.log(err);
    return;
  }
  console.log("MySQL Connected to CBT_Point");
});

const api = express.Router();

// ================= AUTH & USERS =================
api.post("/auth/login/guru", (req, res) => {
  const { nama, nip } = req.body;
  db.query("SELECT * FROM guru WHERE LOWER(nama) = LOWER(?) AND nip = ?", [nama, nip], (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length > 0) return res.json({ role: "guru", user: result[0] });
    res.status(401).json({ error: "Invalid credentials" });
  });
});

api.post("/auth/login/siswa", (req, res) => {
  const { nama, nis } = req.body;
  db.query("SELECT * FROM siswa WHERE LOWER(nama) = LOWER(?) AND nis = ?", [nama, nis], (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length > 0) return res.json({ role: "siswa", user: result[0] });
    res.status(401).json({ error: "Invalid credentials" });
  });
});

api.get("/siswa", (req, res) => {
  db.query("SELECT * FROM siswa", (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

api.get("/siswa/search", (req, res) => {
  const q = `%${req.query.q || ""}%`;
  db.query("SELECT * FROM siswa WHERE nama LIKE ? OR nis LIKE ? OR kelas LIKE ?", [q, q, q], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

// ================= JENIS CATATAN =================
api.get("/jenis_catatan/:tipe", (req, res) => {
  db.query("SELECT * FROM jenis_catatan WHERE tipe = ?", [req.params.tipe], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

api.post("/jenis_catatan", (req, res) => {
  const { nama, deskripsi, tipe, poin } = req.body;
  db.query("INSERT INTO jenis_catatan (nama, deskripsi, tipe, poin) VALUES (?, ?, ?, ?)", [nama, deskripsi, tipe, poin], (err, result) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ success: true, id_jenis: result.insertId });
  });
});

api.put("/jenis_catatan/:id", (req, res) => {
  const { nama, deskripsi, tipe, poin } = req.body;
  db.query("UPDATE jenis_catatan SET nama=?, deskripsi=?, tipe=?, poin=? WHERE id_jenis=?", [nama, deskripsi, tipe, poin, req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

api.delete("/jenis_catatan/:id", (req, res) => {
  db.query("DELETE FROM jenis_catatan WHERE id_jenis=?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

// ================= POINT RECORDS =================
api.get("/point_records/siswa/:nis", (req, res) => {
  db.query("SELECT * FROM point_records WHERE nis_siswa = ? ORDER BY id DESC", [req.params.nis], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

api.get("/point_records/guru/:nama_guru", (req, res) => {
  db.query("SELECT * FROM point_records WHERE nama_guru = ? ORDER BY id DESC", [req.params.nama_guru], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

api.post("/point_records", (req, res) => {
  const data = req.body;
  const sql = "INSERT INTO point_records (id, nama_poin, detail_poin, jenis_poin, poin, nama_guru, nama_siswa, kelas_siswa, nis_siswa, tanggal, jam) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
  const values = [data.id, data.nama_poin, data.detail_poin, data.jenis_poin, data.poin, data.nama_guru, data.nama_siswa, data.kelas_siswa, data.nis_siswa, data.tanggal, data.jam];
  db.query(sql, values, (err, result) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ success: true });
  });
});

api.delete("/point_records/:id", (req, res) => {
  db.query("DELETE FROM point_records WHERE id=?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

// ================= DRAFTS =================
api.get("/drafts", (req, res) => {
  db.query("SELECT * FROM drafts ORDER BY created_at DESC", (err, result) => {
    if (err) return res.status(500).json(err);
    // parse JSON for daftar_siswa
    const data = result.map(r => ({
      ...r,
      daftar_siswa: typeof r.daftar_siswa === 'string' ? JSON.parse(r.daftar_siswa) : r.daftar_siswa
    }));
    res.json(data);
  });
});

api.post("/drafts", (req, res) => {
  const d = req.body;
  const ds = JSON.stringify(d.daftar_siswa || []);
  db.query("INSERT INTO drafts (id, nama_poin, detail_poin, jenis_poin, poin, daftar_siswa, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)", 
  [d.id, d.nama_poin, d.detail_poin, d.jenis_poin, d.poin, ds, d.created_at], (err, result) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ success: true });
  });
});

api.put("/drafts/:id", (req, res) => {
  const d = req.body;
  const ds = JSON.stringify(d.daftar_siswa || []);
  db.query("UPDATE drafts SET nama_poin=?, detail_poin=?, jenis_poin=?, poin=?, daftar_siswa=?, created_at=? WHERE id=?", 
  [d.nama_poin, d.detail_poin, d.jenis_poin, d.poin, ds, d.created_at, req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

api.delete("/drafts/:id", (req, res) => {
  db.query("DELETE FROM drafts WHERE id=?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

// ================= MESSAGES =================
api.get("/messages/:nis", (req, res) => {
  db.query("SELECT * FROM messages WHERE nis_tujuan = ? ORDER BY id DESC", [req.params.nis], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

api.post("/messages", (req, res) => {
  const m = req.body;
  db.query("INSERT INTO messages (id, judul, isi_pesan, pengirim, nis_tujuan, tanggal, jam, catatan, lampiran) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
  [m.id, m.judul, m.isi_pesan, m.pengirim, m.nis_tujuan, m.tanggal, m.jam, m.catatan || null, m.lampiran || null], (err, result) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ success: true });
  });
});

api.delete("/messages/:id", (req, res) => {
  db.query("DELETE FROM messages WHERE id=?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ success: true });
  });
});

// Mendaftarkan prefix /api
app.use("/api", api);

app.listen(3000, () => {
  console.log("Server running on port 3000");
});