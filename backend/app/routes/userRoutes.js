const express = require('express');
const router = express.Router();
const {
  register,
  login,
  getProfile,
  updateProfile,
  getAllUsers,
  updateUser,
  deleteUser,
  forgotPassword,
  verifyResetCode,
  resetPassword,
  socialLogin
} = require('../controllers/userController');
const { auth, authorize } = require('../middlewares/auth');

// Public routes
router.post('/register', register);
router.post('/login', login);
router.post('/social-login', socialLogin);
router.post('/forgot', forgotPassword);
router.post('/verify-code', verifyResetCode);
router.post('/reset-password', resetPassword);

// Protected routes
router.use(auth); // All routes below require authentication

// User profile routes
router.get('/profile', getProfile);
router.put('/profile', updateProfile);

// Admin routes
router.get('/all', authorize('ceo', 'projectManager'), getAllUsers);
router.put('/:userId', authorize('ceo', 'projectManager'), updateUser);
router.delete('/:userId', authorize('ceo', 'projectManager'), deleteUser);

module.exports = router;
