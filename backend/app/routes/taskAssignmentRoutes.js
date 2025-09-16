const express = require('express');
const router = express.Router();
const {
  createTaskAssignment,
  getAllTaskAssignments,
  getTaskAssignmentById,
  approveTaskAssignment,
  rejectTaskAssignment,
  updateTaskAssignment,
  deleteTaskAssignment
} = require('../controllers/taskAssignmentController');
const { auth, authorize } = require('../middlewares/auth');

// All routes require authentication
router.use(auth);

// Task assignment routes
router.post('/', createTaskAssignment);
router.get('/', getAllTaskAssignments);
router.get('/:assignmentId', getTaskAssignmentById);
router.put('/:assignmentId', updateTaskAssignment);
router.delete('/:assignmentId', deleteTaskAssignment);

// Approval routes (CEO and Project Manager only)
router.put('/:assignmentId/approve', authorize('ceo', 'projectManager'), approveTaskAssignment);
router.put('/:assignmentId/reject', authorize('ceo', 'projectManager'), rejectTaskAssignment);

module.exports = router;
