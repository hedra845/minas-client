import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'auth_service.dart';

class DepositService {
  static const String baseUrl = 'https://minasagency.com/api';

  static Future<Map<String, dynamic>> submitDeposit({
    required double amount,
    required int method,
    required String name,
    File? imageFile, // Optional File object
  }) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      // Create multipart request for file upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/deposit_store'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['amount'] = amount.toString();
      request.fields['method'] = method.toString();
      request.fields['name'] = name;

      // Add image file only if provided
      if (imageFile != null) {
        final imageStream = http.ByteStream(imageFile.openRead());
        final imageLength = await imageFile.length();
        final imageMultipartFile = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: path.basename(imageFile.path),
        );
        request.files.add(imageMultipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
          'فشل في إرسال طلب الإيداع - Failed to submit deposit: ${response.statusCode}',
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
          'خطأ في إرسال طلب الإيداع - Error submitting deposit: $e',
        );
      }
    }
  }
}
