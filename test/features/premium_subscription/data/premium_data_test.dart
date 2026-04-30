import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/premium_subscription/data/api/subscription_api.dart';
import 'package:software_project/features/premium_subscription/data/dto/cancel_subscription_response_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/current_subscription_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/subscribe_request_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/subscribe_response_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/subscription_features_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/subscription_plan_dto.dart';
import 'package:software_project/features/premium_subscription/data/mappers/current_subscription_mapper.dart';
import 'package:software_project/features/premium_subscription/data/mappers/subscription_features_mapper.dart';
import 'package:software_project/features/premium_subscription/data/mappers/subscription_plan_mapper.dart';
import 'package:software_project/features/premium_subscription/data/repository/subscription_repository_impl.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_type.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_status.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';

import '../helpers/premium_test_data.dart';

class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
          Invocation.method(
            #get,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
          returnValue: Future<Response<T>>.value(
            Response<T>(requestOptions: RequestOptions(path: path)),
          ),
        )
        as Future<Response<T>>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
          Invocation.method(
            #post,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
          returnValue: Future<Response<T>>.value(
            Response<T>(requestOptions: RequestOptions(path: path)),
          ),
        )
        as Future<Response<T>>;
  }
}

void main() {
  group('premium DTOs and mappers', () {
    test('features parse numeric and unlimited values with defaults', () {
      final numeric = SubscriptionFeaturesDto.fromJson({
        'maxUploads': 240,
        'adFree': true,
        'offlineListening': true,
        'playbackAccess': true,
        'playlistLimit': 12,
      });
      final unlimited = SubscriptionFeaturesDto.fromJson({
        'maxUploads': 'unlimited',
        'playlistLimit': 'unlimited',
      });
      final defaults = SubscriptionFeaturesDto.fromJson({});

      expect(numeric.toEntity().uploadLimit, 240);
      expect(numeric.toEntity().adFree, isTrue);
      expect(numeric.toEntity().offlineListening, isTrue);
      expect(numeric.toEntity().limitPlaybackAccess, isTrue);
      expect(numeric.toEntity().playlistLimit, 12);
      expect(unlimited.toEntity().uploadLimit, -1);
      expect(unlimited.toEntity().playlistLimit, -1);
      expect(defaults.toEntity().uploadLimit, 180);
      expect(defaults.toEntity().playlistLimit, 3);
      expect(defaults.toEntity().adFree, isFalse);
    });

    test('subscription plan maps hyphenated artist-pro tier', () {
      final dto = SubscriptionPlanDto.fromJson({
        'name': 'artist-pro',
        'monthlyPrice': 175,
        'yearlyPrice': 1750,
        'currency': 'EGP',
        'features': {'maxUploads': 'unlimited', 'playlistLimit': 50},
      });

      final entity = dto.toEntity();

      expect(entity.tier, SubscriptionTier.artistpro);
      expect(entity.monthlyPrice, 175);
      expect(entity.yearlyPrice, 1750);
      expect(entity.currency, 'EGP');
      expect(entity.features.uploadLimit, -1);
    });

    test(
      'current subscription supports endedAt fallback and empty features',
      () {
        final dto = CurrentSubscriptionDto.fromJson({
          'plan': 'artist-pro',
          'status': 'cancelled',
          'startedAt': '2026-01-01T00:00:00Z',
          'endedAt': '2026-02-01T00:00:00Z',
          'autoRenew': false,
        });

        final entity = dto.toEntity();

        expect(entity.tier, SubscriptionTier.artistpro);
        expect(entity.status, SubscriptionStatus.cancelled);
        expect(entity.startedAt, DateTime.parse('2026-01-01T00:00:00Z'));
        expect(entity.expiresAt, DateTime.parse('2026-02-01T00:00:00Z'));
        expect(entity.autoRenew, isFalse);
        expect(entity.features.uploadLimit, 180);
      },
    );

    test('request and response DTOs serialize and parse expected shapes', () {
      final request = SubscribeRequestDto(
        plan: 'artist-pro',
        billingCycle: 'yearly',
        paymentMethod: 'card',
        card: {'last4': '1111'},
        trialDays: 7,
      );
      final noCard = SubscribeRequestDto(
        plan: 'artist',
        billingCycle: 'monthly',
        paymentMethod: 'paypal',
      );
      final subscribe = SubscribeResponseDto.fromJson({'message': 'ok'});
      final emptySubscribe = SubscribeResponseDto.fromJson({});
      final cancel = CancelSubscriptionResponseDto.fromJson({
        'message': 'cancelled',
        'expiresAt': 'soon',
      });

      expect(request.toJson(), {
        'plan': 'artist-pro',
        'billingCycle': 'yearly',
        'paymentMethod': 'card',
        'card': {'last4': '1111'},
        'trialDays': 7,
      });
      expect(noCard.toJson().containsKey('card'), isFalse);
      expect(noCard.toJson()['trialDays'], 0);
      expect(subscribe.message, 'ok');
      expect(emptySubscribe.message, '');
      expect(cancel.message, 'cancelled');
      expect(cancel.expiresAt, 'soon');
    });
  });

  group('SubscriptionApi', () {
    late MockDio dio;
    late SubscriptionApi api;

    setUp(() {
      dio = MockDio();
      api = SubscriptionApi(dio);
    });

    Response<Map<String, dynamic>> jsonResponse(
      String path,
      Map<String, dynamic> data,
    ) {
      return Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: path),
        data: data,
        statusCode: 200,
      );
    }

    test('fetches and parses plan list', () async {
      when(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getSubscriptionPlans),
      ).thenAnswer(
        (_) async => jsonResponse(ApiEndpoints.getSubscriptionPlans, {
          'plans': [
            {
              'name': 'artist',
              'monthlyPrice': 99,
              'yearlyPrice': 999,
              'currency': 'EGP',
              'features': {'maxUploads': 360, 'playlistLimit': 20},
            },
          ],
        }),
      );

      final result = await api.getSubscriptionPlans();

      expect(result.single.name, 'artist');
      verify(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getSubscriptionPlans),
      ).called(1);
    });

    test('fetches current subscription', () async {
      when(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getCurrentSubscription),
      ).thenAnswer(
        (_) async => jsonResponse(ApiEndpoints.getCurrentSubscription, {
          'plan': 'free',
          'status': 'active',
          'autoRenew': true,
          'features': {'maxUploads': 180, 'playlistLimit': 3},
        }),
      );

      final result = await api.getCurrentSubscription();

      expect(result.plan, 'free');
      verify(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getCurrentSubscription),
      ).called(1);
    });

    test('posts subscribe and cancel requests', () async {
      final request = SubscribeRequestDto(
        plan: 'artist',
        billingCycle: 'monthly',
        paymentMethod: 'paypal',
      );
      when(
        dio.post<Map<String, dynamic>>(
          ApiEndpoints.subscribe,
          data: request.toJson(),
        ),
      ).thenAnswer(
        (_) async => jsonResponse(ApiEndpoints.subscribe, {'message': 'done'}),
      );
      when(
        dio.post<Map<String, dynamic>>(ApiEndpoints.cancelSubscription),
      ).thenAnswer(
        (_) async => jsonResponse(ApiEndpoints.cancelSubscription, {
          'message': 'cancelled',
          'expiresAt': '2026-05-15',
        }),
      );

      final subscribe = await api.subscribe(request: request);
      final cancel = await api.cancelSubscription();

      expect(subscribe.message, 'done');
      expect(cancel.message, 'cancelled');
      verify(
        dio.post<Map<String, dynamic>>(
          ApiEndpoints.subscribe,
          data: request.toJson(),
        ),
      ).called(1);
      verify(
        dio.post<Map<String, dynamic>>(ApiEndpoints.cancelSubscription),
      ).called(1);
    });
  });

  group('SubscriptionRepositoryImpl', () {
    test('maps API DTOs and builds card subscribe payloads', () async {
      final dio = MockDio();
      final api = SubscriptionApi(dio);
      final repository = SubscriptionRepositoryImpl(api);

      when(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getSubscriptionPlans),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(
            path: ApiEndpoints.getSubscriptionPlans,
          ),
          data: {
            'plans': [
              {
                'name': 'artist-pro',
                'monthlyPrice': 175,
                'yearlyPrice': 1750,
                'currency': 'EGP',
                'features': {'maxUploads': 'unlimited'},
              },
            ],
          },
        ),
      );
      when(
        dio.get<Map<String, dynamic>>(ApiEndpoints.getCurrentSubscription),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(
            path: ApiEndpoints.getCurrentSubscription,
          ),
          data: {
            'plan': 'artist-pro',
            'status': 'active',
            'autoRenew': true,
            'features': {'maxUploads': 'unlimited'},
          },
        ),
      );
      when(
        dio.post<Map<String, dynamic>>(
          ApiEndpoints.subscribe,
          data: {
            'plan': 'artist-pro',
            'billingCycle': 'yearly',
            'paymentMethod': 'card',
            'card': {
              'last4': '1111',
              'brand': 'visa',
              'expiryMonth': 12,
              'expiryYear': 2030,
            },
            'trialDays': 3,
          },
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ApiEndpoints.subscribe),
          data: {'message': 'subscribed'},
        ),
      );
      when(
        dio.post<Map<String, dynamic>>(ApiEndpoints.cancelSubscription),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ApiEndpoints.cancelSubscription),
          data: {'message': 'cancelled', 'expiresAt': 'later'},
        ),
      );

      final plans = await repository.getPlans();
      final current = await repository.getCurrentSubscription();
      final subscribe = await repository.subscribe(
        tier: SubscriptionTier.artistpro,
        billingCycle: BillingCycle.yearly,
        paymentMethod: cardPaymentMethod,
        trialDays: 3,
      );
      final cancel = await repository.cancelSubscription();

      expect(plans.single.tier, SubscriptionTier.artistpro);
      expect(current.tier, SubscriptionTier.artistpro);
      expect(subscribe.message, 'subscribed');
      expect(cancel.message, 'cancelled');
    });

    test('omits card payload for non-card payment method', () async {
      final dio = MockDio();
      final repository = SubscriptionRepositoryImpl(SubscriptionApi(dio));
      when(
        dio.post<Map<String, dynamic>>(
          ApiEndpoints.subscribe,
          data: {
            'plan': 'artist',
            'billingCycle': 'monthly',
            'paymentMethod': 'paypal',
            'trialDays': 0,
          },
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ApiEndpoints.subscribe),
          data: {'message': 'paypal'},
        ),
      );

      final result = await repository.subscribe(
        tier: SubscriptionTier.artist,
        billingCycle: BillingCycle.monthly,
        paymentMethod: const PaymentMethodEntity(
          type: PaymentMethodType.paypal,
        ),
      );

      expect(result.message, 'paypal');
    });
  });
}
