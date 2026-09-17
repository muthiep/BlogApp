import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db';

const JWT_SECRET = process.env.JWT_SECRET || 'rahasia';

// Daftar akun baru
export async function register(req: Request, res: Response) {
  try {
    const { name_user, email, password_user } = req.body;

    if (!name_user || !email || !password_user) {
      return res.status(422).json({ status: 'error', message: 'Semua field wajib diisi' });
    }

    const hashedPassword = await bcrypt.hash(password_user, 10);

    const [result]: any = await pool.query(
      'INSERT INTO users (name_user, email, password_user) VALUES (?, ?, ?)',
      [name_user, email, hashedPassword]
    );

    res.status(201).json({
      status: 'success',
      message: 'Registrasi berhasil',
      data: { id_user: result.insertId, name_user, email },
    });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}

// Login, dapat token
export async function login(req: Request, res: Response) {
  try {
    const { email, password_user } = req.body;

    const [rows]: any = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(401).json({ status: 'error', message: 'Email atau password salah' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password_user, user.password_user);
    if (!isMatch) {
      return res.status(401).json({ status: 'error', message: 'Email atau password salah' });
    }

    const token = jwt.sign({ id_user: user.id_user, email: user.email }, JWT_SECRET, {
      expiresIn: '7d',
    });

    res.status(200).json({
      status: 'success',
      message: 'Login berhasil',
      data: { token, user: { id_user: user.id_user, name_user: user.name_user, email: user.email } },
    });
  } catch (err: any) {
    res.status(500).json({ status: 'error', message: err.message });
  }
}
