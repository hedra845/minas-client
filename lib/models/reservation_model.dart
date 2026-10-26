class StatusModel {
  final int? id;
  final String name;
  final LocalizedName localizedName;

  StatusModel({this.id, required this.name, required this.localizedName});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      name: json['name'] ?? '',
      localizedName: LocalizedName.fromJson(json['name'] ?? {}),
    );
  }

  String getLocalizedName(String languageCode) {
    return localizedName.getLocalizedName(languageCode);
  }
}

class ApiErrorResponse {
  final Map<String, List<String>> errors;

  ApiErrorResponse({required this.errors});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final errors = <String, List<String>>{};

    if (json['errors'] is Map<String, dynamic>) {
      final errorsMap = json['errors'] as Map<String, dynamic>;
      errorsMap.forEach((key, value) {
        if (value is List) {
          errors[key] = value.cast<String>();
        } else if (value is String) {
          errors[key] = [value];
        }
      });
    }

    return ApiErrorResponse(errors: errors);
  }

  String getErrorMessage() {
    if (errors.isEmpty) return 'An error occurred';

    final allErrors = <String>[];
    errors.forEach((field, messages) {
      allErrors.addAll(messages);
    });

    return allErrors.join(', ');
  }

  String getFieldErrorMessage(String field) {
    return errors[field]?.join(', ') ?? '';
  }

  bool hasFieldError(String field) {
    return errors.containsKey(field) && errors[field]!.isNotEmpty;
  }
}

class ReservationResponse {
  final ReservationsData reservations;
  final List<ServiceModel> services;
  final List<StatusModel> statuses;
  final dynamic filters;

  ReservationResponse({
    required this.reservations,
    required this.services,
    required this.statuses,
    required this.filters,
  });

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    return ReservationResponse(
      reservations: ReservationsData.fromJson(json['reservations']),
      services: _parseServices(json['services']),
      statuses: _parseStatuses(json['statuses']),
      filters: json['filters'],
    );
  }

  static List<StatusModel> _parseStatuses(dynamic statusesData) {
    if (statusesData == null) return [];

    if (statusesData is List) {
      return statusesData
          .map((status) => StatusModel.fromJson(status))
          .toList();
    } else if (statusesData is Map<String, dynamic>) {
      if (statusesData.containsKey('data') && statusesData['data'] is List) {
        return (statusesData['data'] as List)
            .map((status) => StatusModel.fromJson(status))
            .toList();
      }
      return [StatusModel.fromJson(statusesData)];
    }
    return [];
  }

  static List<ServiceModel> _parseServices(dynamic servicesData) {
    if (servicesData == null) {
      return [];
    }

    if (servicesData is List) {
      return servicesData
          .map((service) => ServiceModel.fromJson(service))
          .toList();
    } else if (servicesData is Map<String, dynamic>) {
      // Handle case where services is a Map with a 'data' key
      if (servicesData.containsKey('data') && servicesData['data'] is List) {
        return (servicesData['data'] as List)
            .map((service) => ServiceModel.fromJson(service))
            .toList();
      }
      // Handle case where services is a single service object
      return [ServiceModel.fromJson(servicesData)];
    }

    return [];
  }
}

class ReservationsData {
  final int currentPage;
  final List<ReservationModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ReservationsData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ReservationsData.fromJson(Map<String, dynamic> json) {
    return ReservationsData(
      currentPage: json['current_page'] ?? 1,
      data: _parseReservations(json['data']),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: _parsePaginationLinks(json['links']),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  static List<ReservationModel> _parseReservations(dynamic data) {
    if (data == null) {
      return [];
    }

    if (data is List) {
      return data
          .map((reservation) => ReservationModel.fromJson(reservation))
          .toList();
    } else if (data is Map<String, dynamic>) {
      // Handle case where data is a Map with a 'data' key
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map((reservation) => ReservationModel.fromJson(reservation))
            .toList();
      }
      // Handle case where data is a single reservation object
      return [ReservationModel.fromJson(data)];
    }

    return [];
  }

  static List<PaginationLink> _parsePaginationLinks(dynamic links) {
    if (links == null) {
      return [];
    }

    if (links is List) {
      return links.map((link) => PaginationLink.fromJson(link)).toList();
    } else if (links is Map<String, dynamic>) {
      // Handle case where links is a Map with a 'data' key
      if (links.containsKey('data') && links['data'] is List) {
        return (links['data'] as List)
            .map((link) => PaginationLink.fromJson(link))
            .toList();
      }
      // Handle case where links is a single link object
      return [PaginationLink.fromJson(links)];
    }

    return [];
  }
}

class ReservationModel {
  final int id;
  final ServiceModel service;
  final DateTime date;
  final String pnrNumber;
  final double cost;
  final String status;
  final String? attachment;
  final CompanyModel company;

  ReservationModel({
    required this.id,
    required this.service,
    required this.date,
    required this.pnrNumber,
    required this.cost,
    required this.status,
    this.attachment,
    required this.company,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      service: ServiceModel.fromJson(json['service'] ?? {}),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      pnrNumber: json['pnr_number'] ?? '',
      cost: (json['cost'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      attachment: json['attachment'],
      company: CompanyModel.fromJson(json['company'] ?? {}),
    );
  }
}

class ServiceModel {
  final int? id;
  final LocalizedName name;

  ServiceModel({this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: LocalizedName.fromJson(json['name'] ?? {}),
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

class CompanyModel {
  final CurrencyModel currency;

  CompanyModel({required this.currency});

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      currency: CurrencyModel.fromJson(json['currency'] ?? {}),
    );
  }
}

class CurrencyModel {
  final String symbol;

  CurrencyModel({required this.symbol});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(symbol: json['symbol'] ?? '');
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({this.url, required this.label, required this.active});

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
