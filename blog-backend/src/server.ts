import dotenv from "dotenv";
dotenv.config();
import app from "./app";
import pool from "./config/db";
const DEFAULT_PORT = Number(process.env.PORT) || 3000;

function startServer(port: number) {
  const server = app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
  });
  server.on("error", (error: any) => {
    console.error("Gagal menjalankan server:", error.message);
    process.exit(1);
  });
}

async function start() {
  try {
    const conn = await pool.getConnection();
    console.log("Berhasil terkoneksi ke database:", process.env.DB_NAME);
    conn.release();

    startServer(DEFAULT_PORT);
  } catch (err: any) {
    console.error("Gagal terkoneksi ke database:", err.message);
    process.exit(1);
  }
}
start();