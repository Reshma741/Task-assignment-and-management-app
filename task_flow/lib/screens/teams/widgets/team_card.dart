import 'package:flutter/material.dart';
import 'package:task_flow/utils/color_ext.dart';
import 'package:provider/provider.dart';
import '../../../../providers/team_provider.dart';
import '../../../../models/team.dart';
import '../../../../utils/app_theme.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.team,
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
              // Team Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacitySafe(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          team.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: team.isActive 
                ? AppTheme.secondaryColor.withOpacitySafe(0.1)
                  : Colors.grey.withOpacitySafe(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: team.isActive ? AppTheme.secondaryColor : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Team Members
              Consumer<TeamProvider>(
                builder: (context, teamProvider, child) {
                  final members = teamProvider.getTeamMembers(team.id);
                  final leader = teamProvider.getUserById(team.leaderId);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Team Leader: ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            leader?.name ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Members (${members.length}): ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              children: members.take(3).map((member) {
                                return CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.primaryColor.withOpacitySafe(0.1),
                                  child: Text(
                                    member.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList()
                                ..addAll(
                                  members.length > 3
                                      ? [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.grey.withOpacitySafe(0.1),
                                            child: Text(
                                              '+${members.length - 3}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ]
                                      : [],
                                ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Created Date
              Text(
                'Created ${_formatDate(team.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}
















