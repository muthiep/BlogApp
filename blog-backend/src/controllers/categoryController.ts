import { Request, Response } from 'express';
import pool from '../config/db';
// Buat controller untuk kategori dengan operasi CRUD (Create, Read, Update, Delete)
// GET /api/categories
export async function getAllCategories(req: Request, res: Response) {
  try {
    const [rows] = await pool.query('SELECT * FROM categories ORDER BY id_category ASC');
    res.status(200).json({ status: 'success', message: 'Daftar kategori berhasil diambil', data: rows });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}

// GET /api/categories/:id
export async function getCategoryById(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const [rows]: any = await pool.query('SELECT * FROM categories WHERE id_category = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', message: `Kategori id ${id} tidak ditemukan` });
    }
    res.status(200).json({ status: 'success', message: 'Detail kategori berhasil diambil', data: rows[0] });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}

// POST /api/categories (wajib login)
export async function createCategory(req: Request, res: Response) {
  try {
    const { name_category, description_category } = req.body;

    if (!name_category) {
      return res.status(422).json({ status: 'error', message: 'name_category wajib diisi' });
    }

    const [result]: any = await pool.query(
      'INSERT INTO categories (name_category, description_category) VALUES (?, ?)',
      [name_category, description_category || null]
    );

    res.status(201).json({
      status: 'success',
      message: 'Kategori berhasil dibuat',
      data: { id_category: result.insertId, name_category, description_category },
    });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}

// PUT /api/categories/:id (wajib login)
export async function updateCategory(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { name_category, description_category } = req.body;

    if (!name_category) {
      return res.status(422).json({ status: 'error', message: 'name_category wajib diisi' });
    }

    const [existing]: any = await pool.query('SELECT id_category FROM categories WHERE id_category = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ status: 'error', message: `Kategori id ${id} tidak ditemukan` });
    }

    await pool.query(
      'UPDATE categories SET name_category = ?, description_category = ? WHERE id_category = ?',
      [name_category, description_category || null, id]
    );

    res.status(200).json({ status: 'success', message: 'Kategori berhasil diperbarui', data: { id_category: id, name_category, description_category } });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}

// DELETE /api/categories/:id (wajib login)
export async function deleteCategory(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const [existing]: any = await pool.query('SELECT id_category FROM categories WHERE id_category = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ status: 'error', message: `Kategori id ${id} tidak ditemukan` });
    }

    await pool.query('DELETE FROM categories WHERE id_category = ?', [id]);
    res.status(200).json({ status: 'success', message: 'Kategori berhasil dihapus' });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}
