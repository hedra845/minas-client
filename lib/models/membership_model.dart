class MembershipsResponse {
  final bool success;
  final List<Membership> memberships;
  final UserMembership? userMembership;
  final int? userMembershipId; // For when user_membership is just an ID

  MembershipsResponse({
    required this.success,
    required this.memberships,
    this.userMembership,
    this.userMembershipId,
  });

  factory MembershipsResponse.fromJson(Map<String, dynamic> json) {
    try {
      // print('MembershipsResponse JSON: $json'); // Debug log

      final membershipsList = json['memberships'] as List? ?? [];
      // print('Memberships list length: ${membershipsList.length}'); // Debug log

      // Handle user_membership - could be an object or just an ID
      UserMembership? userMembership;
      int? userMembershipId;

      final userMembershipData = json['user_membership'];
      if (userMembershipData != null) {
        if (userMembershipData is Map<String, dynamic>) {
          // It's a full UserMembership object
          userMembership = UserMembership.fromJson(userMembershipData);
        } else if (userMembershipData is int) {
          // It's just an ID
          userMembershipId = userMembershipData;
        }
      }

      return MembershipsResponse(
        success: json['success'] ?? false,
        memberships:
            membershipsList
                .map((membership) => Membership.fromJson(membership))
                .toList(),
        userMembership: userMembership,
        userMembershipId: userMembershipId,
      );
    } catch (e) {
      // print('Error parsing MembershipsResponse: $e'); // Debug log
      rethrow;
    }
  }
}

class Membership {
  final int id;
  final LocalizedName name;
  final String memberlogo;
  final String bgColor;
  final String textColor;
  final String sidebarImage;
  final String logo;
  final String circleIcon;
  final String checkIcon;
  final List<String> features;
  final int minInvoice;
  final int maxInvoice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String image;
  final bool isSelected;

  Membership({
    required this.id,
    required this.name,
    required this.memberlogo,
    required this.bgColor,
    required this.textColor,
    required this.sidebarImage,
    required this.logo,
    required this.circleIcon,
    required this.checkIcon,
    required this.features,
    required this.minInvoice,
    required this.maxInvoice,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.isSelected,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    // Parse features from JSON string
    List<String> featuresList = [];
    if (json['features'] != null) {
      try {
        final featuresData = json['features'];
        // print('Features data: $featuresData'); // Debug log

        if (featuresData is String) {
          // Parse JSON array string properly
          final featuresString = featuresData;
          // print('Features string: $featuresString'); // Debug log

          // Remove brackets and quotes, then split by comma
          final cleanFeatures = featuresString
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '');

          featuresList =
              cleanFeatures
                  .split(', ')
                  .where((f) => f.trim().isNotEmpty)
                  .map((f) => f.trim())
                  .toList();

          // print('Parsed features: $featuresList'); // Debug log
        } else if (featuresData is List) {
          // If it's already a list
          featuresList = featuresData.cast<String>();
          // print('Features as list: $featuresList'); // Debug log
        }
      } catch (e) {
        // print('Error parsing features: $e'); // Debug log
        featuresList = [];
      }
    }

    return Membership(
      id: json['id'],
      name: LocalizedName.fromJson(json['name'] ?? {'ar': '', 'en': ''}),
      memberlogo: json['memberlogo'] ?? '',
      bgColor: json['bgColor'] ?? '#000000',
      textColor: json['textColor'] ?? '#ffffff',
      sidebarImage: json['sidebarImage'] ?? '',
      logo: json['logo'] ?? '',
      circleIcon: json['circleIcon'] ?? '',
      checkIcon: json['checkIcon'] ?? '',
      features: featuresList,
      minInvoice: json['min_invoice'] ?? 0,
      maxInvoice: json['max_invoice'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      image: json['image'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class UserMembership {
  final int id;
  final int userId;
  final int membershipId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserMembership({
    required this.id,
    required this.userId,
    required this.membershipId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      id: json['id'],
      userId: json['user_id'],
      membershipId: json['membership_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class LocalizedName {
  final String ar;
  final String en;

  LocalizedName({required this.ar, required this.en});

  factory LocalizedName.fromJson(Map<String, dynamic> json) {
    return LocalizedName(ar: json['ar'] ?? '', en: json['en'] ?? '');
  }

  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? ar : en;
  }
}
