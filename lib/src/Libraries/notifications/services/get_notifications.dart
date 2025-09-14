import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/converter.dart';

/// Fetch user notifications from Firestore
class NotificationFetcher {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
}