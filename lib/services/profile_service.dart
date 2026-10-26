import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:minas_client/services/auth_service.dart';

class ProfileService {
  static const String _baseUrl = 'https://minasagency.com/api';
  static const String _personalInfoEndpoint = '/personal_info';

  /// Get personal information from API
  static Future<Map<String, dynamic>?> getPersonalInfo() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_personalInfoEndpoint');

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
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response has success field and personal_info
        if (responseData['success'] == true &&
            responseData['personal_info'] != null) {
          return responseData['personal_info'] as Map<String, dynamic>;
        } else {
          throw Exception('Invalid API response format');
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        // Try to parse error response
        String errorMessage =
            'Failed to load personal info: ${response.statusCode}';
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

  /// Update personal information
  static Future<bool> updatePersonalInfo(Map<String, dynamic> userData) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl$_personalInfoEndpoint');

      // Check if we have an image file to upload
      if (userData.containsKey('image') && userData['image'] is String) {
        final imagePath = userData['image'] as String;

        // If it's a file path, use multipart request
        if (File(imagePath).existsSync()) {
          return await _updatePersonalInfoWithFile(
            url,
            token,
            userData,
            imagePath,
          );
        }
      }

      // Otherwise, use regular JSON request
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
            body: json.encode(userData),
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
            'Failed to update personal info: ${response.statusCode}';
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

  /// Update personal information with file upload
  static Future<bool> _updatePersonalInfoWithFile(
    Uri url,
    String token,
    Map<String, dynamic> userData,
    String imagePath,
  ) async {
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'MINAS-Client/1.0',
      });

      // Add image file
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'image',
          imagePath,
        );
        request.files.add(multipartFile);
      }

      // Add other fields
      userData.forEach((key, value) {
        if (key != 'image' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
            'Failed to update personal info: ${response.statusCode}';
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

  /// Update specific personal information fields
  static Future<bool> updatePersonalInfoFields({
    String? image,
    String? name,
    String? phone,
    bool? notifyMail,
    bool? notifyWhatsapp,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (image != null) {
        // إذا كانت الصورة مسار ملف محلي، استخدمه مباشرة
        if (File(image).existsSync()) {
          updateData['image'] = image;
        } else {
          // إذا كانت رابط، استخدمه مباشرة
          updateData['image'] = image;
        }
      }
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (notifyMail != null) updateData['notify_mail'] = notifyMail ? 1 : 0;
      if (notifyWhatsapp != null) {
        updateData['notify_whatsapp'] = notifyWhatsapp ? 1 : 0;
      }

      return await updatePersonalInfo(updateData);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile image to server
  static Future<String?> uploadProfileImage(String imagePath) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('Image file does not exist');
      }

      final url = Uri.parse('$_baseUrl$_personalInfoEndpoint/upload_image');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'MINAS-Client/1.0',
      });

      // إضافة الملف
      final multipartFile = await http.MultipartFile.fromPath(
        'image', // اسم الحقل في الخادم
        imagePath,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true &&
            responseData['image_url'] != null) {
          return responseData['image_url'] as String;
        } else {
          throw Exception('Invalid upload response format');
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      } else {
        String errorMessage = 'Failed to upload image: ${response.statusCode}';
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
