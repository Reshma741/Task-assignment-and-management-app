const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters']
  },
  role: {
    type: String,
    enum: ['ceo', 'projectManager', 'hr', 'teamMember'],
    default: 'teamMember'
  },
  avatar: {
    type: String,
    default: null
  },
  isActive: {
    type: Boolean,
    default: true
  },
  department: {
    type: String,
    trim: true
  },
  teamId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Team',
    default: null
  }
}, {
  timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON output
userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  return user;
};

// Role-based permission methods
userSchema.methods.canAssignTasksDirectly = function() {
  return ['ceo', 'projectManager'].includes(this.role);
};

userSchema.methods.canAssignTasksWithApproval = function() {
  return ['hr', 'teamMember'].includes(this.role);
};

userSchema.methods.canPostNotices = function() {
  return ['hr', 'ceo'].includes(this.role);
};

userSchema.methods.canApproveTaskAssignments = function() {
  return ['ceo', 'projectManager'].includes(this.role);
};

userSchema.methods.canViewAllTasks = function() {
  return ['ceo', 'projectManager'].includes(this.role);
};

userSchema.methods.canManageTeams = function() {
  return ['ceo', 'projectManager'].includes(this.role);
};

userSchema.virtual('roleDisplayName').get(function() {
  const roleMap = {
    ceo: 'CEO',
    projectManager: 'Project Manager',
    hr: 'HR',
    teamMember: 'Team Member'
  };
  return roleMap[this.role] || 'Team Member';
});

module.exports = mongoose.model('User', userSchema);
