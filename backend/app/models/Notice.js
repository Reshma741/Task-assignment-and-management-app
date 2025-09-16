const mongoose = require('mongoose');

const noticeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Notice title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  content: {
    type: String,
    required: [true, 'Notice content is required'],
    trim: true,
    maxlength: [2000, 'Content cannot exceed 2000 characters']
  },
  type: {
    type: String,
    enum: ['holiday', 'birthday', 'announcement', 'meeting', 'general'],
    default: 'general'
  },
  postedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Posted by user is required']
  },
  scheduledDate: {
    type: Date
  },
  expiryDate: {
    type: Date
  },
  isActive: {
    type: Boolean,
    default: true
  },
  targetRoles: [{
    type: String,
    enum: ['ceo', 'projectManager', 'hr', 'teamMember']
  }],
  imageUrl: {
    type: String
  },
  attachments: [{
    type: String // File URLs or paths
  }]
}, {
  timestamps: true
});

// Virtual for checking if notice is expired
noticeSchema.virtual('isExpired').get(function() {
  if (!this.expiryDate) return false;
  return new Date() > this.expiryDate;
});

// Virtual for checking if notice is scheduled
noticeSchema.virtual('isScheduled').get(function() {
  if (!this.scheduledDate) return false;
  return new Date() < this.scheduledDate;
});

// Virtual for type display name
noticeSchema.virtual('typeDisplayName').get(function() {
  const typeMap = {
    holiday: 'Holiday',
    birthday: 'Birthday',
    announcement: 'Announcement',
    meeting: 'Meeting',
    general: 'General'
  };
  return typeMap[this.type] || 'General';
});

// Ensure virtual fields are serialized
noticeSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Notice', noticeSchema);
