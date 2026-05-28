import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/finance_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'Food';

  static const _categories = ['Food', 'Transport', 'Education', 'Health', 'Entertainment', 'Rent', 'Savings', 'Other'];

  Future<void> _add() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;
    await ref.read(financeProvider.notifier).add(
      type: _type,
      category: _category,
      amount: amount,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
    );
    _amountCtrl.clear();
    _noteCtrl.clear();
  }

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(financeProvider);
    final summary = ref.read(financeProvider.notifier).monthlySummary;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20)),
                      const SizedBox(width: 12),
                      SLText('◈ FINANCE TRACKER', style: SLType.headline(size: 18)),
                    ],
                  ),
                ),
              ),
              // Summary row
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _SummaryCard(label: 'INCOME', value: summary['income']!, color: SLColors.success),
                      const SizedBox(width: 8),
                      _SummaryCard(label: 'EXPENSE', value: summary['expense']!, color: SLColors.danger),
                      const SizedBox(width: 8),
                      _SummaryCard(label: 'NET', value: summary['net']!,
                          color: summary['net']! >= 0 ? SLColors.success : SLColors.danger),
                    ],
                  ),
                ),
              ),
              // Add entry form
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: SystemPanel(
                    child: Column(
                      children: [
                        Row(children: ['income', 'expense', 'saving'].map((t) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _type == t ? SLColors.glowCore : SLColors.textDim,
                                ),
                              ),
                              child: SLText(t.toUpperCase(),
                                style: SLType.sysLabel(size: 8,
                                    color: _type == t ? SLColors.glowCore : SLColors.textMid),
                                align: TextAlign.center),
                            ),
                          ),
                        )).toList()),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: SLType.hudNum(size: 22, color: SLColors.textBright),
                          decoration: InputDecoration(hintText: '0.00', prefixText: '₹ '),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          dropdownColor: SLColors.panelMid,
                          style: SLType.body(color: SLColors.textBright),
                          decoration: const InputDecoration(),
                          items: _categories.map((c) => DropdownMenuItem(value: c,
                            child: SLText(c, style: SLType.body(color: SLColors.textBright)))).toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteCtrl,
                          style: SLType.body(color: SLColors.textBright),
                          decoration: InputDecoration(hintText: 'NOTE (OPTIONAL)'),
                        ),
                        const SizedBox(height: 12),
                        SystemButton(label: '◈ LOG ENTRY', onTap: _add, width: double.infinity),
                      ],
                    ),
                  ),
                ),
              ),
              // Transaction list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final e = entries[i];
                      final color = e.type == 'income' ? SLColors.success
                          : e.type == 'saving' ? SLColors.xpBright : SLColors.danger;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SystemPanel(
                          glowColor: color,
                          glowIntensity: 0.2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SLText(e.category, style: SLType.body(size: 13, color: SLColors.textBright)),
                                  if (e.note != null) SLText(e.note!, style: SLType.body(size: 11, color: SLColors.textMid)),
                                  SLText(e.date, style: SLType.body(size: 11, color: SLColors.textDim)),
                                ],
                              )),
                              SLText(
                                '${e.type == 'expense' ? '-' : '+'}₹${e.amount.round()}',
                                style: SLType.hudNum(size: 16, color: color),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              ),
              SliverPadding(padding: const EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: SystemPanel(
      glowColor: color,
      glowIntensity: 0.4,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          SLText('₹${value.abs().round()}', style: SLType.hudNum(size: 16, color: color)),
          SLText(label, style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
        ],
      ),
    ),
  );
}
