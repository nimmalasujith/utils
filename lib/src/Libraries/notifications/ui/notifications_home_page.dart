import 'package:flutter/material.dart';
import '../services/get_notifications.dart';
import '../services/notification_count.dart';
import '../models/converter.dart';

class NotificationsHomePage extends StatelessWidget {
  final String userId;

  const NotificationsHomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final fetcher = NotificationFetcher();
    final counter = NotificationCounter();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: counter.getUnreadCount(userId),
          builder: (context, snapshot) {
            final unread = snapshot.data ?? 0;
            return Text("Notifications ($unread unread)");
          },
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: fetcher.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty) return const Center(child: Text("No notifications"));

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                title: Text(notif.title),
                subtitle: Text(notif.body),
                trailing: notif.read ? null : const Icon(Icons.mark_email_unread),
              );
            },
          );
        },
      ),
    );
  }
}