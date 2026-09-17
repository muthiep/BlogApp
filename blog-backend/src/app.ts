import express from "express";
import cors from "cors";
import postRoutes from "./routes/postRoutes";
import categoryRoutes from "./routes/categoryRoutes";
import userRoutes from "./routes/userRoutes";
import path from "path";

const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

app.get("/", (req, res) => {
  res.json({ status: "success", message: "Blog API is running" });
});

app.use("/api/posts", postRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/users", userRoutes);

// Route tidak ditemukan
app.use((req, res) => {
  res
    .status(404)
    .json({
      status: "error",
      message: `Route ${req.method} ${req.originalUrl} tidak ditemukan`,
    });
});

export default app;
