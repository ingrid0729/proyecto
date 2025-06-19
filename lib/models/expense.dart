class Expense {
  final int? id;
  final int userId;
  final double amount;
  final String description;
  final String date;
  final String category;

  Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'description': description,
        'date': date,
        'category': category,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        userId: map['userId'],
        amount: map['amount'],
        description: map['description'],
        date: map['date'],
        category: map['category'],
      );
}
