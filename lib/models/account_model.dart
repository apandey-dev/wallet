class AccountModel {
  final String id;
  final String name;
  final double balance;
  final String type; // 'bank', 'cash', 'savings', 'wallet'
  final String icon;
  final String colorHex;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    this.type = 'bank',
    this.icon = 'wallet',
    this.colorHex = '#111827',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
      'icon': icon,
      'colorHex': colorHex,
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] as String? ?? 'bank',
      icon: json['icon'] as String? ?? 'wallet',
      colorHex: json['colorHex'] as String? ?? '#111827',
    );
  }

  AccountModel copyWith({
    String? id,
    String? name,
    double? balance,
    String? type,
    String? icon,
    String? colorHex,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
