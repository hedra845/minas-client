import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'auth_service.dart';

class TransactionsService {
  static const String baseUrl = 'https://minasagency.com/api';

  /// Get headers with authentication token
  Future<Map<String, String>> get headers async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw TransactionsException('No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get transactions with optional filtering
  Future<TransactionResponse> getTransactions({
    String? status,
    String? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }

      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final uri = Uri.parse(
        '$baseUrl/transactions',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final requestHeaders = await headers;
      final response = await http.get(uri, headers: requestHeaders);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransactionResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // Token expired or invalid - logout user
        await AuthService.logout();
        throw TransactionsException('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        // Access denied - logout user
        await AuthService.logout();
        throw TransactionsException('Access denied. Please login again.');
      } else if (response.statusCode == 404) {
        throw TransactionsException('No transactions found.');
      } else {
        throw TransactionsException(
          'Failed to load transactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is TransactionsException) {
        rethrow;
      }
      throw TransactionsException('Network error: $e');
    }
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(int transactionId) async {
    try {
      final uri = Uri.parse('$baseUrl/transactions/$transactionId');
      final requestHeaders = await headers;
      final response = await http.get(uri, headers: requestHeaders);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Transaction.fromJson(jsonData['transaction'] ?? jsonData);
      } else if (response.statusCode == 401) {
        // Token expired or invalid - logout user
        await AuthService.logout();
        throw TransactionsException('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        // Access denied - logout user
        await AuthService.logout();
        throw TransactionsException('Access denied. Please login again.');
      } else if (response.statusCode == 404) {
        throw TransactionsException('Transaction not found.');
      } else {
        throw TransactionsException(
          'Failed to load transaction: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is TransactionsException) {
        rethrow;
      }
      throw TransactionsException('Network error: $e');
    }
  }
}

class TransactionsException implements Exception {
  final String message;

  TransactionsException(this.message);

  @override
  String toString() => 'TransactionsException: $message';
}
