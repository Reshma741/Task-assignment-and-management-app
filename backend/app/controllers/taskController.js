const Task = require('../models/Task');
const User = require('../models/User');
const TaskAssignment = require('../models/TaskAssignment');
const { sendSuccess, sendError } = require('../utils/response');

// Create a new task
const createTask = async (req, res) => {
  try {
    const {
      title,
      description,
      priority,
      assignedTo,
      projectId,
      dueDate,
      tags,
      estimatedHours
    } = req.body;

    // Validation
    if (!title || !description || !assignedTo) {
      return sendError(res, 'Title, description, and assigned user are required');
    }

    // Check if assigned user exists
    const assignedUser = await User.findById(assignedTo);
    if (!assignedUser) {
      return sendError(res, 'Assigned user not found');
    }

    // Create task
    const task = new Task({
      title,
      description,
      priority: priority || 'medium',
      assignedTo,
      assignedBy: req.user._id,
      projectId,
      dueDate: dueDate ? new Date(dueDate) : null,
      tags: tags || [],
      estimatedHours: estimatedHours || 0
    });

    await task.save();

    // Populate the task with user details
    await task.populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' }
    ]);

    sendSuccess(res, 'Task created successfully', task, 201);
  } catch (error) {
    console.error('Create task error:', error);
    sendError(res, 'Failed to create task', 500);
  }
};

// Get all tasks
const getAllTasks = async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status, 
      priority, 
      assignedTo, 
      assignedBy,
      projectId 
    } = req.query;

    const filter = {};

    // Apply filters
    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (assignedTo) filter.assignedTo = assignedTo;
    if (assignedBy) filter.assignedBy = assignedBy;
    if (projectId) filter.projectId = projectId;

    // If user is not CEO or Project Manager, only show their assigned tasks
    if (!req.user.canViewAllTasks()) {
      filter.assignedTo = req.user._id;
    }

    const tasks = await Task.find(filter)
      .populate('assignedTo', 'name email role')
      .populate('assignedBy', 'name email role')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await Task.countDocuments(filter);

    sendSuccess(res, 'Tasks retrieved successfully', {
      tasks,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all tasks error:', error);
    sendError(res, 'Failed to retrieve tasks', 500);
  }
};

// Get task by ID
const getTaskById = async (req, res) => {
  try {
    const { taskId } = req.params;

    const task = await Task.findById(taskId)
      .populate('assignedTo', 'name email role')
      .populate('assignedBy', 'name email role');

    if (!task) {
      return sendError(res, 'Task not found', 404);
    }

    // Check if user can view this task
    if (!req.user.canViewAllTasks() && task.assignedTo._id.toString() !== req.user._id.toString()) {
      return sendError(res, 'Access denied', 403);
    }

    sendSuccess(res, 'Task retrieved successfully', task);
  } catch (error) {
    console.error('Get task by ID error:', error);
    sendError(res, 'Failed to retrieve task', 500);
  }
};

// Update task
const updateTask = async (req, res) => {
  try {
    const { taskId } = req.params;
    const {
      title,
      description,
      status,
      priority,
      assignedTo,
      projectId,
      dueDate,
      tags,
      estimatedHours,
      actualHours
    } = req.body;

    const task = await Task.findById(taskId);
    if (!task) {
      return sendError(res, 'Task not found', 404);
    }

    // Check permissions
    const canEdit = req.user.canViewAllTasks() || 
                   task.assignedTo.toString() === req.user._id.toString() ||
                   task.assignedBy.toString() === req.user._id.toString();

    if (!canEdit) {
      return sendError(res, 'Access denied', 403);
    }

    // Update fields
    const updateData = {};
    if (title) updateData.title = title;
    if (description) updateData.description = description;
    if (status) updateData.status = status;
    if (priority) updateData.priority = priority;
    if (assignedTo) updateData.assignedTo = assignedTo;
    if (projectId) updateData.projectId = projectId;
    if (dueDate) updateData.dueDate = new Date(dueDate);
    if (tags) updateData.tags = tags;
    if (estimatedHours !== undefined) updateData.estimatedHours = estimatedHours;
    if (actualHours !== undefined) updateData.actualHours = actualHours;

    const updatedTask = await Task.findByIdAndUpdate(
      taskId,
      updateData,
      { new: true, runValidators: true }
    ).populate([
      { path: 'assignedTo', select: 'name email role' },
      { path: 'assignedBy', select: 'name email role' }
    ]);

    sendSuccess(res, 'Task updated successfully', updatedTask);
  } catch (error) {
    console.error('Update task error:', error);
    sendError(res, 'Failed to update task', 500);
  }
};

// Delete task
const deleteTask = async (req, res) => {
  try {
    const { taskId } = req.params;

    const task = await Task.findById(taskId);
    if (!task) {
      return sendError(res, 'Task not found', 404);
    }

    // Check permissions - only CEO, Project Manager, or task creator can delete
    const canDelete = req.user.canViewAllTasks() || 
                     task.assignedBy.toString() === req.user._id.toString();

    if (!canDelete) {
      return sendError(res, 'Access denied', 403);
    }

    // Delete related task assignments
    await TaskAssignment.deleteMany({ taskId });

    await Task.findByIdAndDelete(taskId);

    sendSuccess(res, 'Task deleted successfully');
  } catch (error) {
    console.error('Delete task error:', error);
    sendError(res, 'Failed to delete task', 500);
  }
};

// Get user's tasks
const getUserTasks = async (req, res) => {
  try {
    const { userId } = req.params;
    const { status, priority } = req.query;

    // Check if user can view other users' tasks
    if (userId !== req.user._id.toString() && !req.user.canViewAllTasks()) {
      return sendError(res, 'Access denied', 403);
    }

    const filter = { assignedTo: userId };
    if (status) filter.status = status;
    if (priority) filter.priority = priority;

    const tasks = await Task.find(filter)
      .populate('assignedTo', 'name email role')
      .populate('assignedBy', 'name email role')
      .sort({ createdAt: -1 });

    sendSuccess(res, 'User tasks retrieved successfully', tasks);
  } catch (error) {
    console.error('Get user tasks error:', error);
    sendError(res, 'Failed to retrieve user tasks', 500);
  }
};

module.exports = {
  createTask,
  getAllTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getUserTasks
};
