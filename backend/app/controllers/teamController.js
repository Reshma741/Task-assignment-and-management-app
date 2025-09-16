const Team = require('../models/Team');
const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/response');

// Create a new team
const createTeam = async (req, res) => {
  try {
    const { name, description, leaderId, memberIds } = req.body;

    // Validation
    if (!name || !description || !leaderId) {
      return sendError(res, 'Name, description, and leader are required');
    }

    // Check if leader exists
    const leader = await User.findById(leaderId);
    if (!leader) {
      return sendError(res, 'Team leader not found');
    }

    // Check if user can manage teams
    if (!req.user.canManageTeams()) {
      return sendError(res, 'Access denied. Insufficient permissions to create teams');
    }

    // Create team
    const team = new Team({
      name,
      description,
      leaderId,
      memberIds: memberIds || []
    });

    await team.save();

    // Populate the team with user details
    await team.populate([
      { path: 'leaderId', select: 'name email role' },
      { path: 'memberIds', select: 'name email role' }
    ]);

    sendSuccess(res, 'Team created successfully', team, 201);
  } catch (error) {
    console.error('Create team error:', error);
    sendError(res, 'Failed to create team', 500);
  }
};

// Get all teams
const getAllTeams = async (req, res) => {
  try {
    const { page = 1, limit = 10, isActive } = req.query;
    const filter = {};

    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const teams = await Team.find(filter)
      .populate('leaderId', 'name email role')
      .populate('memberIds', 'name email role')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await Team.countDocuments(filter);

    sendSuccess(res, 'Teams retrieved successfully', {
      teams,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all teams error:', error);
    sendError(res, 'Failed to retrieve teams', 500);
  }
};

// Get team by ID
const getTeamById = async (req, res) => {
  try {
    const { teamId } = req.params;

    const team = await Team.findById(teamId)
      .populate('leaderId', 'name email role')
      .populate('memberIds', 'name email role');

    if (!team) {
      return sendError(res, 'Team not found', 404);
    }

    sendSuccess(res, 'Team retrieved successfully', team);
  } catch (error) {
    console.error('Get team by ID error:', error);
    sendError(res, 'Failed to retrieve team', 500);
  }
};

// Update team
const updateTeam = async (req, res) => {
  try {
    const { teamId } = req.params;
    const { name, description, leaderId, memberIds, isActive } = req.body;

    const team = await Team.findById(teamId);
    if (!team) {
      return sendError(res, 'Team not found', 404);
    }

    // Check permissions
    if (!req.user.canManageTeams()) {
      return sendError(res, 'Access denied. Insufficient permissions to update teams');
    }

    // Update fields
    const updateData = {};
    if (name) updateData.name = name;
    if (description) updateData.description = description;
    if (leaderId) updateData.leaderId = leaderId;
    if (memberIds) updateData.memberIds = memberIds;
    if (isActive !== undefined) updateData.isActive = isActive;

    const updatedTeam = await Team.findByIdAndUpdate(
      teamId,
      updateData,
      { new: true, runValidators: true }
    ).populate([
      { path: 'leaderId', select: 'name email role' },
      { path: 'memberIds', select: 'name email role' }
    ]);

    sendSuccess(res, 'Team updated successfully', updatedTeam);
  } catch (error) {
    console.error('Update team error:', error);
    sendError(res, 'Failed to update team', 500);
  }
};

// Delete team
const deleteTeam = async (req, res) => {
  try {
    const { teamId } = req.params;

    const team = await Team.findById(teamId);
    if (!team) {
      return sendError(res, 'Team not found', 404);
    }

    // Check permissions
    if (!req.user.canManageTeams()) {
      return sendError(res, 'Access denied. Insufficient permissions to delete teams');
    }

    // Remove team reference from users
    await User.updateMany(
      { teamId: teamId },
      { $unset: { teamId: 1 } }
    );

    await Team.findByIdAndDelete(teamId);

    sendSuccess(res, 'Team deleted successfully');
  } catch (error) {
    console.error('Delete team error:', error);
    sendError(res, 'Failed to delete team', 500);
  }
};

// Add member to team
const addMemberToTeam = async (req, res) => {
  try {
    const { teamId } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return sendError(res, 'User ID is required');
    }

    const team = await Team.findById(teamId);
    if (!team) {
      return sendError(res, 'Team not found', 404);
    }

    // Check permissions
    if (!req.user.canManageTeams()) {
      return sendError(res, 'Access denied. Insufficient permissions to manage team members');
    }

    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Check if user is already a member
    if (team.memberIds.includes(userId)) {
      return sendError(res, 'User is already a member of this team');
    }

    // Add member to team
    team.memberIds.push(userId);
    await team.save();

    // Update user's teamId
    user.teamId = teamId;
    await user.save();

    // Populate the updated team
    await team.populate([
      { path: 'leaderId', select: 'name email role' },
      { path: 'memberIds', select: 'name email role' }
    ]);

    sendSuccess(res, 'Member added to team successfully', team);
  } catch (error) {
    console.error('Add member to team error:', error);
    sendError(res, 'Failed to add member to team', 500);
  }
};

// Remove member from team
const removeMemberFromTeam = async (req, res) => {
  try {
    const { teamId, userId } = req.params;

    const team = await Team.findById(teamId);
    if (!team) {
      return sendError(res, 'Team not found', 404);
    }

    // Check permissions
    if (!req.user.canManageTeams()) {
      return sendError(res, 'Access denied. Insufficient permissions to manage team members');
    }

    // Check if user is a member
    if (!team.memberIds.includes(userId)) {
      return sendError(res, 'User is not a member of this team');
    }

    // Remove member from team
    team.memberIds = team.memberIds.filter(id => id.toString() !== userId);
    await team.save();

    // Update user's teamId
    await User.findByIdAndUpdate(userId, { $unset: { teamId: 1 } });

    // Populate the updated team
    await team.populate([
      { path: 'leaderId', select: 'name email role' },
      { path: 'memberIds', select: 'name email role' }
    ]);

    sendSuccess(res, 'Member removed from team successfully', team);
  } catch (error) {
    console.error('Remove member from team error:', error);
    sendError(res, 'Failed to remove member from team', 500);
  }
};

module.exports = {
  createTeam,
  getAllTeams,
  getTeamById,
  updateTeam,
  deleteTeam,
  addMemberToTeam,
  removeMemberFromTeam
};
