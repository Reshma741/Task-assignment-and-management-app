const mongoose = require('mongoose');

const taskAssignmentSchema = new mongoose.Schema({
  taskId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Task',
    required: [true, 'Task ID is required']
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Assigned to user is required']
  },
  assignedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Assigned by user is required']
  },
  approvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending'
  },
  approvedAt: {
    type: Date
  },
  rejectionReason: {
    type: String,
    trim: true,
    maxlength: [500, 'Rejection reason cannot exceed 500 characters']
  },
  notes: {
    type: String,
    trim: true,
    maxlength: [1000, 'Notes cannot exceed 1000 characters']
  }
}, {
  timestamps: true
});

// Virtual for status display text
taskAssignmentSchema.virtual('statusText').get(function() {
  const statusMap = {
    pending: 'Pending Approval',
    approved: 'Approved',
    rejected: 'Rejected'
  };
  return statusMap[this.status] || 'Pending Approval';
});

// Set approvedAt when status changes to approved
taskAssignmentSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'approved' && !this.approvedAt) {
    this.approvedAt = new Date();
  }
  next();
});

// Ensure virtual fields are serialized
taskAssignmentSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('TaskAssignment', taskAssignmentSchema);
