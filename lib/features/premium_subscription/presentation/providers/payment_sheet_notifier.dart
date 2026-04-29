import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_method_type.dart';
import 'payment_sheet_state.dart';

final paymentSheetNotifierProvider =
    NotifierProvider<PaymentSheetNotifier, PaymentSheetState>(
  PaymentSheetNotifier.new,
);

class PaymentSheetNotifier extends Notifier<PaymentSheetState> {
  @override
  PaymentSheetState build() => const PaymentSheetState();

  void selectMethod(PaymentMethodType method) {
    state = state.copyWith(
      selectedMethod: method,
      errorMessage: null,
      resultMessage: null,
    );
  }

  void processPayment() {
    state = state.copyWith(
      isProcessing: true,
      isSuccessful: false,
      errorMessage: null,
      resultMessage: null,
    );
  }

  void paymentSuccess(String message) {
    state = state.copyWith(
      isProcessing: false,
      isSuccessful: true,
      resultMessage: message,
      errorMessage: null,
    );
  }

  void paymentFailed(String error) {
    state = state.copyWith(
      isProcessing: false,
      isSuccessful: false,
      errorMessage: error,
      resultMessage: null,
    );
  }

  void reset() {
    state = const PaymentSheetState();
  }
}