import 'payment_method_type.dart';

class PaymentMethodEntity {
  final PaymentMethodType type;
  final String? last4;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;

  const PaymentMethodEntity({
    required this.type,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
  });

  PaymentMethodEntity copyWith({
    PaymentMethodType? type,
    String? last4,
    String? brand,
    int? expiryMonth,
    int? expiryYear,
  }) {
    return PaymentMethodEntity(
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
    );
  }
}