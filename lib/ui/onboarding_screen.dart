import 'package:flutter/material.dart';
import '../repositories/onboarding_repository.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingRepository repo;
  final String displayName;
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.repo, required this.displayName, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Mode { choose, join, solo }

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Mode _mode = _Mode.choose;
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_mode == _Mode.join) {
        await widget.repo.joinFamily(code: _codeCtrl.text.trim(), displayName: widget.displayName);
      } else {
        await widget.repo.createFamily(name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(), displayName: widget.displayName);
      }
      widget.onDone();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mulai')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mode == _Mode.choose) ...[
              FilledButton(key: const Key('mode-join'), onPressed: () => setState(() => _mode = _Mode.join), child: const Text('Gabung keluarga (punya kode)')),
              const SizedBox(height: 12),
              OutlinedButton(key: const Key('mode-solo'), onPressed: () => setState(() => _mode = _Mode.solo), child: const Text('Lanjut sendiri')),
            ],
            if (_mode == _Mode.join)
              TextField(key: const Key('code-field'), controller: _codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Kode keluarga')),
            if (_mode == _Mode.solo)
              TextField(key: const Key('name-field'), controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama keluarga (opsional)')),
            if (_mode != _Mode.choose) ...[
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              FilledButton(key: const Key('onboarding-submit'), onPressed: _busy ? null : _submit, child: Text(_busy ? 'Memproses...' : 'Lanjut')),
              TextButton(onPressed: () => setState(() => _mode = _Mode.choose), child: const Text('Kembali')),
            ],
          ],
        ),
      ),
    );
  }
}
