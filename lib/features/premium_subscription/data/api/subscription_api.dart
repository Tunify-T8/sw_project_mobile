import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/subscription_plan_dto.dart';
import '../dto/current_subscription_dto.dart';
import '../dto/subscribe_request_dto.dart';
import '../dto/subscribe_response_dto.dart';
import '../dto/cancel_subscription_response_dto.dart';

class SubscriptionApi {
  final Dio dio;

  SubscriptionApi(this.dio);

  Future<List<SubscriptionPlanDto>> getSubscriptionPlans() async {
    final response = await dio.get(ApiEndpoints.getSubscriptionPlans);
    final data = response.data as Map<String, dynamic>;
    final plans = data['plans'] as List<dynamic>;

    return plans
        .map(
          (json) => SubscriptionPlanDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<CurrentSubscriptionDto> getCurrentSubscription() async {
    final response = await dio.get(ApiEndpoints.getCurrentSubscription);
    return CurrentSubscriptionDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

Future<SubscribeResponseDto> subscribe({
  required SubscribeRequestDto request,
}) async {
  final response = await dio.post(
    ApiEndpoints.subscribe,
    data: request.toJson(),
  );

  return SubscribeResponseDto.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<CancelSubscriptionResponseDto> cancelSubscription() async {
  final response = await dio.post(ApiEndpoints.cancelSubscription);

  return CancelSubscriptionResponseDto.fromJson(
    response.data as Map<String, dynamic>,
  );
}
}
