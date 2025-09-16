const mongoose = require('mongoose');

const teamSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Team name is required'],
    trim: true,
    maxlength: [100, 'Team name cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Team description is required'],
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  leaderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Team leader is required']
  },
  memberIds: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Validate that leader is in memberIds
teamSchema.pre('save', function(next) {
  if (this.memberIds && !this.memberIds.includes(this.leaderId)) {
    this.memberIds.push(this.leaderId);
  }
  next();
});

// Virtual for member count
teamSchema.virtual('memberCount').get(function() {
  return this.memberIds ? this.memberIds.length : 0;
});

// Ensure virtual fields are serialized
teamSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Team', teamSchema);
