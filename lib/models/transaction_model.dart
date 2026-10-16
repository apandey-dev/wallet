enum TransactionType { expense, income, transfer }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? note;
  final String icon;
  final String? accountId;
  final String? toAccountId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
    this.icon = 'wallet',
    this.accountId,
    this.toAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'icon': icon,
      'accountId': accountId,
      'toAccountId': toAccountId,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    TransactionType parsedType;
    final typeStr = json['type'] as String?;
    if (typeStr == 'income') {
      parsedType = TransactionType.income;
    } else if (typeStr == 'transfer') {
      parsedType = TransactionType.transfer;
    } else {
      parsedType = TransactionType.expense;
    }

    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ?? 'General',
      type: parsedType,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      icon: json['icon'] as String? ?? 'wallet',
      accountId: json['accountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? note,
    String? icon,
    String? accountId,
    String? toAccountId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      icon: icon ?? this.icon,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
    );
  }
}
