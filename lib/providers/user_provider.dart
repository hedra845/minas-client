import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:minas_client/services/profile_service.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _userPhone;
  String? _userEmail;
  String? _userAddress;
  String? _userProfileImage;
  double? _userBalance;
  String? _userCountry;
  int? _userId;
  bool? _notifyMail;
  bool? _notifyWhatsapp;
  int? _membershipId;
  String? _userType;

  // Getters
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userEmail => _userEmail;
  String? get userAddress => _userAddress;
  String? get userProfileImage => _userProfileImage;
  double? get userBalance => _userBalance;
  String? get userCountry => _userCountry;
  int? get userId => _userId;
  bool? get notifyMail => _notifyMail;
  bool? get notifyWhatsapp => _notifyWhatsapp;
  int? get membershipId => _membershipId;
  String? get userType => _userType;

  // Check if user data is loaded
  bool get hasUserData => _userName != null && _userPhone != null;

  /// Load user data from storage
  Future<void> loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        _userName =
            userData['name'] ?? userData['full_name'] ?? userData['username'];
        _userPhone =
            userData['phone'] ?? userData['phone_number'] ?? userData['mobile'];
        _userEmail = userData['email'];
        _userAddress = userData['address'] ?? userData['location'];
        _userProfileImage =
            userData['profile_image'] ??
            userData['avatar'] ??
            userData['photo'];

        notifyListeners();
      }
    } catch (e) {}
  }

  /// Load user data from API
  Future<void> loadUserDataFromAPI() async {
    try {
      final apiData = await ProfileService.getPersonalInfo();
      if (apiData != null) {
        _userId = apiData['id'];
        _userName =
            apiData['name'] ?? apiData['full_name'] ?? apiData['username'];
        _userPhone =
            apiData['phone'] ?? apiData['phone_number'] ?? apiData['mobile'];
        _userEmail = apiData['email'];
        _userAddress = apiData['address'] ?? apiData['location'];
        _userProfileImage =
            apiData['image'] ??
            apiData['profile_image'] ??
            apiData['avatar'] ??
            apiData['photo'];
        _userBalance =
            (apiData['balance'] ?? apiData['balance_sum'] ?? 0.0).toDouble();
        _userCountry = apiData['country'];
        _notifyMail = apiData['notify_mail'] == 1;
        _notifyWhatsapp = apiData['notify_whatsapp'] == 1;
        _membershipId = apiData['membership_id'];
        _userType = apiData['user_type'];

        // Save to local storage for offline access
        await AuthService.saveUserData(apiData);

        notifyListeners();
      }
    } catch (e) {
      // Fallback to local storage if API fails
      await loadUserData();
    }
  }

  /// Update user data (called after successful login)
  void updateUserData(Map<String, dynamic> userData) {
    _userName =
        userData['name'] ?? userData['full_name'] ?? userData['username'];
    _userPhone =
        userData['phone'] ?? userData['phone_number'] ?? userData['mobile'];
    _userEmail = userData['email'];
    _userAddress = userData['address'] ?? userData['location'];
    _userProfileImage =
        userData['profile_image'] ?? userData['avatar'] ?? userData['photo'];

    notifyListeners();
  }

  /// Clear user data (called during logout)
  void clearUserData() {
    _userName = null;
    _userPhone = null;
    _userEmail = null;
    _userAddress = null;
    _userProfileImage = null;
    _userBalance = null;
    _userCountry = null;
    _userId = null;
    _notifyMail = null;
    _notifyWhatsapp = null;

    notifyListeners();
  }

  /// Get display name (fallback to "User" if no name)
  String getDisplayName() {
    return _userName ?? 'User';
  }

  /// Get display phone (fallback to empty if no phone)
  String getDisplayPhone() {
    return _userPhone ?? '';
  }

  /// Get display email (fallback to empty if no email)
  String getDisplayEmail() {
    return _userEmail ?? '';
  }

  /// Get display address (fallback to empty if no address)
  String getDisplayAddress() {
    return _userAddress ?? '';
  }

  /// Get display profile image (fallback to null if no image)
  String? getDisplayProfileImage() {
    return _userProfileImage;
  }

  /// Get display balance (fallback to 0.0 if no balance)
  double getDisplayBalance() {
    return _userBalance ?? 0.0;
  }

  /// Get display country (fallback to empty if no country)
  String getDisplayCountry() {
    return _userCountry ?? '';
  }

  /// Get display user ID (fallback to 0 if no ID)
  int getDisplayUserId() {
    return _userId ?? 0;
  }

  /// Get display notify mail status (fallback to false if no data)
  bool getDisplayNotifyMail() {
    return _notifyMail ?? false;
  }

  /// Get display notify whatsapp status (fallback to false if no data)
  bool getDisplayNotifyWhatsapp() {
    return _notifyWhatsapp ?? false;
  }

  /// Get display membership ID (fallback to null if no data)
  int? getDisplayMembershipId() {
    return _membershipId;
  }

  /// Get display user type (fallback to null if no data)
  String? getDisplayUserType() {
    return _userType;
  }

  /// Get membership status text
  String getMembershipStatus() {
    if (_membershipId == null) {
      return 'no_membership'.tr();
    }
    return 'membership_active'.tr();
  }

  /// Update profile image
  void updateProfileImage(String imagePath) {
    _userProfileImage = imagePath;
    notifyListeners();
  }

  /// Update personal information via API
  Future<bool> updatePersonalInfo({
    String? image,
    String? name,
    String? phone,
    bool? notifyMail,
    bool? notifyWhatsapp,
  }) async {
    try {
      final success = await ProfileService.updatePersonalInfoFields(
        image: image,
        name: name,
        phone: phone,
        notifyMail: notifyMail,
        notifyWhatsapp: notifyWhatsapp,
      );

      if (success) {
        // Update local data
        if (image != null) _userProfileImage = image;
        if (name != null) _userName = name;
        if (phone != null) _userPhone = phone;
        if (notifyMail != null) _notifyMail = notifyMail;
        if (notifyWhatsapp != null) _notifyWhatsapp = notifyWhatsapp;

        notifyListeners();
      }

      return success;
    } catch (e) {
      rethrow;
    }
  }
}
