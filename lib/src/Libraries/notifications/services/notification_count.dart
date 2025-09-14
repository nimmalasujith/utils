import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for counting notifications
class NotificationCounter {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Count unread notifications for a user
  Stream<int> getUnreadCount(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("read", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Count all notifications for a user
  Stream<int> getTotalCount(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}