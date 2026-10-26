import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import 'auth_service.dart';

class ReservationService {
  static const String baseUrl = 'https://minasagency.com/api';

  // Get headers with authentication token
  Future<Map<String, String>> get headers async {
    return await AuthService.getAuthHeaders();
  }

  Future<ReservationResponse> getReservations({
    int page = 1,
    String? date,
    int? service,
    String? status,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {'page': page.toString()};

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      if (service != null) {
        queryParams['service'] = service.toString();
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/reservations',
      ).replace(queryParameters: queryParams);

      final requestHeaders = await headers;
      final response = await http.get(uri, headers: requestHeaders);

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ReservationResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw ReservationException(
          'Authentication failed. Please login again.',
        );
      } else if (response.statusCode == 403) {
        throw ReservationException(
          'Access denied. You do not have permission to access reservations.',
        );
      } else {
        throw ReservationException(
          'Failed to load reservations: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ReservationException) {
        rethrow;
      }
      throw ReservationException('Network error: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await AuthService.isLoggedIn();
  }

  /// Clear authentication token
  Future<void> clearAuthentication() async {
    await AuthService.logout();
  }
}

class ReservationException implements Exception {
  final String message;

  ReservationException(this.message);

  @override
  String toString() => 'ReservationException: $message';
}
