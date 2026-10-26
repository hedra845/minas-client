import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minas_client/models/notification_model.dart';
import 'package:minas_client/services/auth_service.dart';

class NotificationService {
  static const String _baseUrl = 'https://minasagency.com/api';
  static const String _notificationsEndpoint = '/notifications';

  /// Get all notifications for the current user
  static Future<NotificationResponse?> getNotifications() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_notificationsEndpoint');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NotificationResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_notificationsEndpoint/read');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
            body: json.encode({'id': notificationId}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        // Try to parse error response
        String errorMessage =
            'Failed to mark notification as read: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If parsing fails, use default message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send read notification with notification_id key
  static Future<bool> sendReadNotification(String notificationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_notificationsEndpoint/read');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
            body: json.encode({'notification_id': notificationId}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        // Try to parse error response
        String errorMessage =
            'Failed to send read notification: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If parsing fails, use default message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_notificationsEndpoint/read_all');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        // Try to parse error response
        String errorMessage =
            'Failed to mark all notifications as read: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If parsing fails, use default message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
