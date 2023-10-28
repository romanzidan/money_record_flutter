import 'package:intl/intl.dart';

class AppFormat {
  static String date(String stringDate) {
    // 2023-12-25
    DateTime dateTime = DateTime.parse(stringDate);
    return DateFormat('d MMM yyyy', 'id_ID')
        .format(dateTime); // ex : 25 Des 2023
  }
}
