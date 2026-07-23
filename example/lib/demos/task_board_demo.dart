import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

/// Cross-tree demo: drag team members from the sidebar onto tasks in the
/// backlog to assign them.
///
/// The sidebar (drag source) and the task list (scroll target) live in
/// separate widget subtrees, so they share an explicit
/// [DragAutoScrollController].
class TaskBoardDemo extends StatefulWidget {
  const TaskBoardDemo({super.key});

  @override
  State<TaskBoardDemo> createState() => _TaskBoardDemoState();
}

class _TeamMember {
  const _TeamMember(this.name, this.role, this.color);

  final String name;
  final String role;
  final MaterialColor color;

  String get initials => name.split(' ').map((part) => part[0]).take(2).join();
}

const _team = [
  _TeamMember('Ava Richter', 'Product Design', Colors.purple),
  _TeamMember('Jonas Weber', 'Frontend', Colors.blue),
  _TeamMember('Mira Chen', 'Backend', Colors.teal),
  _TeamMember('Leo Martins', 'QA Engineering', Colors.orange),
  _TeamMember('Sofia Ionescu', 'Mobile', Colors.pink),
  _TeamMember('Tom Becker', 'DevOps', Colors.indigo),
];

class _TaskTag {
  const _TaskTag(this.label, this.color);

  final String label;
  final MaterialColor color;
}

const _tagDesign = _TaskTag('Design', Colors.purple);
const _tagFrontend = _TaskTag('Frontend', Colors.blue);
const _tagBackend = _TaskTag('Backend', Colors.teal);
const _tagQa = _TaskTag('QA', Colors.orange);
const _tagMobile = _TaskTag('Mobile', Colors.pink);
const _tagInfra = _TaskTag('Infra', Colors.brown);

class _Task {
  _Task(this.code, this.title, this.tag, this.points);

  final String code;
  final String title;
  final _TaskTag tag;
  final int points;
  _TeamMember? assignee;
}

List<_Task> _buildBacklog() => [
  _Task('APP-141', 'Redesign onboarding flow', _tagDesign, 5),
  _Task('APP-142', 'Fix token refresh race condition', _tagBackend, 3),
  _Task('APP-143', 'Add dark mode to settings screen', _tagFrontend, 2),
  _Task('APP-144', 'Migrate image cache to disk store', _tagMobile, 5),
  _Task('APP-145', 'Regression suite for checkout', _tagQa, 3),
  _Task('APP-146', 'Blue-green deploy pipeline', _tagInfra, 8),
  _Task('APP-147', 'Empty states for search results', _tagDesign, 2),
  _Task('APP-148', 'Paginate activity feed API', _tagBackend, 3),
  _Task('APP-149', 'Keyboard navigation for data table', _tagFrontend, 5),
  _Task('APP-150', 'Offline draft sync', _tagMobile, 8),
  _Task('APP-151', 'Load test invoice service', _tagQa, 3),
  _Task('APP-152', 'Rotate staging TLS certificates', _tagInfra, 1),
  _Task('APP-153', 'Icon set refresh for v3', _tagDesign, 3),
  _Task('APP-154', 'Webhook retry with backoff', _tagBackend, 5),
  _Task('APP-155', 'Drag & drop file upload widget', _tagFrontend, 5),
  _Task('APP-156', 'Push notification deep links', _tagMobile, 3),
  _Task('APP-157', 'Flaky test triage dashboard', _tagQa, 2),
  _Task('APP-158', 'Autoscaling rules for workers', _tagInfra, 5),
  _Task('APP-159', 'Accessibility audit fixes', _tagDesign, 5),
  _Task('APP-160', 'GraphQL schema for reports', _tagBackend, 8),
  _Task('APP-161', 'Virtualized list performance pass', _tagFrontend, 3),
  _Task('APP-162', 'Biometric login on Android', _tagMobile, 5),
  _Task('APP-163', 'Contract tests for billing API', _tagQa, 3),
  _Task('APP-164', 'Terraform module cleanup', _tagInfra, 2),
  _Task('APP-165', 'Motion spec for card transitions', _tagDesign, 2),
  _Task('APP-166', 'Audit log export endpoint', _tagBackend, 3),
];

class _TaskBoardDemoState extends State<TaskBoardDemo> {
  final _dragController = DragAutoScrollController();
  final _scrollController = ScrollController();
  final _backlog = _buildBacklog();

  @override
  void dispose() {
    _dragController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _assignedCount(_TeamMember member) =>
      _backlog.where((task) => task.assignee == member).length;

  void _assign(_Task task, _TeamMember member) {
    setState(() => task.assignee = member);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag a member onto a task to assign it',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _team.length,
                  itemBuilder: (context, index) {
                    final member = _team[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AutoScrollDraggable<_TeamMember>(
                        controller: _dragController,
                        data: member,
                        feedback: _MemberDragFeedback(member: member),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _MemberTile(
                            member: member,
                            assignedCount: _assignedCount(member),
                          ),
                        ),
                        child: _MemberTile(
                          member: member,
                          assignedCount: _assignedCount(member),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                child: Row(
                  children: [
                    Text(
                      'Sprint 42 · Backlog',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_backlog.length} tasks',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DragAutoScroller(
                  controller: _dragController,
                  scrollController: _scrollController,
                  showEdgeZones: true,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    itemCount: _backlog.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = _backlog[index];
                      return _TaskCard(
                        task: task,
                        onAssign: (member) => _assign(task, member),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.assignedCount});

  final _TeamMember member;
  final int assignedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _MemberAvatar(member: member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.role,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (assignedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: member.color.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$assignedCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: member.color.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Icon(
              Icons.drag_indicator_rounded,
              color: theme.colorScheme.outline,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, this.radius = 20});

  final _TeamMember member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: member.color.shade100,
      child: Text(
        member.initials,
        style: TextStyle(
          color: member.color.shade900,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

class _MemberDragFeedback extends StatelessWidget {
  const _MemberDragFeedback({required this.member});

  final _TeamMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MemberAvatar(member: member, radius: 18),
            const SizedBox(width: 10),
            Text(
              member.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onAssign});

  final _Task task;
  final ValueChanged<_TeamMember> onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<_TeamMember>(
      onAcceptWithDetails: (details) => onAssign(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHovered
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          task.code,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _TagChip(tag: task.tag),
                        const SizedBox(width: 10),
                        Text(
                          '${task.points} pts',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _AssigneeBadge(assignee: task.assignee),
            ],
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final _TaskTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tag.color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tag.color.shade200),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: tag.color.shade800,
        ),
      ),
    );
  }
}

class _AssigneeBadge extends StatelessWidget {
  const _AssigneeBadge({required this.assignee});

  final _TeamMember? assignee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignee = this.assignee;
    if (assignee == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Unassigned',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MemberAvatar(member: assignee, radius: 14),
        const SizedBox(width: 8),
        Text(
          assignee.name,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
