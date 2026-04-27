import 'subscription_features_dto.dart';

class CurrentSubscriptionDto {
  final String plan;
  final String status;
  final String? startedAt;
  final String? expiresAt;
  final bool autoRenew;
  final SubscriptionFeaturesDto features;

  CurrentSubscriptionDto({
    required this.plan,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    required this.autoRenew,
    required this.features,
  });

  factory CurrentSubscriptionDto.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionDto(
      plan: json['plan'],
      status: json['status'],
      startedAt: json['startedAt'],
      expiresAt: json['expiresAt'],
      autoRenew: json['autoRenew'] ?? false,
      features: SubscriptionFeaturesDto.fromJson(json['features']),
    );
  }
}