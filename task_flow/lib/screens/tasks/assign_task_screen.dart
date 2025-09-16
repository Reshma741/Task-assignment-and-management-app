import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../models/task_assignment.dart';
import '../../utils/app_theme.dart';

class AssignTaskScreen extends StatefulWidget {
  final Task? existingTask;
  
  const AssignTaskScreen({super.key, this.existingTask});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _selectedAssigneeId;
  int _estimatedHours = 1;
  
  List<User> _availableUsers = [];
  bool _needsApproval = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descriptionController.text = widget.existingTask!.description;
      _selectedPriority = widget.existingTask!.priority;
      _dueDate = widget.existingTask!.dueDate;
      _selectedAssigneeId = widget.existingTask!.assignedTo;
      _estimatedHours = widget.existingTask!.estimatedHours;
    }
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await teamProvider.loadUsers();
    
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;
    
    setState(() {
      _availableUsers = teamProvider.users.where((user) {
        // Filter users based on current user's role and permissions
        if (currentUser.role == UserRole.ceo) {
          return true; // CEO can assign to anyone
        } else if (currentUser.role == UserRole.projectManager) {
          return true; // PM can assign to team members
        } else if (currentUser.role == UserRole.hr) {
          return true; // HR can assign but needs CEO approval
        } else if (currentUser.role == UserRole.teamMember) {
          // Team members can only assign to peers in same team
          return user.teamId == currentUser.teamId && user.id != currentUser.id;
        }
        return false;
      }).toList();
      
      // Check if assignment needs approval
      _needsApproval = _checkIfNeedsApproval(currentUser);
    });
  }

  bool _checkIfNeedsApproval(User currentUser) {
    if (currentUser.role == UserRole.ceo || currentUser.role == UserRole.projectManager) {
      return false; // No approval needed
    } else if (currentUser.role == UserRole.hr) {
      return true; // Needs CEO approval
    } else if (currentUser.role == UserRole.teamMember) {
      return true; // Needs PM approval
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask != null ? 'Reassign Task' : 'Assign Task'),
        actions: [
          TextButton(
            onPressed: _assignTask,
            child: const Text(
              'Assign',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Approval Notice
              if (_needsApproval)
                Card(
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Approval Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getApprovalMessage(),
                                style: TextStyle(
                                  color: Colors.orange[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Priority Selection
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((priority) {
                  return ChoiceChip(
                    label: Text(_getPriorityText(priority)),
                    selected: _selectedPriority == priority,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    },
                    selectedColor: _getPriorityColor(priority).withValues(alpha: 0.2),
                    checkmarkColor: _getPriorityColor(priority),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Assignee Selection
              Text(
                'Assign To',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedAssigneeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select assignee',
                ),
                items: _availableUsers.map((user) {
                  return DropdownMenuItem(
                    value: user.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                user.roleDisplayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssigneeId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an assignee';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Due Date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due Date'),
                  subtitle: Text(_dueDate != null 
                    ? _formatDate(_dueDate!)
                    : 'No due date set'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _selectDueDate,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Estimated Hours
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Hours',
                  border: OutlineInputBorder(),
                  suffixText: 'hours',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _estimatedHours = int.tryParse(value) ?? 1;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated hours';
                  }
                  final hours = int.tryParse(value);
                  if (hours == null || hours <= 0) {
                    return 'Please enter a valid number of hours';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Assignment Summary
              if (_selectedAssigneeId != null)
                _buildAssignmentSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentSummary() {
    final assignee = _availableUsers.firstWhere(
      (user) => user.id == _selectedAssigneeId,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    assignee.name[0].toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignee.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        assignee.roleDisplayName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: _getPriorityColor(_selectedPriority),
                ),
                const SizedBox(width: 8),
                Text(
                  'Priority: ${_getPriorityText(_selectedPriority)}',
                  style: TextStyle(
                    color: _getPriorityColor(_selectedPriority),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${_formatDate(_dueDate!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (_needsApproval) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 16,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requires approval',
                    style: TextStyle(
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getApprovalMessage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser?.role == UserRole.hr) {
      return 'This task assignment will be sent to CEO for approval.';
    } else if (currentUser?.role == UserRole.teamMember) {
      return 'This task assignment will be sent to Project Manager for approval.';
    }
    return 'This task assignment requires approval.';
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _assignTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final task = Task(
      id: widget.existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: TaskStatus.todo,
      priority: _selectedPriority,
      assignedTo: _selectedAssigneeId!,
      assignedBy: currentUser.id,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      dueDate: _dueDate,
      estimatedHours: _estimatedHours,
    );

    if (_needsApproval) {
      // Create task assignment request
      final assignment = TaskAssignment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: task.id,
        assignedTo: _selectedAssigneeId!,
        assignedBy: currentUser.id,
        status: AssignmentStatus.pending,
        createdAt: DateTime.now(),
        notes: 'Task assignment request',
      );

      // Add to pending assignments (in a real app, this would be sent to backend)
      // For now, we'll just show the success message
      debugPrint('Assignment request created: ${assignment.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task assignment request sent for approval'),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      // Direct assignment
      if (widget.existingTask != null) {
        await taskProvider.updateTask(task);
      } else {
        await taskProvider.addTask(task);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task assigned successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
