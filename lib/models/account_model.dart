class Account {
  int id;
  String description;
  double value;
  String dueDate;
  bool paid;

  Account({
    required this.id,
    required this.description,
    required this.value,
    required this.dueDate,
    required this.paid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'dueDate': dueDate,
      'paid': paid ? 1 : 0,
    };
  }
}
