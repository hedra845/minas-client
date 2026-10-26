import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minas_client/models/membership_model.dart';
import 'auth_service.dart';

class MembershipsService {
  static const String baseUrl = 'https://minasagency.com/api';

  static Future<MembershipsResponse> getMemberships() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/memberships'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print('Memberships API Response: $data'); // Debug log
        return MembershipsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired or invalid - logout user
        await AuthService.logout();
        throw Exception('انتهت صلاحية الجلسة - Session Expired');
      } else if (response.statusCode == 403) {
        // Access denied - logout user
        await AuthService.logout();
        throw Exception('غير مصرح لك بالوصول - Access Denied');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'فشل في جلب العضويات - Failed to fetch memberships: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception('خطأ في الاتصال بالإنترنت - Network Connection Error');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('انتهت مهلة الاتصال - Connection Timeout');
      } else {
        throw Exception('خطأ في جلب العضويات - Error fetching memberships: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> subscribeToMembership(
    int membershipId,
  ) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/memberships/subscribe'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'membership_id': membershipId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid - logout user
        await AuthService.logout();
        throw Exception('انتهت صلاحية الجلسة - Session Expired');
      } else if (response.statusCode == 403) {
        // Access denied - logout user
        await AuthService.logout();
        throw Exception('غير مصرح لك بالوصول - Access Denied');
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] ?? {};
        String errorMessage = 'خطأ في البيانات المدخلة - Validation Error:\n';

        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessage += '• ${messages.join(', ')}\n';
          }
        });

        throw Exception(errorMessage);
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'فشل في الاشتراك في العضوية - Failed to subscribe to membership: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception('خطأ في الاتصال بالإنترنت - Network Connection Error');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('انتهت مهلة الاتصال - Connection Timeout');
      } else {
        throw Exception(
          'خطأ في الاشتراك في العضوية - Error subscribing to membership: $e',
        );
      }
    }
  }
}
