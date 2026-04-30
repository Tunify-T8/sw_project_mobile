import 'package:flutter/material.dart';

class PaymentFields extends StatelessWidget {
  const PaymentFields({
    super.key,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.cardholderNameController,
  });

  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController cardholderNameController;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      errorStyle: const TextStyle(color: Color(0xFFFF8A65)),
      filled: true,
      fillColor: const Color(0xFF181818),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF343434)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF5500)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF8A65)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF8A65)),
      ),
    );
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: const Key('payment_card_number_field'),
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFFFF5500),
          decoration: _inputDecoration('Card Number'),
          validator: (value) {
            final digits = _digitsOnly(value ?? '');

            if (digits.isEmpty) return 'Card number is required';
            if (digits.length < 13 || digits.length > 19) {
              return 'Card number must be 13-19 digits';
            }

            return null;
          },
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                key: const Key('payment_expiry_field'),
                controller: expiryController,
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFFFF5500),
                decoration: _inputDecoration('Expiry Date (MM/YY)'),
                validator: (value) {
                  final expiry = value?.trim() ?? '';
                  final match = RegExp(
                    r'^(0[1-9]|1[0-2])\/(\d{2})$',
                  ).firstMatch(expiry);

                  if (expiry.isEmpty) return 'Expiry is required';
                  if (match == null) return 'Use MM/YY';

                  final month = int.parse(match.group(1)!);
                  final year = 2000 + int.parse(match.group(2)!);
                  final now = DateTime.now();
                  final expiryDate = DateTime(year, month + 1, 0);

                  if (expiryDate.isBefore(
                    DateTime(now.year, now.month, now.day),
                  )) {
                    return 'Card is expired';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              flex: 4,
              child: TextFormField(
                key: const Key('payment_cvv_field'),
                controller: cvvController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFFFF5500),
                decoration: _inputDecoration('CVV'),
                validator: (value) {
                  final digits = _digitsOnly(value ?? '');

                  if (digits.isEmpty) return 'CVV is required';
                  if (digits.length != 3) return 'CVV must be 3 digits';

                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        TextFormField(
          key: const Key('payment_cardholder_name_field'),
          controller: cardholderNameController,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFFFF5500),
          decoration: _inputDecoration('Cardholder Name'),
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Cardholder name is required';
            }

            return null;
          },
        ),
      ],
    );
  }
}
