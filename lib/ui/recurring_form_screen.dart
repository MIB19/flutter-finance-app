import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_cubit.dart';
import '../blocs/recurring_bloc.dart';
import '../core/formatting.dart';
import '../models/category.dart';
import '../models/recurring_rule.dart';
import 'widgets/dot_grid_background.dart';

class RecurringFormScreen extends StatefulWidget {
  final RecurringRule? existing;
  const RecurringFormScreen({super.key, this.existing});

  @override
  State<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends State<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TxType _type = TxType.expense;
  String? _categoryId;
  int _dayOfMonth = 1;
  late String _startMonth;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startMonth = monthKeyOf(DateTime.now());
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _categoryId = e.categoryId;
      _nameCtrl.text = e.name;
      _amountCtrl.text = e.amount.toString();
      _dayOfMonth = e.dayOfMonth;
      _startMonth = e.startMonth.substring(0, 7);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kategori Baru'),
        content: TextField(
          key: const Key('new-category-name'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal')),
          TextButton(
            key: const Key('confirm-add-category'),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    final trimmed = name.trim();
    final cubit = context.read<CategoryCubit>();
    await cubit.add(trimmed, _type);
    if (!mounted) return;
    final match = cubit.state.categories
        .where((c) => c.name == trimmed && c.type == _type);
    if (match.isNotEmpty) setState(() => _categoryId = match.first.id);
  }

  Future<void> _pickStartMonth() async {
    final initial = DateTime(int.parse(_startMonth.split('-')[0]),
        int.parse(_startMonth.split('-')[1]), 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startMonth = monthKeyOf(picked));
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      if (_categoryId == null) setState(() => _error = 'Pilih kategori');
      return;
    }
    setState(() => _error = null);
    final existing = widget.existing;
    if (existing != null) {
      context.read<RecurringBloc>().add(RecurringUpdated(existing.id, {
            'name': _nameCtrl.text,
            'amount': int.parse(_amountCtrl.text),
            'dayOfMonth': _dayOfMonth,
            'categoryId': _categoryId,
            'type': txTypeToString(_type),
          }));
    } else {
      context.read<RecurringBloc>().add(RecurringCreated(
            categoryId: _categoryId!,
            name: _nameCtrl.text,
            amount: int.parse(_amountCtrl.text),
            type: _type,
            dayOfMonth: _dayOfMonth,
            startMonth: _startMonth,
          ));
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    final existing = widget.existing;
    if (existing == null) return;
    context.read<RecurringBloc>().add(RecurringDeleted(existing.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final categories = context
        .watch<CategoryCubit>()
        .state
        .categories
        .where((c) => c.type == _type)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit' : 'Pengeluaran Tetap Baru')),
      body: DotGridBackground(
        light: true,
        child: Form(
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
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  _categoryId = null;
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('rule-name'),
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('rule-amount'),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('category-field'),
                      value: _categoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: categories
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                  IconButton(
                    key: const Key('add-category'),
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Kategori baru',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const Key('day-of-month-field'),
                value: _dayOfMonth,
                decoration:
                    const InputDecoration(labelText: 'Tanggal tiap bulan'),
                items: List.generate(31, (i) => i + 1)
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text(d.toString())))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _dayOfMonth = v ?? _dayOfMonth),
              ),
              const SizedBox(height: 12),
              ListTile(
                key: const Key('start-month-field'),
                title: const Text('Mulai bulan'),
                subtitle: Text(monthLabel(_startMonth)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartMonth,
              ),
              if (_error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('save-rule'),
                onPressed: _save,
                child: const Text('Simpan'),
              ),
              if (isEdit) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('delete-rule'),
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Hapus'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
