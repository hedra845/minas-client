import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer_model.dart';
import 'auth_service.dart';

class OffersService {
  static const String baseUrl = 'https://minasagency.com/api';

  /// Get headers with authentication token
  Future<Map<String, String>> get headers async {
    return await AuthService.getAuthHeaders();
  }

  /// Get offers with optional filtering and pagination
  Future<OffersResponse> getOffers({
    int page = 1,
    int? serviceId,
    String? serviceName,
    String? status,
    String? date,
    String? search,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {'page': page.toString()};

      if (serviceId != null && serviceId != 0) {
        queryParams['service_id'] = serviceId.toString();
      } else if (serviceName != null && serviceName.isNotEmpty) {
        queryParams['service'] = serviceName;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Use GET for all requests (API doesn't support POST)
      final uri = Uri.parse(
        '$baseUrl/offers',
      ).replace(queryParameters: queryParams);

      final requestHeaders = await headers;
      requestHeaders['User-Agent'] = 'MINAS-Client/1.0';
      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return OffersResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw OffersException('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw OffersException(
          'Access denied. You do not have permission to access offers.',
        );
      } else if (response.statusCode == 422) {
        // Parse error details from response
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Invalid request parameters';
          final errors = errorData['errors'] ?? {};
          throw OffersException('Validation error: $message. Errors: $errors');
        } catch (e) {
          throw OffersException(
            'Invalid request parameters (422). Please check your filter selection.',
          );
        }
      } else {
        throw OffersException('Failed to load offers: ${response.statusCode}');
      }
    } catch (e) {
      if (e is OffersException) {
        rethrow;
      }
      throw OffersException('Network error: $e');
    }
  }

  /// Get available services for filtering
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await getOffers();
      return response.services;
    } catch (e) {
      throw OffersException('Failed to load services: $e');
    }
  }

  /// Get offer by ID
  Future<OfferModel> getOfferById(int offerId) async {
    try {
      final uri = Uri.parse('$baseUrl/offers/$offerId');
      final requestHeaders = await headers;
      requestHeaders['User-Agent'] = 'MINAS-Client/1.0';
      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return OfferModel.fromJson(jsonData['offer'] ?? jsonData);
      } else if (response.statusCode == 401) {
        throw OffersException('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        throw OffersException('Offer not found.');
      } else {
        throw OffersException('Failed to load offer: ${response.statusCode}');
      }
    } catch (e) {
      if (e is OffersException) {
        rethrow;
      }
      throw OffersException('Network error: $e');
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

class OffersException implements Exception {
  final String message;

  OffersException(this.message);

  @override
  String toString() => 'OffersException: $message';
}
