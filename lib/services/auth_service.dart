import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _loginStatusKey = 'is_logged_in';
  static const String baseUrl = 'https://minasagency.com/api';

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final isLoggedIn = prefs.getBool(_loginStatusKey) ?? false;

      return token != null && token.isNotEmpty && isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save login session
  static Future<bool> saveLoginSession({
    required String token,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_loginStatusKey, true);

      if (userData != null) {
        // Ensure email is included in user data
        final userDataWithEmail = Map<String, dynamic>.from(userData);
        if (userDataWithEmail['email'] == null ||
            userDataWithEmail['email'].isEmpty) {
          // If email is not provided, try to get it from other fields
          userDataWithEmail['email'] =
              userDataWithEmail['email_address'] ??
              userDataWithEmail['user_email'] ??
              userDataWithEmail['mail'] ??
              '';
        }

        // Ensure profile image is included in user data
        if (userDataWithEmail['profile_image'] == null ||
            userDataWithEmail['profile_image'].isEmpty) {
          // If profile image is not provided, try to get it from other fields
          userDataWithEmail['profile_image'] =
              userDataWithEmail['avatar'] ??
              userDataWithEmail['photo'] ??
              userDataWithEmail['image'] ??
              '';
        }

        await prefs.setString(_userDataKey, jsonEncode(userDataWithEmail));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save user data to storage
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = jsonEncode(userData);
      await prefs.setString(_userDataKey, userDataString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear login session (logout)
  static Future<bool> logout() async {
    try {
      final token = await getToken();

      // Call logout API if token exists
      if (token != null && token.isNotEmpty) {
        try {
          await http
              .post(
                Uri.parse('$baseUrl/logout'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                  'User-Agent': 'MINAS-Client/1.0',
                },
              )
              .timeout(Duration(seconds: 30));

          // Continue with local logout regardless of API response
        } catch (e) {
          // Continue with local logout even if API fails
        }
      }

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.setBool(_loginStatusKey, false);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify token with server
  static Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;

      final response = await http
          .get(
            Uri.parse('$baseUrl/user'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'User-Agent': 'MINAS-Client/1.0',
            },
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token expired or invalid, logout user
        await logout();
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get authentication headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'MINAS-Client/1.0',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Check if session is valid (with server verification)
  static Future<bool> isSessionValid() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) return false;

    // Optionally verify with server
    return await verifyToken();
  }

  /// Update user profile image
  static Future<bool> updateProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        userData['profile_image'] = imagePath;

        await prefs.setString(_userDataKey, jsonEncode(userData));
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
