import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _auth = AuthService();
  final _api = const ApiService();

  bool _loading = false;
  num? _result;
  String? _lastOp;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  Future<void> _run(String operation, String label) async {
    final a = num.tryParse(_a.text.trim());
    final b = num.tryParse(_b.text.trim());
    if (a == null || b == null) {
      _showError('Enter two valid numbers first.');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await _api.calculate(operation, a, b);
      setState(() {
        _result = result;
        _lastOp = label;
      });
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not reach the server. Is the backend running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? 'Signed in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Signed in as $email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  _NumberField(controller: _a, label: 'First number'),
                  const SizedBox(height: 16),
                  _NumberField(controller: _b, label: 'Second number'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _OpButton(label: 'Add', symbol: '+', onTap: _loading ? null : () => _run('add', 'Add')),
                      const SizedBox(width: 12),
                      _OpButton(label: 'Subtract', symbol: '−', onTap: _loading ? null : () => _run('subtract', 'Subtract')),
                      const SizedBox(width: 12),
                      _OpButton(label: 'Multiply', symbol: '×', onTap: _loading ? null : () => _run('multiply', 'Multiply')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Center(
                        child: _loading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  Text(
                                    _lastOp == null ? 'Result' : '$_lastOp result',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _result == null ? '—' : '$_result',
                                    style: Theme.of(context).textTheme.displaySmall,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _OpButton extends StatelessWidget {
  const _OpButton({required this.label, required this.symbol, required this.onTap});

  final String label;
  final String symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
        child: Column(
          children: [
            Text(symbol, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
