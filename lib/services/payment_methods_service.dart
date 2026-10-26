import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_method_model.dart';
import 'auth_service.dart';

class PaymentMethodsService {
  static const String baseUrl = 'https://minasagency.com/api';

  static Future<PaymentMethodsResponse> getPaymentMethods({
    String? token,
  }) async {
    try {
      // Use provided token or get from AuthService
      final authToken = token ?? await AuthService.getToken();

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/payment_methods'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PaymentMethodsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('خطأ في المصادقة - Authentication Error');
      } else if (response.statusCode == 403) {
        throw Exception('غير مصرح لك بالوصول - Access Denied');
      } else if (response.statusCode == 404) {
        throw Exception('طريقة الدفع غير موجودة - Payment Method Not Found');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'فشل في تحميل طرق الدفع - Failed to load payment methods: ${response.statusCode}',
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
          'خطأ في جلب طرق الدفع - Error fetching payment methods: $e',
        );
      }
    }
  }

  static Future<List<PaymentMethod>> getPaymentMethodsWithFallback({
    String? token,
  }) async {
    try {
      final response = await getPaymentMethods(token: token);
      return response.paymentMethods;
    } catch (e) {
      // Return empty list as fallback
      return [];
    }
  }
}
