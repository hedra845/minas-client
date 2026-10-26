class PaymentMethodsResponse {
  final List<PaymentMethod> paymentMethods;

  PaymentMethodsResponse({required this.paymentMethods});

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      paymentMethods:
          (json['payment_methods'] as List)
              .map((method) => PaymentMethod.fromJson(method))
              .toList(),
    );
  }
}

class PaymentMethod {
  final int id;
  final LocalizedName name;
  final String image;
  final String? paymentIdentifier;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.image,
    this.paymentIdentifier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: LocalizedName.fromJson(json['name'] ?? {'ar': '', 'en': ''}),
      image: json['image'] ?? '',
      paymentIdentifier: json['payment_identifier'],
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
