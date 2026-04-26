import 'subscription_features_dto.dart';

class SubscriptionPlanDto {
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final SubscriptionFeaturesDto features;

  SubscriptionPlanDto({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.features,
  });

  factory SubscriptionPlanDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanDto(
      name: json['name'],
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      yearlyPrice: (json['yearly_price'] as num).toDouble(),
      currency: json['currency'],
      features: SubscriptionFeaturesDto.fromJson(json['features']),
    );
  }
}