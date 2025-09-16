import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';

import '../../models/team.dart';
import '../../utils/app_theme.dart';
import 'package:task_flow/utils/color_ext.dart';

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedLeader;
  final List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.loadUsers();
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final team = Team(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        leaderId: _selectedLeader!,
        memberIds: _selectedMembers,
        createdAt: DateTime.now(),
      );

      await teamProvider.addTeam(team);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team'),
        actions: [
          TextButton(
            onPressed: _saveTeam,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Team Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  hintText: 'Enter team name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a team name';
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
                  hintText: 'Enter team description',
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
              
              // Team Leader Selection
              Consumer<TeamProvider>(
                builder: (context, teamProvider, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedLeader,
                    decoration: const InputDecoration(
                      labelText: 'Team Leader',
                    ),
                    items: teamProvider.users.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.primaryColor.withOpacitySafe(0.1),
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(user.name),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacitySafe(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.roleDisplayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeader = value;
                        // Remove leader from members if they were selected
                        _selectedMembers.remove(value);
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a team leader';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Team Members Selection
              Consumer<TeamProvider>(
                builder: (context, teamProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Members',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: teamProvider.users
                              .where((user) => user.id != _selectedLeader)
                              .map((user) {
                            final isSelected = _selectedMembers.contains(user.id);
                            return CheckboxListTile(
                              title: Row(
                                children: [
                                    CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppTheme.primaryColor.withOpacitySafe(0.1),
                                    child: Text(
                                      user.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user.name),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacitySafe(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      user.roleDisplayName,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedMembers.add(user.id);
                                  } else {
                                    _selectedMembers.remove(user.id);
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveTeam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}











