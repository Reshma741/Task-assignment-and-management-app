const User = require('../models/User');
const { generateToken, generateRefreshToken } = require('../utils/jwt');
const { sendSuccess, sendError } = require('../utils/response');
const validator = require('validator');
const PasswordReset = require('../models/PasswordReset');
const { generateSixDigitCode } = require('../utils/code');
const { sendResetCodeEmail } = require('../utils/email');

// Register a new user
const register = async (req, res) => {
  try {
    const { name, email, password, role, department } = req.body;

    // Validation
    if (!name || !email || !password) {
      return sendError(res, 'Name, email, and password are required');
    }

    if (!validator.isEmail(email)) {
      return sendError(res, 'Please provide a valid email address');
    }

    if (password.length < 6) {
      return sendError(res, 'Password must be at least 6 characters long');
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return sendError(res, 'User with this email already exists');
    }

    // Create new user
    const user = new User({
      name,
      email,
      password,
      role: role || 'teamMember',
      department
    });

    await user.save();

    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    sendSuccess(res, 'User registered successfully', {
      user,
      token,
      refreshToken
    }, 201);
  } catch (error) {
    console.error('Registration error:', error);
    sendError(res, 'Registration failed', 500);
  }
};

// Login user
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return sendError(res, 'Email and password are required');
    }

    // Find user and include password for comparison
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return sendError(res, 'Invalid email or password');
    }

    // Check if user is active
    if (!user.isActive) {
      return sendError(res, 'Account is deactivated');
    }

    // Compare password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return sendError(res, 'Invalid email or password');
    }

    // Generate tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    sendSuccess(res, 'Login successful', {
      user,
      token,
      refreshToken
    });
  } catch (error) {
    console.error('Login error:', error);
    sendError(res, 'Login failed', 500);
  }
};

// Get current user profile
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('teamId', 'name');
    sendSuccess(res, 'Profile retrieved successfully', user);
  } catch (error) {
    console.error('Get profile error:', error);
    sendError(res, 'Failed to retrieve profile', 500);
  }
};

// Update user profile
const updateProfile = async (req, res) => {
  try {
    const { name, department, avatar } = req.body;
    const updateData = {};

    if (name) updateData.name = name;
    if (department) updateData.department = department;
    if (avatar) updateData.avatar = avatar;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    sendSuccess(res, 'Profile updated successfully', user);
  } catch (error) {
    console.error('Update profile error:', error);
    sendError(res, 'Failed to update profile', 500);
  }
};

// Get all users (admin only)
const getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, role, isActive } = req.query;
    const filter = {};

    if (role) filter.role = role;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const users = await User.find(filter)
      .populate('teamId', 'name')
      .select('-password')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await User.countDocuments(filter);

    sendSuccess(res, 'Users retrieved successfully', {
      users,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all users error:', error);
    sendError(res, 'Failed to retrieve users', 500);
  }
};

// Update user (admin only)
const updateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, email, role, department, isActive, teamId } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (role) updateData.role = role;
    if (department) updateData.department = department;
    if (isActive !== undefined) updateData.isActive = isActive;
    if (teamId) updateData.teamId = teamId;

    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, runValidators: true }
    ).populate('teamId', 'name');

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    sendSuccess(res, 'User updated successfully', user);
  } catch (error) {
    console.error('Update user error:', error);
    sendError(res, 'Failed to update user', 500);
  }
};

// Delete user (admin only)
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    sendSuccess(res, 'User deleted successfully');
  } catch (error) {
    console.error('Delete user error:', error);
    sendError(res, 'Failed to delete user', 500);
  }
};

module.exports = {
  register,
  login,
  socialLogin: async (req, res) => {
    try {
      const { provider, token, email, name, avatar } = req.body;
      if (!provider || !email) {
        return sendError(res, 'Provider and email are required');
      }

      // In real implementation, verify provider token here.
      // For now, trust input and upsert user by email.
      let user = await User.findOne({ email });
      if (!user) {
        user = new User({
          name: name || email.split('@')[0],
          email,
          password: Math.random().toString(36).slice(2),
          role: 'teamMember',
          avatar
        });
        await user.save();
      }

      const jwt = generateToken(user._id);
      const refreshToken = generateRefreshToken(user._id);

      return sendSuccess(res, 'Social login successful', { user, token: jwt, refreshToken });
    } catch (error) {
      console.error('Social login error:', error);
      return sendError(res, 'Social login failed', 500);
    }
  },
  getProfile,
  updateProfile,
  getAllUsers,
  updateUser,
  deleteUser,
  // added below
  forgotPassword: async (req, res) => {
    try {
      const { email } = req.body;
      if (!email || !validator.isEmail(email)) {
        return sendError(res, 'Valid email is required');
      }

      const user = await User.findOne({ email });
      if (!user) {
        return sendError(res, 'No account found with this email', 404);
      }

      const code = generateSixDigitCode();
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

      await PasswordReset.deleteMany({ email });
      const record = await PasswordReset.create({ email, userId: user._id, code, expiresAt });

      const frontendBase = process.env.FRONTEND_URL || 'http://localhost:3000';
      // Build link compatible with Flutter web hash routing
      const pathWithQuery = `/reset?token=${encodeURIComponent(record._id.toString())}&email=${encodeURIComponent(email)}`;
      const link = frontendBase.includes('#')
        ? `${frontendBase}${pathWithQuery}`
        : `${frontendBase}#${pathWithQuery}`;

      // Send email (link only; no code in body)
      try {
        await sendResetCodeEmail(email, null, link);
      } catch (e) {
        console.warn('Email send failed (dev fallback):', e.message);
      }

      return sendSuccess(res, 'Password reset link sent to email');
    } catch (error) {
      console.error('Forgot password error:', error);
      return sendError(res, 'Failed to initiate password reset', 500);
    }
  },

  verifyResetCode: async (req, res) => {
    try {
      const { email, code } = req.body;
      if (!email || !code) return sendError(res, 'Email and code are required');

      const record = await PasswordReset.findOne({ email, code, used: false });
      if (!record || record.isExpired()) {
        return sendError(res, 'Invalid or expired code');
      }

      return sendSuccess(res, 'Code verified');
    } catch (error) {
      console.error('Verify code error:', error);
      return sendError(res, 'Failed to verify code', 500);
    }
  },

  resetPassword: async (req, res) => {
    try {
      const { email, code, token, newPassword } = req.body;
      if (!newPassword) {
        return sendError(res, 'New password is required');
      }
      if (newPassword.length < 6) {
        return sendError(res, 'Password must be at least 6 characters');
      }

      let record;
      if (token) {
        record = await PasswordReset.findOne({ _id: token, email, used: false });
      } else if (email && code) {
        record = await PasswordReset.findOne({ email, code, used: false });
      } else {
        return sendError(res, 'Provide either token, or email and code');
      }
      if (!record || record.isExpired()) {
        return sendError(res, 'Invalid or expired code');
      }

      const user = await User.findOne({ _id: record.userId, email });
      if (!user) return sendError(res, 'User not found', 404);

      user.password = newPassword; // will be hashed by pre-save hook
      await user.save();

      record.used = true;
      await record.save();

      return sendSuccess(res, 'Password reset successful');
    } catch (error) {
      console.error('Reset password error:', error);
      return sendError(res, 'Failed to reset password', 500);
    }
  }
};
