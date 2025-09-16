const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Task title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  description: {
    type: String,
    required: [true, 'Task description is required'],
    trim: true,
    maxlength: [1000, 'Description cannot exceed 1000 characters']
  },
  status: {
    type: String,
    enum: ['todo', 'inProgress', 'completed', 'cancelled'],
    default: 'todo'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Assigned user is required']
  },
  assignedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Assigned by user is required']
  },
  projectId: {
    type: String,
    trim: true
  },
  dueDate: {
    type: Date
  },
  completedAt: {
    type: Date
  },
  tags: [{
    type: String,
    trim: true
  }],
  attachments: [{
    type: String // File URLs or paths
  }],
  estimatedHours: {
    type: Number,
    default: 0,
    min: [0, 'Estimated hours cannot be negative']
  },
  actualHours: {
    type: Number,
    default: 0,
    min: [0, 'Actual hours cannot be negative']
  }
}, {
  timestamps: true
});

// Virtual for checking if task is overdue
taskSchema.virtual('isOverdue').get(function() {
  if (!this.dueDate || this.status === 'completed') return false;
  return new Date() > this.dueDate;
});

// Virtual for status display text
taskSchema.virtual('statusText').get(function() {
  const statusMap = {
    todo: 'To Do',
    inProgress: 'In Progress',
    completed: 'Completed',
    cancelled: 'Cancelled'
  };
  return statusMap[this.status] || 'To Do';
});

// Virtual for priority display text
taskSchema.virtual('priorityText').get(function() {
  const priorityMap = {
    low: 'Low',
    medium: 'Medium',
    high: 'High',
    urgent: 'Urgent'
  };
  return priorityMap[this.priority] || 'Medium';
});

// Set completedAt when status changes to completed
taskSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'completed' && !this.completedAt) {
    this.completedAt = new Date();
  }
  next();
});

// Ensure virtual fields are serialized
taskSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Task', taskSchema);
