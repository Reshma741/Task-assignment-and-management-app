
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/user.dart';
import '../../../../utils/app_theme.dart';
import 'approval_requests_widget.dart';
import 'notices_widget.dart';
import '../../notices/create_announcement_screen.dart';
import '../../tasks/assign_task_screen.dart';

class RoleBasedDashboard extends StatelessWidget {
  const RoleBasedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        return _RoleDashboardContent(user: user);
      },
    );
  }
}

class _RoleDashboardContent extends StatelessWidget {
  final User user;
  
  const _RoleDashboardContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('role_dashboard_${user.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role-specific welcome message
        _buildRoleWelcome(context, user),
        const SizedBox(height: 24),

        // Role-specific content
        ..._buildRoleSpecificContent(context, user),
      ],
    );
  }

  Widget _buildRoleWelcome(BuildContext context, User user) {
    return Container(
      key: ValueKey('welcome_${user.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRoleIcon(user.role),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.roleDisplayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getRoleDescription(user.role),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoleSpecificContent(BuildContext context, User user) {
    switch (user.role) {
      case UserRole.ceo:
        return [
          const ApprovalRequestsWidget(),
          const SizedBox(height: 24),
          const NoticesWidget(),
        ];
      case UserRole.projectManager:
        return [
          const ApprovalRequestsWidget(),
          const SizedBox(height: 24),
          const NoticesWidget(),
        ];
      case UserRole.hr:
        return [
          const NoticesWidget(),
          const SizedBox(height: 24),
          _buildHRQuickActions(context),
        ];
      case UserRole.teamMember:
        return [
          const NoticesWidget(),
          const SizedBox(height: 24),
          _buildTeamMemberContent(context),
        ];
    }
  }

  Widget _buildHRQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HR Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Post Notice',
                icon: Icons.campaign,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateAnnouncementScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Manage Users',
                icon: Icons.people,
                color: AppTheme.secondaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AssignTaskScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamMemberContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Assign Task',
                icon: Icons.assignment_ind,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AssignTaskScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'View Tasks',
                icon: Icons.assignment_outlined,
                color: AppTheme.secondaryColor,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigate to Tasks tab to view all assignments')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Assignment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can assign tasks to your team members. All assignments require Project Manager approval.',
                        style: TextStyle(
                          color: Colors.blue[600],
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
      ],
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.ceo:
        return Icons.admin_panel_settings;
      case UserRole.projectManager:
        return Icons.manage_accounts;
      case UserRole.hr:
        return Icons.people_alt;
      case UserRole.teamMember:
        return Icons.person;
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.ceo:
        return 'You have full access to assign tasks and approve requests';
      case UserRole.projectManager:
        return 'Manage your team and approve task assignments';
      case UserRole.hr:
        return 'Post notices and manage HR-related tasks';
      case UserRole.teamMember:
        return 'Complete your assigned tasks and collaborate with your team';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
