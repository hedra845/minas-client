class NotificationModel {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final NotificationData data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;
  final String notificationImage;

  NotificationModel({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationImage,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      notifiableType: json['notifiable_type'] ?? '',
      notifiableId: json['notifiable_id'] ?? 0,
      data: NotificationData.fromJson(json['data'] ?? {}),
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      notificationImage: json['notification_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_type': notifiableType,
      'notifiable_id': notifiableId,
      'data': data.toJson(),
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'notification_image': notificationImage,
    };
  }

  bool get isRead => readAt != null;

  String get fullImageUrl {
    // If notificationImage is already a full URL, use it directly
    if (notificationImage.isNotEmpty &&
        (notificationImage.startsWith('http://') ||
            notificationImage.startsWith('https://'))) {
      return notificationImage;
    }

    // If data.image is a full URL, use it directly
    if (data.image.isNotEmpty &&
        (data.image.startsWith('http://') ||
            data.image.startsWith('https://'))) {
      return data.image;
    }

    // If notificationImage is a base URL and data.image is a path, combine them
    if (notificationImage.isNotEmpty && data.image.isNotEmpty) {
      // Remove trailing slash from notificationImage if present
      String baseUrl =
          notificationImage.endsWith('/')
              ? notificationImage.substring(0, notificationImage.length - 1)
              : notificationImage;

      // Add leading slash to data.image if not present
      String imagePath =
          data.image.startsWith('/') ? data.image : '/$data.image';

      return '$baseUrl$imagePath';
    }

    return '';
  }
}

class NotificationData {
  final String title;
  final String image;
  final String offerName;
  final String description;
  final String createdAt;
  final String link;

  NotificationData({
    required this.title,
    required this.image,
    required this.offerName,
    required this.description,
    required this.createdAt,
    required this.link,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      offerName: json['offer_name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'offer_name': offerName,
      'description': description,
      'created_at': createdAt,
      'link': link,
    };
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int unreadNotifications;

  NotificationResponse({
    required this.notifications,
    required this.unreadNotifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((item) => NotificationModel.fromJson(item))
              .toList() ??
          [],
      unreadNotifications: json['unread_notifications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'unread_notifications': unreadNotifications,
    };
  }
}
