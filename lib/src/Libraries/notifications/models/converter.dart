import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for notifications
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  /// Convert object → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  /// Create object from JSON
  static NotificationModel fromJson(Map<String, dynamic> json, {String? id}) {
    return NotificationModel(
      id: id ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      read: json['read'] ?? false,
    );
  }

  /// Convert Firestore snapshot → model
  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return NotificationModel.fromJson(data, id: doc.id);
  }
}

/// Repository for working with notifications
class NotificationRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Get stream of notifications for a user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  /// Add new notification
  Future<void> addNotification(String userId, NotificationModel notification) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toJson());
  }

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(notificationId)
        .update({'read': true});
  }

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(notificationId)
        .delete();
  }

  /// 🔹 Count unread notifications
  Stream<int> getUnreadCount(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("read", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}