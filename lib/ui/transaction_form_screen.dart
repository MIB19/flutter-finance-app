import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_cubit.dart';
import '../blocs/dashboard_cubit.dart';
import '../blocs/month_bloc.dart';
import '../core/formatting.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'widgets/dot_grid_background.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionRepository txRepo;
  final Transaction? existing;
  const TransactionFormScreen({super.key, required this.txRepo, this.existing});

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
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _categoryId = e.categoryId;
      _amountCtrl.text = e.amount.toString();
      _noteCtrl.text = e.note ?? '';
      _date = DateTime.parse(e.occurredOn);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _refreshAndPop() {
    if (!mounted) return;
    final ym = context.read<MonthBloc>().state.ym;
    context.read<MonthBloc>().add(MonthRequested(ym));
    context.read<DashboardCubit>().load(ym);
    Navigator.of(context).pop(true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      if (_categoryId == null) setState(() => _error = 'Pilih kategori');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final occurredOn =
          '${monthKeyOf(_date)}-${_date.day.toString().padLeft(2, '0')}';
      final existing = widget.existing;
      if (existing != null) {
        await widget.txRepo.update(existing.id, {
          'categoryId': _categoryId,
          'amount': int.parse(_amountCtrl.text),
          'type': txTypeToString(_type),
          'occurredOn': occurredOn,
          'note': _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        });
      } else {
        await widget.txRepo.create(
          categoryId: _categoryId!,
          amount: int.parse(_amountCtrl.text),
          type: _type,
          occurredOn: occurredOn,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        );
      }
      _refreshAndPop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.txRepo.remove(existing.id);
      _refreshAndPop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
      appBar: AppBar(title: Text(isEdit ? 'Edit' : 'Transaksi')),
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
              ListTile(
                title: const Text('Tanggal'),
                subtitle: Text(
                    '${monthKeyOf(_date)}-${_date.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100));
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              TextFormField(
                  controller: _noteCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Catatan (opsional)')),
              if (_error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('save-tx'),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
              ),
              if (isEdit) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('delete-tx'),
                  onPressed: _saving ? null : _delete,
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
