const TaskAssignment = require('../models/TaskAssignment');
const Task = require('../models/Task');
const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/response');

// Create a task assignment request
const createTaskAssignment = async (req, res) => {
  try {
    const { taskId, assignedTo, notes } = req.body;

    // Validation
    if (!taskId || !assignedTo) {
      return sendError(res, 'Task ID and assigned user are required');
    }

    // Check if task exists
    const task = await Task.findById(taskId);
    if (!task) {
      return sendError(res, 'Task not found', 404);
    }

    // Check if assigned user exists
    const assignedUser = await User.findById(assignedTo);
    if (!assignedUser) {
      return sendError(res, 'Assigned user not found', 404);
    }

    // Check if assignment already exists
    const existingAssignment = await TaskAssignment.findOne({
      taskId,
      assignedTo,
      status: { $in: ['pending', 'approved'] }
    });

    if (existingAssignment) {
      return sendError(res, 'Task assignment already exists for this user');
    }

    // Create task assignment
    const taskAssignment = new TaskAssignment({
      taskId,
      assignedTo,
      assignedBy: req.user._id,
      notes
    });

    await taskAssignment.save();

    // Populate the assignment with user details
    await taskAssignment.populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' },
      { path: 'taskId', select: 'title description status priority' }
    ]);

    sendSuccess(res, 'Task assignment request created successfully', taskAssignment, 201);
  } catch (error) {
    console.error('Create task assignment error:', error);
    sendError(res, 'Failed to create task assignment', 500);
  }
};

// Get all task assignments
const getAllTaskAssignments = async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status, 
      assignedTo, 
      assignedBy 
    } = req.query;

    const filter = {};

    // Apply filters
    if (status) filter.status = status;
    if (assignedTo) filter.assignedTo = assignedTo;
    if (assignedBy) filter.assignedBy = assignedBy;

    // If user is not CEO or Project Manager, only show their assignments
    if (!req.user.canApproveTaskAssignments()) {
      filter.$or = [
        { assignedTo: req.user._id },
        { assignedBy: req.user._id }
      ];
    }

    const assignments = await TaskAssignment.find(filter)
      .populate('assignedTo', 'name email role')
      .populate('assignedBy', 'name email role')
      .populate('approvedBy', 'name email role')
      .populate('taskId', 'title description status priority')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await TaskAssignment.countDocuments(filter);

    sendSuccess(res, 'Task assignments retrieved successfully', {
      assignments,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all task assignments error:', error);
    sendError(res, 'Failed to retrieve task assignments', 500);
  }
};

// Get task assignment by ID
const getTaskAssignmentById = async (req, res) => {
  try {
    const { assignmentId } = req.params;

    const assignment = await TaskAssignment.findById(assignmentId)
      .populate('assignedTo', 'name email role')
      .populate('assignedBy', 'name email role')
      .populate('approvedBy', 'name email role')
      .populate('taskId', 'title description status priority');

    if (!assignment) {
      return sendError(res, 'Task assignment not found', 404);
    }

    // Check if user can view this assignment
    const canView = req.user.canApproveTaskAssignments() ||
                   assignment.assignedTo._id.toString() === req.user._id.toString() ||
                   assignment.assignedBy._id.toString() === req.user._id.toString();

    if (!canView) {
      return sendError(res, 'Access denied', 403);
    }

    sendSuccess(res, 'Task assignment retrieved successfully', assignment);
  } catch (error) {
    console.error('Get task assignment by ID error:', error);
    sendError(res, 'Failed to retrieve task assignment', 500);
  }
};

// Approve task assignment
const approveTaskAssignment = async (req, res) => {
  try {
    const { assignmentId } = req.params;
    const { notes } = req.body;

    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return sendError(res, 'Task assignment not found', 404);
    }

    // Check permissions
    if (!req.user.canApproveTaskAssignments()) {
      return sendError(res, 'Access denied. Insufficient permissions to approve task assignments');
    }

    // Check if already processed
    if (assignment.status !== 'pending') {
      return sendError(res, 'Task assignment has already been processed');
    }

    // Update assignment
    assignment.status = 'approved';
    assignment.approvedBy = req.user._id;
    assignment.approvedAt = new Date();
    if (notes) assignment.notes = notes;

    await assignment.save();

    // Update the task's assignedTo field
    await Task.findByIdAndUpdate(assignment.taskId, {
      assignedTo: assignment.assignedTo
    });

    // Populate the updated assignment
    await assignment.populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' },
      { path: 'approvedBy', select: 'name email role' },
      { path: 'taskId', select: 'title description status priority' }
    ]);

    sendSuccess(res, 'Task assignment approved successfully', assignment);
  } catch (error) {
    console.error('Approve task assignment error:', error);
    sendError(res, 'Failed to approve task assignment', 500);
  }
};

// Reject task assignment
const rejectTaskAssignment = async (req, res) => {
  try {
    const { assignmentId } = req.params;
    const { rejectionReason, notes } = req.body;

    if (!rejectionReason) {
      return sendError(res, 'Rejection reason is required');
    }

    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return sendError(res, 'Task assignment not found', 404);
    }

    // Check permissions
    if (!req.user.canApproveTaskAssignments()) {
      return sendError(res, 'Access denied. Insufficient permissions to reject task assignments');
    }

    // Check if already processed
    if (assignment.status !== 'pending') {
      return sendError(res, 'Task assignment has already been processed');
    }

    // Update assignment
    assignment.status = 'rejected';
    assignment.approvedBy = req.user._id;
    assignment.approvedAt = new Date();
    assignment.rejectionReason = rejectionReason;
    if (notes) assignment.notes = notes;

    await assignment.save();

    // Populate the updated assignment
    await assignment.populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' },
      { path: 'approvedBy', select: 'name email role' },
      { path: 'taskId', select: 'title description status priority' }
    ]);

    sendSuccess(res, 'Task assignment rejected successfully', assignment);
  } catch (error) {
    console.error('Reject task assignment error:', error);
    sendError(res, 'Failed to reject task assignment', 500);
  }
};

// Update task assignment
const updateTaskAssignment = async (req, res) => {
  try {
    const { assignmentId } = req.params;
    const { notes } = req.body;

    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return sendError(res, 'Task assignment not found', 404);
    }

    // Check permissions - only the assigner or approver can update
    const canUpdate = assignment.assignedBy.toString() === req.user._id.toString() ||
                     req.user.canApproveTaskAssignments();

    if (!canUpdate) {
      return sendError(res, 'Access denied. Insufficient permissions to update this assignment');
    }

    // Only allow updates to pending assignments
    if (assignment.status !== 'pending') {
      return sendError(res, 'Cannot update processed task assignments');
    }

    // Update fields
    if (notes) assignment.notes = notes;

    await assignment.save();

    // Populate the updated assignment
    await assignment.populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' },
      { path: 'approvedBy', select: 'name email role' },
      { path: 'taskId', select: 'title description status priority' }
    ]);

    sendSuccess(res, 'Task assignment updated successfully', assignment);
  } catch (error) {
    console.error('Update task assignment error:', error);
    sendError(res, 'Failed to update task assignment', 500);
  }
};

// Delete task assignment
const deleteTaskAssignment = async (req, res) => {
  try {
    const { assignmentId } = req.params;

    const assignment = await TaskAssignment.findById(assignmentId);
    if (!assignment) {
      return sendError(res, 'Task assignment not found', 404);
    }

    // Check permissions - only the assigner or approver can delete
    const canDelete = assignment.assignedBy.toString() === req.user._id.toString() ||
                     req.user.canApproveTaskAssignments();

    if (!canDelete) {
      return sendError(res, 'Access denied. Insufficient permissions to delete this assignment');
    }

    // Only allow deletion of pending assignments
    if (assignment.status !== 'pending') {
      return sendError(res, 'Cannot delete processed task assignments');
    }

    await TaskAssignment.findByIdAndDelete(assignmentId);

    sendSuccess(res, 'Task assignment deleted successfully');
  } catch (error) {
    console.error('Delete task assignment error:', error);
    sendError(res, 'Failed to delete task assignment', 500);
  }
};

module.exports = {
  createTaskAssignment,
  getAllTaskAssignments,
  getTaskAssignmentById,
  approveTaskAssignment,
  rejectTaskAssignment,
  updateTaskAssignment,
  deleteTaskAssignment
};
