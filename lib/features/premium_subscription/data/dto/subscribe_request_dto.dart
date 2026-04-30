class SubscribeRequestDto {
  final String plan;
  final String billingCycle;
  final String paymentMethod;
  final Map<String, dynamic>? card;
  final int trialDays;

  SubscribeRequestDto({
    required this.plan,
    required this.billingCycle,
    required this.paymentMethod,
    this.card,
    this.trialDays = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'billingCycle': billingCycle,
      'paymentMethod': paymentMethod,
      if (card != null) 'card': card,
      'trialDays': trialDays,
    };
  }
}
