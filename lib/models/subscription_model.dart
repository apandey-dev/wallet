enum BillingCycle { monthly, yearly }

class SubscriptionModel {
  final String id;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextRenewalDate;
  final String category;
  final String icon;
  final bool isActive;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextRenewalDate,
    this.category = 'Subscriptions',
    this.icon = 'sub',
    this.isActive = true,
  });

  int get daysUntilRenewal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      nextRenewalDate.year,
      nextRenewalDate.month,
      nextRenewalDate.day,
    );
    return target.difference(today).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle.name,
      'nextRenewalDate': nextRenewalDate.toIso8601String(),
      'category': category,
      'icon': icon,
      'isActive': isActive,
    };
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingCycle: json['billingCycle'] == 'yearly'
          ? BillingCycle.yearly
          : BillingCycle.monthly,
      nextRenewalDate: DateTime.parse(json['nextRenewalDate'] as String),
      category: json['category'] as String? ?? 'Subscriptions',
      icon: json['icon'] as String? ?? 'sub',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  SubscriptionModel copyWith({
    String? id,
    String? name,
    double? amount,
    BillingCycle? billingCycle,
    DateTime? nextRenewalDate,
    String? category,
    String? icon,
    bool? isActive,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
