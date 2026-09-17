import { Request, Response } from "express";
import pool from "../config/db";
// Buat controller untuk artikel dengan operasi CRUD (Create, Read, Update, Delete)
// Gunakan JOIN untuk mengambil nama user dan nama kategori dari tabel users dan categories
const SELECT_POST = `
  SELECT p.id_post, p.title, p.content, p.created_at, p.updated_at,
         p.id_user, u.name_user AS author_name,
         p.id_category, c.name_category AS category_name,
         p.image_url
  FROM posts p
  JOIN users u ON u.id_user = p.id_user
  JOIN categories c ON c.id_category = p.id_category
`;

// GET /api/posts
export async function getAllPosts(req: Request, res: Response) {
  try {
    const [rows] = await pool.query(
      `${SELECT_POST} ORDER BY p.created_at DESC`,
    );
    res.status(200).json({
      status: "success",
      message: "Daftar artikel berhasil diambil",
      data: rows,
    });
  } catch (err: any) {
    res.status(500).json({ status: "error", message: err.message });
  }
}

// GET /api/posts/:id
export async function getPostById(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const [rows]: any = await pool.query(`${SELECT_POST} WHERE p.id_post = ?`, [
      id,
    ]);

    if (rows.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: `Artikel id ${id} tidak ditemukan` });
    }
    res.status(200).json({
      status: "success",
      message: "Detail artikel berhasil diambil",
      data: rows[0],
    });
  } catch (err: any) {
    res.status(500).json({ status: "error", message: err.message });
  }
}

// POST /api/posts (wajib login, id_user diambil dari token)
export async function createPost(req: Request, res: Response) {
  try {
    const { id_category, title, content, image_url } = req.body;
    const id_user = (req as any).user.id_user;
    const uploadedFile = (req as any).file as Express.Multer.File | undefined;
    const finalImageUrl = uploadedFile
      ? `${req.protocol}://${req.get("host")}/uploads/${uploadedFile.filename}`
      : (image_url ?? null);

    if (!id_category || !title || !content) {
      return res.status(422).json({
        status: "error",
        message: "id_category, title, content wajib diisi",
      });
    }

    const [result]: any = await pool.query(
      "INSERT INTO posts (id_user, id_category, title, content, image_url) VALUES (?, ?, ?, ?, ?)",
      [id_user, id_category, title, content, finalImageUrl],
    );

    const [rows]: any = await pool.query(`${SELECT_POST} WHERE p.id_post = ?`, [
      result.insertId,
    ]);
    res.status(201).json({
      status: "success",
      message: "Artikel berhasil dibuat",
      data: rows[0],
    });
  } catch (err: any) {
    res.status(500).json({ status: "error", message: err.message });
  }
}

// PUT /api/posts/:id (wajib login, cuma boleh edit punya sendiri)
export async function updatePost(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { id_category, title, content, image_url } = req.body;
    const id_user = (req as any).user.id_user;
    const uploadedFile = (req as any).file as Express.Multer.File | undefined;

    const [existing]: any = await pool.query(
      "SELECT * FROM posts WHERE id_post = ?",
      [id],
    );
    if (existing.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: `Artikel id ${id} tidak ditemukan` });
    }
    if (existing[0].id_user !== id_user) {
      return res.status(403).json({
        status: "error",
        message: "Kamu tidak berhak mengubah artikel milik user lain",
      });
    }

    const finalImageUrl = uploadedFile
      ? `${req.protocol}://${req.get("host")}/uploads/${uploadedFile.filename}`
      : image_url !== undefined
        ? (image_url || null)
        : existing[0].image_url;

    await pool.query(
      "UPDATE posts SET id_category = ?, title = ?, content = ?, image_url = ? WHERE id_post = ?",
      [id_category, title, content, finalImageUrl, id],
    );

    const [rows]: any = await pool.query(`${SELECT_POST} WHERE p.id_post = ?`, [
      id,
    ]);
    res.status(200).json({
      status: "success",
      message: "Artikel berhasil diperbarui",
      data: rows[0],
    });
  } catch (err: any) {
    res.status(500).json({ status: "error", message: err.message });
  }
}

// DELETE /api/posts/:id (wajib login, cuma boleh hapus punya sendiri)
export async function deletePost(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const id_user = (req as any).user.id_user;

    const [existing]: any = await pool.query(
      "SELECT * FROM posts WHERE id_post = ?",
      [id],
    );
    if (existing.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: `Artikel id ${id} tidak ditemukan` });
    }
    if (existing[0].id_user !== id_user) {
      return res.status(403).json({
        status: "error",
        message: "Kamu tidak berhak menghapus artikel milik user lain",
      });
    }

    await pool.query("DELETE FROM posts WHERE id_post = ?", [id]);
    res
      .status(200)
      .json({ status: "success", message: "Artikel berhasil dihapus" });
  } catch (err: any) {
    res.status(500).json({ status: "error", message: err.message });
  }
}
