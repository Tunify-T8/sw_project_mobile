import 'package:flutter/material.dart';

import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/entities/payment_method_type.dart';
import 'payment_fields.dart';
import 'payment_option.dart';

class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({
    super.key,
    required this.price,
    required this.onContinue,
  });

  final String price;
  final Future<String> Function(PaymentMethodEntity paymentMethod) onContinue;

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  PaymentMethodType _selectedMethod = PaymentMethodType.card;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _resultMessage;
  String? _errorMessage;

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

  void _selectMethod(PaymentMethodType method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  Future<void> _continue() async {
    if (_isProcessing) return;

    if (_selectedMethod != PaymentMethodType.card) {
      await _submitPayment(PaymentMethodEntity(type: _selectedMethod));
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
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _resultMessage = null;
    });

    try {
      final message = await widget.onContinue(paymentMethod);
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _resultMessage = message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _tryAgain() {
    setState(() {
      _errorMessage = null;
      _resultMessage = null;
      _isSuccess = false;
      _isProcessing = false;
    });
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text(
              _isSuccess
                  ? 'Payment Successful'
                  : _errorMessage != null
                      ? 'Payment Failed'
                      : 'Payment method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (_isSuccess)
              _PaymentSuccessView(
                message: _resultMessage ?? 'Subscription activated',
              )
            else if (_errorMessage != null)
              _PaymentErrorView(message: _errorMessage!)
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
                            isSelected: (_selectedMethod == method),
                            onTap: () {
                              if (!_isProcessing) _selectMethod(method);
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 18),

              if (_selectedMethod == PaymentMethodType.card)
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
                  '${_methodLabel(_selectedMethod)} coming soon.',
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
                onPressed: _isProcessing
                    ? null
                    : _isSuccess
                        ? () => Navigator.of(context).pop()
                        : _errorMessage != null
                            ? _tryAgain
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
                child: _isProcessing
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
                        _isSuccess
                            ? 'Start Exploring'
                            : _errorMessage != null
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

class _PaymentSuccessView extends StatelessWidget {
  const _PaymentSuccessView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const features = [
      'Ad-free listening',
      'Offline listening',
      'Expanded upload limits',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(
            Icons.check_circle,
            color: Color(0xFF2ECC71),
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlocked features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final feature in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Color(0xFFFF5500),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentErrorView extends StatelessWidget {
  const _PaymentErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(
            Icons.error,
            color: Color(0xFFFF6B6B),
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}
