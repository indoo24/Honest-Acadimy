import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/shared/cubit/notifications_cubit.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? Colors.grey[200] : Theme.of(context).primaryColor,
                  child: Icon(
                    notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Colors.white,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, h:mm a').format(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                onTap: () {
                  if (!notification.isRead) {
                    context.read<NotificationsCubit>().markAsRead(notification.id);
                  }
                  // Navigate based on type if needed
                  if (notification.type == 'booking_request') {
                    context.push('/admin');
                  } else {
                    context.push('/history');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
