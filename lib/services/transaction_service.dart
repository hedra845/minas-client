import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'auth_service.dart';

class TransactionService {
  static const String baseUrl = 'https://minasagency.com/api';

  static Future<TransactionResponse> getTransactions() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TransactionResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('خطأ في المصادقة - Authentication Error');
      } else if (response.statusCode == 403) {
        throw Exception('غير مصرح لك - Access Denied');
      } else if (response.statusCode == 404) {
        throw Exception('المعاملات غير موجودة - Transactions not found');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'خطأ غير متوقع - Unexpected Error: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('خطأ في الاتصال - Connection Error');
    } on HttpException {
      throw Exception('خطأ في الطلب - Request Error');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات - Data Format Error');
    } catch (e) {
      throw Exception('خطأ غير متوقع - Unexpected Error: $e');
    }
  }

  static Future<TransactionResponse> getTransactionsWithFallback() async {
    try {
      return await getTransactions();
    } catch (e) {
      return TransactionResponse(transactions: []);
    }
  }

  static Future<Map<String, dynamic>> getTransactionDetails(
    int transactionId,
  ) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('خطأ في المصادقة - Authentication Error');
      } else if (response.statusCode == 403) {
        throw Exception('غير مصرح لك - Access Denied');
      } else if (response.statusCode == 404) {
        throw Exception('المعاملة غير موجودة - Transaction not found');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'خطأ غير متوقع - Unexpected Error: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('خطأ في الاتصال - Connection Error');
    } on HttpException {
      throw Exception('خطأ في الطلب - Request Error');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات - Data Format Error');
    } catch (e) {
      throw Exception('خطأ غير متوقع - Unexpected Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateTransactionStatus({
    required int transactionId,
    required String status,
    String? notes,
  }) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final Map<String, dynamic> body = {
        'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('خطأ في المصادقة - Authentication Error');
      } else if (response.statusCode == 403) {
        throw Exception('غير مصرح لك - Access Denied');
      } else if (response.statusCode == 404) {
        throw Exception('المعاملة غير موجودة - Transaction not found');
      } else if (response.statusCode == 422) {
        throw Exception('بيانات غير صحيحة - Invalid Data');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'خطأ غير متوقع - Unexpected Error: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('خطأ في الاتصال - Connection Error');
    } on HttpException {
      throw Exception('خطأ في الطلب - Request Error');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات - Data Format Error');
    } catch (e) {
      throw Exception('خطأ غير متوقع - Unexpected Error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteTransaction(
    int transactionId,
  ) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يرجى تسجيل الدخول أولاً - Please login first');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'تم حذف المعاملة بنجاح'};
      } else if (response.statusCode == 401) {
        throw Exception('خطأ في المصادقة - Authentication Error');
      } else if (response.statusCode == 403) {
        throw Exception('غير مصرح لك - Access Denied');
      } else if (response.statusCode == 404) {
        throw Exception('المعاملة غير موجودة - Transaction not found');
      } else if (response.statusCode == 500) {
        throw Exception('خطأ في الخادم - Server Error');
      } else {
        throw Exception(
          'خطأ غير متوقع - Unexpected Error: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('خطأ في الاتصال - Connection Error');
    } on HttpException {
      throw Exception('خطأ في الطلب - Request Error');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات - Data Format Error');
    } catch (e) {
      throw Exception('خطأ غير متوقع - Unexpected Error: $e');
    }
  }
}
