import { Router } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { authMiddleware } from "../middlewares/authMiddleware";
import {
  getAllPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
} from "../controllers/postController";

const router = Router();

const uploadDir = path.join(process.cwd(), "uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = path
      .basename(file.originalname, ext)
      .replace(/[^a-zA-Z0-9-_]/g, "-");
    cb(null, `${Date.now()}-${name}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("File harus berupa gambar"));
    }
  },
});

router.get("/", getAllPosts);
router.get("/:id", getPostById);
router.post("/", authMiddleware, upload.single("image"), createPost);
router.put("/:id", authMiddleware, upload.single("image"), updatePost);
router.delete("/:id", authMiddleware, deletePost);


export default router;
