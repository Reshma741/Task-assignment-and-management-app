import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/role_provider.dart';

import '../../utils/app_theme.dart';
import '../tasks/task_list_screen.dart';
import '../teams/team_list_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/dashboard_stats_card.dart';
import 'widgets/recent_tasks_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/role_based_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const DashboardHome(),
    const TaskListScreen(),
    const TeamListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isInitialized) return; // Prevent multiple initializations
    
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      final roleProvider = Provider.of<RoleProvider>(context, listen: false);
      
      await Future.wait([
        taskProvider.loadTasks(),
        teamProvider.loadTeams(),
        teamProvider.loadUsers(),
        roleProvider.loadPendingAssignments(),
        roleProvider.loadNotices(),
      ]);
      
      _isInitialized = true;
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final teamProvider = Provider.of<TeamProvider>(context, listen: false);
        await Future.wait([
          taskProvider.loadTasks(),
          teamProvider.loadTeams(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Role-based Dashboard Content
            const RoleBasedDashboard(key: ValueKey('role_dashboard')),

            const SizedBox(height: 24),

            // Quick Actions
            const QuickActionsWidget(),

            const SizedBox(height: 24),

            // Statistics Cards
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: [
                        DashboardStatsCard(
                          title: 'Total Tasks',
                          value: taskProvider.totalTasks.toString(),
                          icon: Icons.assignment,
                          color: AppTheme.primaryColor,
                        ),
                        DashboardStatsCard(
                          title: 'Completed',
                          value: taskProvider.completedTasks.toString(),
                          icon: Icons.check_circle,
                          color: AppTheme.completedColor,
                        ),
                        DashboardStatsCard(
                          title: 'In Progress',
                          value: taskProvider.inProgressTasks.toString(),
                          icon: Icons.hourglass_empty,
                          color: AppTheme.inProgressColor,
                        ),
                        DashboardStatsCard(
                          title: 'Completion Rate',
                          value: '${(taskProvider.completionRate * 100).toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: AppTheme.secondaryColor,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Tasks
            const RecentTasksWidget(),
            ],
          ),
        ),
      );
  }
}

