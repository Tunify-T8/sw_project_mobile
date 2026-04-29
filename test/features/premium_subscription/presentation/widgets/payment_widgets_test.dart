import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_type.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_fields.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_method_sheet.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_option.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_result.dart';

Future<void> pumpMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(backgroundColor: Colors.black, body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('payment option renders selected and responds to tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: PaymentOption(
            key: const Key('option'),
            label: 'Credit Card',
            icon: Icons.credit_card,
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('option')), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
    await tester.tap(find.byKey(const Key('option')));
    expect(tapped, isTrue);
  });

  testWidgets('payment fields validate required and malformed card input', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final card = TextEditingController();
    final expiry = TextEditingController();
    final cvv = TextEditingController();
    final name = TextEditingController();
    addTearDown(card.dispose);
    addTearDown(expiry.dispose);
    addTearDown(cvv.dispose);
    addTearDown(name.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Form(
            key: formKey,
            child: PaymentFields(
              cardNumberController: card,
              expiryController: expiry,
              cvvController: cvv,
              cardholderNameController: name,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Card number is required'), findsOneWidget);
    expect(find.text('Expiry is required'), findsOneWidget);
    expect(find.text('CVV is required'), findsOneWidget);
    expect(find.text('Cardholder name is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('payment_card_number_field')),
      '123',
    );
    await tester.enterText(
      find.byKey(const Key('payment_expiry_field')),
      '13/20',
    );
    await tester.enterText(find.byKey(const Key('payment_cvv_field')), '12');
    await tester.enterText(
      find.byKey(const Key('payment_cardholder_name_field')),
      'Ada',
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Card number must be 13-19 digits'), findsOneWidget);
    expect(find.text('Use MM/YY'), findsOneWidget);
    expect(find.text('CVV must be 3 digits'), findsOneWidget);
  });

  testWidgets('payment fields accept valid card input', (tester) async {
    final formKey = GlobalKey<FormState>();
    final card = TextEditingController(text: '4111111111111111');
    final expiry = TextEditingController(text: '12/30');
    final cvv = TextEditingController(text: '123');
    final name = TextEditingController(text: 'Ada Lovelace');
    addTearDown(card.dispose);
    addTearDown(expiry.dispose);
    addTearDown(cvv.dispose);
    addTearDown(name.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Form(
            key: formKey,
            child: PaymentFields(
              cardNumberController: card,
              expiryController: expiry,
              cvvController: cvv,
              cardholderNameController: name,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('payment result renders success and failure states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: PaymentResult(responseMessage: 'Welcome', isSuccessful: true),
        ),
      ),
    );

    expect(find.byKey(const Key('payment_result_message')), findsOneWidget);
    expect(
      find.byKey(const Key('payment_unlocked_features_title')),
      findsOneWidget,
    );
    expect(find.text('Ad-free listening'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: PaymentResult(
            responseMessage: "Couldn't process payment",
            isSuccessful: false,
          ),
        ),
      ),
    );

    expect(find.text("Couldn't process payment"), findsOneWidget);
    expect(
      find.byKey(const Key('payment_unlocked_features_title')),
      findsNothing,
    );
  });

  testWidgets('payment sheet submits non-card method immediately', (
    tester,
  ) async {
    PaymentMethodEntity? submitted;

    await pumpMaterial(
      tester,
      PaymentMethodSheet(
        price: 'EGP 99.00/month',
        onContinue: (method) async {
          submitted = method;
          return 'Paid with wallet';
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('payment_method_option_paypal')));
    await tester.pump();
    expect(
      find.byKey(const Key('payment_method_unavailable_paypal')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pumpAndSettle();

    expect(submitted?.type, PaymentMethodType.paypal);
    expect(find.byKey(const Key('payment_success_result')), findsOneWidget);
    expect(find.text('Paid with wallet'), findsOneWidget);
  });

  testWidgets('payment sheet validates and submits card details', (
    tester,
  ) async {
    PaymentMethodEntity? submitted;

    await pumpMaterial(
      tester,
      PaymentMethodSheet(
        price: 'EGP 175.00/month',
        onContinue: (method) async {
          submitted = method;
          return 'Subscription activated';
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pump();
    expect(find.text('Card number is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('payment_card_number_field')),
      '4111111111111111',
    );
    await tester.enterText(
      find.byKey(const Key('payment_expiry_field')),
      '12/30',
    );
    await tester.enterText(find.byKey(const Key('payment_cvv_field')), '123');
    await tester.enterText(
      find.byKey(const Key('payment_cardholder_name_field')),
      'Ada Lovelace',
    );
    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pumpAndSettle();

    expect(submitted?.type, PaymentMethodType.card);
    expect(submitted?.brand, 'mastercard');
    expect(submitted?.last4, '1111');
    expect(submitted?.expiryMonth, 12);
    expect(submitted?.expiryYear, 2030);
    expect(find.byKey(const Key('payment_success_result')), findsOneWidget);
  });

  testWidgets('payment sheet shows failure and can reset', (tester) async {
    var attempts = 0;

    await pumpMaterial(
      tester,
      PaymentMethodSheet(
        price: 'EGP 175.00/month',
        onContinue: (_) async {
          attempts++;
          throw Exception('declined');
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('payment_method_option_paypal')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(find.byKey(const Key('payment_error_result')), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pump();
    expect(find.byKey(const Key('payment_error_result')), findsNothing);
    expect(find.byKey(const Key('payment_method_option_card')), findsOneWidget);
  });
}
