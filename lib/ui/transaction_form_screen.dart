import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_cubit.dart';
import '../core/formatting.dart';
import '../models/category.dart';
import '../repositories/transaction_repository.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionRepository txRepo;
  final VoidCallback onSaved;
  const TransactionFormScreen({super.key, required this.txRepo, required this.onSaved});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TxType _type = TxType.expense;
  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      if (_categoryId == null) setState(() => _error = 'Pilih kategori');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await widget.txRepo.create(
        categoryId: _categoryId!,
        amount: int.parse(_amountCtrl.text),
        type: _type,
        occurredOn: '${monthKeyOf(_date)}-${_date.day.toString().padLeft(2, '0')}',
        note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      );
      widget.onSaved();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state.categories.where((c) => c.type == _type).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TxType>(
              segments: const [
                ButtonSegment(value: TxType.expense, label: Text('Keluar')),
                ButtonSegment(value: TxType.income, label: Text('Masuk')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() { _type = s.first; _categoryId = null; }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('amount-field'),
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Nominal harus angka > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('category-field'),
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Tanggal'),
              subtitle: Text('${monthKeyOf(_date)}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (picked != null) setState(() => _date = picked);
              },
            ),
            TextFormField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-tx'),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
