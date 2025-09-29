import 'package:intl/intl.dart';

class DateUtils {
  // Metode untuk memformat DateTime menjadi string tanggal yang mudah dibaca
  static String formatDate(DateTime date) {
    // Anda bisa menyesuaikan formatnya di sini
    return DateFormat('dd MMMM yyyy').format(date);
  }
}