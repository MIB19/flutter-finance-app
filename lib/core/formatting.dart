import 'package:intl/intl.dart';

final _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int amount) {
  final abs = _rp.format(amount.abs());
  return amount < 0 ? '-$abs' : abs;
}

String monthKeyOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

String addMonths(String ym, int delta) {
  final parts = ym.split('-');
  final base = DateTime(int.parse(parts[0]), int.parse(parts[1]) + delta, 1);
  return monthKeyOf(base);
}

String monthLabel(String ym) {
  final parts = ym.split('-');
  final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  return DateFormat.yMMMM('id_ID').format(d);
}
