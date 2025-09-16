const express = require('express');
const router = express.Router();
const {
  createTask,
  getAllTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getUserTasks
} = require('../controllers/taskController');
const { auth, authorize } = require('../middlewares/auth');

// All routes require authentication
router.use(auth);

// Task routes
router.post('/', createTask);
router.get('/', getAllTasks);
router.get('/:taskId', getTaskById);
router.put('/:taskId', updateTask);
router.delete('/:taskId', deleteTask);

// User-specific task routes
router.get('/user/:userId', getUserTasks);

module.exports = router;
