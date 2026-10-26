import 'package:flutter/material.dart';

class TransactionResponse {
  final List<Transaction> transactions;

  TransactionResponse({required this.transactions});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions:
          (json['transactions'] as List)
              .map((transaction) => Transaction.fromJson(transaction))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}

class Transaction {
  final int id;
  final String transactionId;
  final String type;
  final String amount;
  final String status;
  final String description;
  final String? attachment;
  final String? attachmentType;
  final int customerId;
  final int? paymentMethodId;
  final String createdAt;
  final String updatedAt;
  final String transactionAttachment;
  final String transactionImage;
  final PaymentMethod? paymentMethod;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    this.attachment,
    this.attachmentType,
    required this.customerId,
    this.paymentMethodId,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionAttachment,
    required this.transactionImage,
    this.paymentMethod,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      attachment: json['attachment'] as String?,
      attachmentType: json['attachment_type'] as String?,
      customerId: json['customer_id'] as int,
      paymentMethodId: json['payment_method_id'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      transactionAttachment: json['transaction_attachment'] as String,
      transactionImage: json['transaction_image'] as String,
      paymentMethod:
          json['payment_method'] != null
              ? PaymentMethod.fromJson(
                json['payment_method'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'type': type,
      'amount': amount,
      'status': status,
      'description': description,
      'attachment': attachment,
      'attachment_type': attachmentType,
      'customer_id': customerId,
      'payment_method_id': paymentMethodId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'transaction_attachment': transactionAttachment,
      'transaction_image': transactionImage,
      'payment_method': paymentMethod?.toJson(),
    };
  }

  // Helper methods
  String get formattedAmount => '\$${double.parse(amount).toStringAsFixed(2)}';

  String get formattedDate {
    final date = DateTime.parse(createdAt);
    return '${date.day}/${date.month}/${date.year}';
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'معلق - Pending';
      case 'approved':
        return 'موافق عليه - Approved';
      case 'rejected':
        return 'مرفوض - Rejected';
      case 'completed':
        return 'مكتمل - Completed';
      default:
        return status;
    }
  }

  String get typeText {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'إيداع - Deposit';
      case 'reservation':
        return 'حجز - Reservation';
      case 'withdrawal':
        return 'سحب - Withdrawal';
      case 'refund':
        return 'استرداد - Refund';
      default:
        return type;
    }
  }

  bool get hasAttachment => attachment != null && attachment!.isNotEmpty;

  String get attachmentUrl {
    if (hasAttachment) {
      return 'https://minasagency.com/storage/$attachment';
    }
    return '';
  }

  String get paymentMethodName {
    if (paymentMethod != null) {
      return paymentMethod!.name.getLocalizedName('en'); // Default to English
    }
    return 'غير محدد - Not specified';
  }

  // Additional helper methods for UI
  String get localizedType {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'إيداع';
      case 'reservation':
        return 'حجز';
      case 'withdrawal':
        return 'سحب';
      case 'refund':
        return 'استرداد';
      default:
        return type;
    }
  }

  String get localizedStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'معلق';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get formattedTime {
    final date = DateTime.parse(createdAt);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class PaymentMethod {
  final int id;
  final LocalizedName name;
  final String image;
  final String? paymentIdentifier;
  final String createdAt;
  final String updatedAt;

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
      id: json['id'] as int,
      name: LocalizedName.fromJson(json['name'] as Map<String, dynamic>),
      image: json['image'] as String,
      paymentIdentifier: json['payment_identifier'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'image': image,
      'payment_identifier': paymentIdentifier,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class LocalizedName {
  final String en;
  final String ar;

  LocalizedName({required this.en, required this.ar});

  factory LocalizedName.fromJson(Map<String, dynamic> json) {
    return LocalizedName(en: json['en'] as String, ar: json['ar'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'ar': ar};
  }

  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return ar;
      case 'en':
      default:
        return en;
    }
  }
}
