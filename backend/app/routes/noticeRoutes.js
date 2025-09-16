const express = require('express');
const router = express.Router();
const {
  createNotice,
  getAllNotices,
  getNoticeById,
  updateNotice,
  deleteNotice,
  getNoticesForUser
} = require('../controllers/noticeController');
const { auth, authorize } = require('../middlewares/auth');

// All routes require authentication
router.use(auth);

// Notice routes
router.post('/', authorize('ceo', 'hr'), createNotice);
router.get('/', getAllNotices);
router.get('/user', getNoticesForUser);
router.get('/:noticeId', getNoticeById);
router.put('/:noticeId', updateNotice);
router.delete('/:noticeId', deleteNotice);

module.exports = router;
