const express = require('express');
const router = express.Router();
const {
  createTeam,
  getAllTeams,
  getTeamById,
  updateTeam,
  deleteTeam,
  addMemberToTeam,
  removeMemberFromTeam
} = require('../controllers/teamController');
const { auth, authorize } = require('../middlewares/auth');

// All routes require authentication
router.use(auth);

// Team routes
router.post('/', authorize('ceo', 'projectManager'), createTeam);
router.get('/', getAllTeams);
router.get('/:teamId', getTeamById);
router.put('/:teamId', authorize('ceo', 'projectManager'), updateTeam);
router.delete('/:teamId', authorize('ceo', 'projectManager'), deleteTeam);

// Team member management routes
router.post('/:teamId/members', authorize('ceo', 'projectManager'), addMemberToTeam);
router.delete('/:teamId/members/:userId', authorize('ceo', 'projectManager'), removeMemberFromTeam);

module.exports = router;
