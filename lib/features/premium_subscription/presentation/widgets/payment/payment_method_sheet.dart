import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_sheet_notifier.dart';

import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/entities/payment_method_type.dart';
import 'payment_fields.dart';
import 'payment_option.dart';
import 'payment_result.dart';

class PaymentMethodSheet extends ConsumerStatefulWidget {
  const PaymentMethodSheet({
    super.key,
    required this.price,
    required this.onContinue,
  });

  final String price;
  final Future<String> Function(PaymentMethodEntity paymentMethod) onContinue;

  @override
  ConsumerState<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends ConsumerState<PaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(paymentSheetNotifierProvider.notifier).reset();
    });
  }

  String _methodLabel(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.card:
        return 'Credit Card';
      case PaymentMethodType.paypal:
        return 'Paypal';
      case PaymentMethodType.apple:
        return 'Google Pay';
    }
  }

  IconData _methodIcon(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.paypal;
      case PaymentMethodType.apple:
        return Icons.payments;
    }
  }

  Future<void> _continue() async {
    final sheetState = ref.read(paymentSheetNotifierProvider);

    if (sheetState.isProcessing) return;

    if (sheetState.selectedMethod != PaymentMethodType.card) {
      await _submitPayment(
        PaymentMethodEntity(type: sheetState.selectedMethod),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cardNumber = _digitsOnly(_cardNumberController.text);
    final expiryParts = _expiryController.text.split('/');

    await _submitPayment(
      PaymentMethodEntity(
        type: PaymentMethodType.card,
        brand: _detectBrand(cardNumber),
        last4: cardNumber.substring(cardNumber.length - 4),
        expiryMonth: int.parse(expiryParts[0]),
        expiryYear: 2000 + int.parse(expiryParts[1]),
      ),
    );
  }

  Future<void> _submitPayment(PaymentMethodEntity paymentMethod) async {
    final notifier = ref.read(paymentSheetNotifierProvider.notifier);

    notifier.processPayment();

    try {
      final message = await widget.onContinue(paymentMethod);
      notifier.paymentSuccess(message);
    } catch (error) {
      notifier.paymentFailed(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _detectBrand(String cardNumber) {
    final firstDigit = int.tryParse(cardNumber[0]) ?? 0;
    return ((firstDigit % 2) == 1) ? 'visa' : 'mastercard';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetState = ref.watch(paymentSheetNotifierProvider);
    final notifier = ref.read(paymentSheetNotifierProvider.notifier);

    final selectedMethod = sheetState.selectedMethod;
    final isProcessing = sheetState.isProcessing;
    final isSuccessful = sheetState.isSuccessful;
    final resultMessage = sheetState.resultMessage;
    final errorMessage = sheetState.errorMessage;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text(
              isSuccessful
                  ? 'Payment Successful'
                  : errorMessage != null
                  ? 'Payment Failed'
                  : 'Payment method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (isSuccessful)
              PaymentResult(
                responseMessage: resultMessage ?? 'Subscription activated',
                isSuccessful: true,
              )
            else if (errorMessage != null)
              PaymentResult(
                responseMessage: "Couldn't process payment",
                isSuccessful: false,
              )
            else ...[
              Row(
                children: PaymentMethodType.values
                    .map(
                      (method) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: (method == PaymentMethodType.apple) ? 0 : 8,
                          ),
                          child: PaymentOption(
                            label: _methodLabel(method),
                            icon: _methodIcon(method),
                            isSelected: (selectedMethod == method),
                            onTap: () {
                              if (!isProcessing) {
                                ref
                                    .read(paymentSheetNotifierProvider.notifier)
                                    .selectMethod(method);
                              }
                              ;
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 18),

              if (selectedMethod == PaymentMethodType.card)
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: PaymentFields(
                    cardNumberController: _cardNumberController,
                    expiryController: _expiryController,
                    cvvController: _cvvController,
                    cardholderNameController: _cardholderNameController,
                  ),
                )
              else
                Text(
                  '${_methodLabel(selectedMethod)} coming soon.',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: isProcessing
                    ? null
                    : isSuccessful
                    ? () => Navigator.of(context).pop()
                    : errorMessage != null
                    ? notifier.reset
                    : _continue,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: const Color(0xFF3A3A3A),
                  disabledForegroundColor: Colors.white70,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        isSuccessful
                            ? 'Start Exploring'
                            : errorMessage != null
                            ? 'Try Again'
                            : 'Pay Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
