class OffersResponse {
  final List<ServiceModel> services;
  final ServiceOffersData serviceoffers;
  final List<dynamic> filters;

  OffersResponse({
    required this.services,
    required this.serviceoffers,
    required this.filters,
  });

  factory OffersResponse.fromJson(Map<String, dynamic> json) {
    return OffersResponse(
      services:
          (json['services'] as List)
              .map((service) => ServiceModel.fromJson(service))
              .toList(),
      serviceoffers: ServiceOffersData.fromJson(json['serviceoffers']),
      filters: json['filters'] ?? [],
    );
  }
}

class ServiceOffersData {
  final List<OfferModel> data;
  final int total;
  final Map<String, dynamic> links;
  final int perPage;
  final int currentPage;

  ServiceOffersData({
    required this.data,
    required this.total,
    required this.links,
    required this.perPage,
    required this.currentPage,
  });

  factory ServiceOffersData.fromJson(Map<String, dynamic> json) {
    return ServiceOffersData(
      data:
          (json['data'] as List)
              .map((offer) => OfferModel.fromJson(offer))
              .toList(),
      total: int.tryParse(json['total'].toString()) ?? 0,
      links: json['links'] as Map<String, dynamic>? ?? {},
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
    );
  }
}

class OfferModel {
  final int id;
  final LocalizedName title;
  final String? image;
  final DateTime? expireDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String price;
  final int currencyId;
  final int serviceId;
  final String serviceName;
  final String currencyName;
  final String? bookingUrl;

  OfferModel({
    required this.id,
    required this.title,
    this.image,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    required this.price,
    required this.currencyId,
    required this.serviceId,
    required this.serviceName,
    required this.currencyName,
    this.bookingUrl,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      title: LocalizedName.fromJson(json['title'] ?? {'ar': '', 'en': ''}),
      image: json['image'],
      expireDate:
          json['expire_date'] != null
              ? DateTime.tryParse(json['expire_date'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
      price: json['price']?.toString() ?? '0',
      currencyId: json['currency_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      currencyName: json['currency_name'] ?? '',
      bookingUrl: json['booking_url'] ?? json['url'] ?? json['link'],
    );
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;

  bool get isExpired {
    if (expireDate == null) return false;
    return DateTime.now().isAfter(expireDate!);
  }

  String get formattedPrice => '$price $currencyName';
}

class ServiceModel {
  final int? id;
  final LocalizedName name;
  final String? icon;
  final String? description;

  ServiceModel({this.id, required this.name, this.icon, this.description});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: LocalizedName.fromJson(json['name'] ?? {'ar': '', 'en': ''}),
      icon: json['icon'],
      description: json['description'],
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
