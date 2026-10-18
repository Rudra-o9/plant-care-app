import 'package:flutter/material.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../services/reminder_service.dart';

/// Screen listing plant care reminders divided into Today, Upcoming, Completed tabs.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reminderService = ReminderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Today's"),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _reminderService,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildReminderList(_reminderService.todayReminders, "No tasks scheduled for today! 🎉"),
              _buildReminderList(_reminderService.upcomingReminders, "No upcoming reminders."),
              _buildReminderList(_reminderService.completedReminders, "No completed tasks yet."),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReminderList(List list, String emptyMessage) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.notifications_none_rounded,
        title: 'All Clear',
        description: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final reminder = list[index];
        return ReminderCard(
          reminder: reminder,
          onToggleComplete: (val) {
            _reminderService.toggleComplete(reminder.id);
          },
          onDelete: () {
            _reminderService.deleteReminder(reminder.id);
          },
        );
      },
    );
  }
}
