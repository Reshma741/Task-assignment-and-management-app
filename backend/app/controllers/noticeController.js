const Notice = require('../models/Notice');
const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/response');

// Create a new notice
const createNotice = async (req, res) => {
  try {
    const {
      title,
      content,
      type,
      scheduledDate,
      expiryDate,
      targetRoles,
      imageUrl,
      attachments
    } = req.body;

    // Validation
    if (!title || !content) {
      return sendError(res, 'Title and content are required');
    }

    // Check if user can post notices
    if (!req.user.canPostNotices()) {
      return sendError(res, 'Access denied. Insufficient permissions to post notices');
    }

    // Create notice
    const notice = new Notice({
      title,
      content,
      type: type || 'general',
      postedBy: req.user._id,
      scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
      expiryDate: expiryDate ? new Date(expiryDate) : null,
      targetRoles: targetRoles || [],
      imageUrl,
      attachments: attachments || []
    });

    await notice.save();

    // Populate the notice with user details
    await notice.populate('postedBy', 'name email role');

    sendSuccess(res, 'Notice created successfully', notice, 201);
  } catch (error) {
    console.error('Create notice error:', error);
    sendError(res, 'Failed to create notice', 500);
  }
};

// Get all notices
const getAllNotices = async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      type, 
      isActive,
      targetRole 
    } = req.query;

    const filter = {};

    // Apply filters
    if (type) filter.type = type;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    // Filter by target roles if specified
    if (targetRole) {
      filter.$or = [
        { targetRoles: { $in: [targetRole] } },
        { targetRoles: { $size: 0 } } // Include notices with no specific target roles
      ];
    }

    // Filter out expired notices unless specifically requested
    if (isActive === undefined || isActive === 'true') {
      filter.$or = [
        { expiryDate: { $exists: false } },
        { expiryDate: null },
        { expiryDate: { $gt: new Date() } }
      ];
    }

    const notices = await Notice.find(filter)
      .populate('postedBy', 'name email role')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await Notice.countDocuments(filter);

    sendSuccess(res, 'Notices retrieved successfully', {
      notices,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all notices error:', error);
    sendError(res, 'Failed to retrieve notices', 500);
  }
};

// Get notice by ID
const getNoticeById = async (req, res) => {
  try {
    const { noticeId } = req.params;

    const notice = await Notice.findById(noticeId)
      .populate('postedBy', 'name email role');

    if (!notice) {
      return sendError(res, 'Notice not found', 404);
    }

    sendSuccess(res, 'Notice retrieved successfully', notice);
  } catch (error) {
    console.error('Get notice by ID error:', error);
    sendError(res, 'Failed to retrieve notice', 500);
  }
};

// Update notice
const updateNotice = async (req, res) => {
  try {
    const { noticeId } = req.params;
    const {
      title,
      content,
      type,
      scheduledDate,
      expiryDate,
      isActive,
      targetRoles,
      imageUrl,
      attachments
    } = req.body;

    const notice = await Notice.findById(noticeId);
    if (!notice) {
      return sendError(res, 'Notice not found', 404);
    }

    // Check permissions - only the poster or HR/CEO can update
    const canUpdate = req.user.canPostNotices() && 
                     (notice.postedBy.toString() === req.user._id.toString() || 
                      ['hr', 'ceo'].includes(req.user.role));

    if (!canUpdate) {
      return sendError(res, 'Access denied. Insufficient permissions to update this notice');
    }

    // Update fields
    const updateData = {};
    if (title) updateData.title = title;
    if (content) updateData.content = content;
    if (type) updateData.type = type;
    if (scheduledDate) updateData.scheduledDate = new Date(scheduledDate);
    if (expiryDate) updateData.expiryDate = new Date(expiryDate);
    if (isActive !== undefined) updateData.isActive = isActive;
    if (targetRoles) updateData.targetRoles = targetRoles;
    if (imageUrl) updateData.imageUrl = imageUrl;
    if (attachments) updateData.attachments = attachments;

    const updatedNotice = await Notice.findByIdAndUpdate(
      noticeId,
      updateData,
      { new: true, runValidators: true }
    ).populate('postedBy', 'name email role');

    sendSuccess(res, 'Notice updated successfully', updatedNotice);
  } catch (error) {
    console.error('Update notice error:', error);
    sendError(res, 'Failed to update notice', 500);
  }
};

// Delete notice
const deleteNotice = async (req, res) => {
  try {
    const { noticeId } = req.params;

    const notice = await Notice.findById(noticeId);
    if (!notice) {
      return sendError(res, 'Notice not found', 404);
    }

    // Check permissions - only the poster or HR/CEO can delete
    const canDelete = req.user.canPostNotices() && 
                     (notice.postedBy.toString() === req.user._id.toString() || 
                      ['hr', 'ceo'].includes(req.user.role));

    if (!canDelete) {
      return sendError(res, 'Access denied. Insufficient permissions to delete this notice');
    }

    await Notice.findByIdAndDelete(noticeId);

    sendSuccess(res, 'Notice deleted successfully');
  } catch (error) {
    console.error('Delete notice error:', error);
    sendError(res, 'Failed to delete notice', 500);
  }
};

// Get notices for current user's role
const getNoticesForUser = async (req, res) => {
  try {
    const { type, limit = 10 } = req.query;
    const filter = {
      isActive: true,
      $or: [
        { targetRoles: { $in: [req.user.role] } },
        { targetRoles: { $size: 0 } } // Include notices with no specific target roles
      ]
    };

    // Filter out expired notices
    filter.$and = [
      {
        $or: [
          { expiryDate: { $exists: false } },
          { expiryDate: null },
          { expiryDate: { $gt: new Date() } }
        ]
      }
    ];

    if (type) filter.type = type;

    const notices = await Notice.find(filter)
      .populate('postedBy', 'name email role')
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });

    sendSuccess(res, 'User notices retrieved successfully', notices);
  } catch (error) {
    console.error('Get notices for user error:', error);
    sendError(res, 'Failed to retrieve user notices', 500);
  }
};

module.exports = {
  createNotice,
  getAllNotices,
  getNoticeById,
  updateNotice,
  deleteNotice,
  getNoticesForUser
};
