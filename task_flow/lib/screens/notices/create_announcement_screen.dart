import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../models/notice.dart';
import '../../utils/app_theme.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  NoticeType _selectedType = NoticeType.announcement;
  DateTime? _scheduledDate;
  DateTime? _expiryDate;
  final List<String> _selectedRoles = [];
  
  final List<String> _availableRoles = [
    'ceo',
    'projectManager', 
    'hr',
    'teamMember',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        actions: [
          TextButton(
            onPressed: _saveAnnouncement,
            child: const Text(
              'Post',
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
              // Notice Type Selection
              Text(
                'Notice Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: NoticeType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getTypeDisplayName(type)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter announcement title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter announcement content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Target Roles
              Text(
                'Target Audience',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _availableRoles.map((role) {
                  return FilterChip(
                    label: Text(_getRoleDisplayName(role)),
                    selected: _selectedRoles.contains(role),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRoles.add(role);
                        } else {
                          _selectedRoles.remove(role);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Schedule Date (Optional)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schedule Date (Optional)'),
                  subtitle: Text(_scheduledDate != null 
                    ? 'Scheduled for ${_formatDate(_scheduledDate!)}'
                    : 'Post immediately'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectScheduledDate,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Expiry Date (Optional)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: const Text('Expiry Date (Optional)'),
                  subtitle: Text(_expiryDate != null 
                    ? 'Expires on ${_formatDate(_expiryDate!)}'
                    : 'No expiry'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectExpiryDate,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Preview Section
              if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty)
                _buildPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(_selectedType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getTypeIcon(_selectedType),
                    color: _getTypeColor(_selectedType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTypeDisplayName(_selectedType),
                    style: TextStyle(
                      color: _getTypeColor(_selectedType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _titleController.text.isEmpty ? 'Title will appear here' : _titleController.text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _contentController.text.isEmpty ? 'Content will appear here' : _contentController.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_selectedRoles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Visible to: ${_selectedRoles.map((role) => _getRoleDisplayName(role)).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(NoticeType type) {
    switch (type) {
      case NoticeType.holiday:
        return 'Holiday';
      case NoticeType.birthday:
        return 'Birthday';
      case NoticeType.announcement:
        return 'Announcement';
      case NoticeType.meeting:
        return 'Meeting';
      case NoticeType.general:
        return 'General';
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'ceo':
        return 'CEO';
      case 'projectManager':
        return 'Project Manager';
      case 'hr':
        return 'HR';
      case 'teamMember':
        return 'Team Member';
      default:
        return role;
    }
  }

  Color _getTypeColor(NoticeType type) {
    switch (type) {
      case NoticeType.holiday:
        return Colors.green;
      case NoticeType.birthday:
        return Colors.pink;
      case NoticeType.announcement:
        return Colors.blue;
      case NoticeType.meeting:
        return Colors.orange;
      case NoticeType.general:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.holiday:
        return Icons.celebration;
      case NoticeType.birthday:
        return Icons.cake;
      case NoticeType.announcement:
        return Icons.campaign;
      case NoticeType.meeting:
        return Icons.meeting_room;
      case NoticeType.general:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    final notice = Notice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      postedBy: authProvider.currentUser?.id ?? '',
      createdAt: DateTime.now(),
      scheduledDate: _scheduledDate,
      expiryDate: _expiryDate,
      targetRoles: _selectedRoles,
    );

    final success = await roleProvider.createNotice(notice);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post announcement')),
        );
      }
    }
  }
}
