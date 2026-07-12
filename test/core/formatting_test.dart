import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:keuangan_app/core/formatting.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('formatRupiah', () {
    test('formats with thousands separators and Rp prefix', () {
      expect(formatRupiah(3000000), 'Rp3.000.000');
      expect(formatRupiah(0), 'Rp0');
    });
    test('formats negatives with a leading minus', () {
      expect(formatRupiah(-50000), '-Rp50.000');
    });
  });

  group('monthKey helpers', () {
    test('monthKeyOf returns YYYY-MM', () {
      expect(monthKeyOf(DateTime(2026, 7, 5)), '2026-07');
    });
    test('addMonths shifts across year boundary', () {
      expect(addMonths('2026-12', 1), '2027-01');
      expect(addMonths('2026-01', -1), '2025-12');
    });
    test('monthLabel is human readable', () {
      expect(monthLabel('2026-07'), 'Juli 2026');
    });
  });
}
