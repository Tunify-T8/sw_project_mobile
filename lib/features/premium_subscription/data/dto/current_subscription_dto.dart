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
    final featuresJson = json['features'];

    return CurrentSubscriptionDto(
      plan: json['plan'] ?? 'free',
      status: json['status'] ?? 'active',
      startedAt: json['startedAt'],
      expiresAt: json['expiresAt'] ?? json['endedAt'],
      autoRenew: json['autoRenew'] ?? false,
      features: SubscriptionFeaturesDto.fromJson(
        featuresJson is Map<String, dynamic>
            ? featuresJson
            : const <String, dynamic>{},
      ),
    );
  }
}
