import 'package:intl/intl.dart';

class Account {
  int? id;
  String description;
  double value;
  String dueDate;
  bool paid;

  Account({
    this.id,
    required this.description,
    required this.value,
    required this.dueDate,
    required this.paid,
  });

  Map<String, dynamic> toMap() {
    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateFormat dbFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = dbFormat.format(inputFormat.parse(dueDate));
    return {
      'id': id,
      'description': description,
      'value': value,
      'dueDate': formattedDate,
      'paid': paid ? 1 : 0,
    };
  }
}
