import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/task.dart';

import 'add_task_screen.dart';

import 'widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  TaskStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    await Future.wait([
      taskProvider.loadTasks(),
      teamProvider.loadUsers(),
    ]);
  }

  List<Task> _getFilteredTasks(TaskStatus status) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    var tasks = taskProvider.getTasksByStatus(status);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) =>
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      tasks = tasks.where((task) => task.priority == _selectedPriority).toList();
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddTaskScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'To Do'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(null),
                _buildTaskList(TaskStatus.todo),
                _buildTaskList(TaskStatus.inProgress),
                _buildTaskList(TaskStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskStatus? status) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Task> tasks;
        if (status == null) {
          tasks = taskProvider.tasks;
        } else {
          tasks = _getFilteredTasks(status);
        }

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == null 
                      ? 'Create your first task to get started'
                      : 'No ${status.toString().split('.').last} tasks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskPriority?>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TaskPriority?>(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...TaskPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toString().split('.').last),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus?>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TaskStatus?>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...TaskStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPriority = null;
                _selectedStatus = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual detail UI
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(task.description),
      ),
    );
  }
}

