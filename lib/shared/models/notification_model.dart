import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.receiverId,
    required this.title,
    required this.body,
    required this.type,
    required this.bookingId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String receiverId;
  final String title;
  final String body;
  final String type;
  final String bookingId;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromFirestore(Map<String, dynamic> json, String id) {
    return AppNotification(
      id: id,
      receiverId: json['receiverId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      bookingId: json['bookingId'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'type': type,
      'bookingId': bookingId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, receiverId, title, body, type, bookingId, isRead, createdAt];
}
