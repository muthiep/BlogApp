import { Router } from 'express';
import { authMiddleware } from '../middlewares/authMiddleware';
import {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
} from '../controllers/categoryController';

const router = Router();

router.get('/', getAllCategories);
router.get('/:id', getCategoryById);
router.post('/', authMiddleware, createCategory);
router.put('/:id', authMiddleware, updateCategory);
router.delete('/:id', authMiddleware, deleteCategory);

export default router;
