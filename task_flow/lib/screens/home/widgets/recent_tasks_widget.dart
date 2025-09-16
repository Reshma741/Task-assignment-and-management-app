import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/utils/color_ext.dart';
import '../../../../providers/task_provider.dart';
import '../../../../models/task.dart';
import '../../../../utils/app_theme.dart';
// import '../../../tasks/task_detail_screen.dart'; // TODO: Create this screen


class RecentTasksWidget extends StatelessWidget {
  const RecentTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to task list - this will be handled by the parent dashboard
                // For now, we'll just show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to Tasks tab to view all tasks')),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final recentTasks = taskProvider.tasks.take(5).toList();

            if (recentTasks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first task to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: recentTasks.map((task) => _TaskListItem(task: task)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
  child: ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          // TODO: Navigate to task detail screen when created
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task: ${task.title}')),
          );
        },
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: task.statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
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
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    task.statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: task.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: task.dueDate != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: task.isOverdue ? AppTheme.errorColor : Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      _formatDate(task.dueDate!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: task.isOverdue ? AppTheme.errorColor : Colors.grey,
                      ),
                    ),
                  ),
                ],
              )
            : null,
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
