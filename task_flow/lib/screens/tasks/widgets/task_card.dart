import 'package:flutter/material.dart';
import 'package:task_flow/utils/color_ext.dart';
import 'package:provider/provider.dart';
import '../../../../providers/team_provider.dart';
import '../../../../models/task.dart';
import '../../../../utils/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and priority
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: task.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.priorityColor.withOpacitySafe(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.priorityText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: task.priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer with assignee and due date
              Row(
                children: [
                  // Assignee
                  Consumer<TeamProvider>(
                    builder: (context, teamProvider, child) {
                      final assignee = teamProvider.getUserById(task.assignedTo);
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primaryColor.withOpacitySafe(0.1),
                            child: Text(
                              assignee?.name.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            assignee?.name ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Due date
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: task.isOverdue ? AppTheme.errorColor : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: task.isOverdue ? AppTheme.errorColor : Colors.grey,
                        fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Progress bar for in-progress tasks
              if (task.status == TaskStatus.inProgress && task.estimatedHours > 0) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${task.actualHours}/${task.estimatedHours}h',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: task.actualHours / task.estimatedHours,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(task.statusColor),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return '${difference}d left';
    } else {
      return '${-difference}d ago';
    }
  }
}

