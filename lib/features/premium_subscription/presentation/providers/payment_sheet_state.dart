import '../../domain/entities/payment_method_type.dart';

class PaymentSheetState {
  final PaymentMethodType selectedMethod;
  final bool isProcessing;
  final bool isSuccessful;
  final String? resultMessage;
  final String? errorMessage;

  const PaymentSheetState({
    this.selectedMethod = PaymentMethodType.card,
    this.isProcessing = false,
    this.isSuccessful = false,
    this.resultMessage,
    this.errorMessage,
  });

  PaymentSheetState copyWith({
    PaymentMethodType? selectedMethod,
    bool? isProcessing,
    bool? isSuccessful,
    String? resultMessage,
    String? errorMessage,
  }) {
    return PaymentSheetState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      resultMessage: resultMessage,
      errorMessage: errorMessage,
    );
  }
}