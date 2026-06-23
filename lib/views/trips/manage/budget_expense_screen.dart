import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_extras.dart';
import 'package:travel_app/models/trip_model.dart';

class BudgetExpenseScreen extends StatefulWidget {
  const BudgetExpenseScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<BudgetExpenseScreen> createState() => _BudgetExpenseScreenState();
}

class _BudgetExpenseScreenState extends State<BudgetExpenseScreen> {
  final TripController c = Get.find<TripController>();

  static const _categories = [
    'Food',
    'Transport',
    'Stay',
    'Activity',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Budget & expenses'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final budget = widget.trip.details?.budget ?? 0.0;
          final spent = c.totalExpenses(widget.trip.id ?? '');
          final remaining = budget - spent;
          final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
          final items = c.expensesFor(widget.trip.id ?? '');

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 16),
                child: _BudgetCard(
                  budget: budget,
                  spent: spent,
                  remaining: remaining,
                  pct: pct,
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(k_pad, 0, k_pad, 10),
                  child: Row(
                    children: const [
                      OverlineText('TRANSACTIONS'),
                      Spacer(),
                    ],
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  gradient: k_gradPrimary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 40),
                              ),
                              const SizedBox(height: 18),
                              const HeadlineText(
                                  'No expenses logged yet'),
                              const SizedBox(height: 6),
                              const MutedText(
                                'Add expenses to keep an eye on your trip budget.',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            k_pad, 0, k_pad, 120),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ExpenseTile(
                          item: items[i],
                          onDelete: () => c.removeExpense(items[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: _showAddDialog,
            child: Ink(
              decoration: BoxDecoration(
                gradient: k_gradAccent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: k_accent.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  CustomText(
                    text: 'Add expense',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final labelC = TextEditingController();
    final amountC = TextEditingController();
    String category = _categories.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(k_radLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadlineText('Add expense'),
                const SizedBox(height: 14),
                TextField(
                  controller: labelC,
                  style: TextStyle(
                      color: AppColors.textDark, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    prefixIcon: Icon(Icons.label_outline_rounded,
                        size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: TextStyle(
                      color: AppColors.textDark, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    prefixIcon:
                        Icon(Icons.attach_money_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 14),
                CustomText(
                  text: 'Category',
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final selected = cat == category;
                    return GestureDetector(
                      onTap: () => setLocal(() => category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.textDark : AppColors.field,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CustomText(
                          text: cat,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textBody,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        variant: CustomButtonVariant.ghost,
                        color: AppColors.textMuted,
                        height: 48,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Add',
                        height: 48,
                        onPressed: () {
                          final amt = double.tryParse(amountC.text);
                          if (labelC.text.trim().isEmpty ||
                              amt == null ||
                              amt <= 0) return;
                          c.addExpense(ExpenseItem(
                            tripId: widget.trip.id ?? '',
                            label: labelC.text.trim(),
                            amount: amt,
                            category: category,
                            date: DateTime.now(),
                          ));
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.pct,
  });
  final double budget;
  final double spent;
  final double remaining;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isOver = remaining < 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(k_radLg),
        gradient: isOver ? null : k_gradPrimary,
        color: isOver ? k_error : null,
        boxShadow: [
          BoxShadow(
            color: (isOver ? k_error : k_primary).withOpacity(0.3),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassChip(
                label: 'BUDGET',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const Spacer(),
              if (budget > 0)
                GlassChip(
                  label: '${(pct * 100).toStringAsFixed(0)}%',
                  icon: Icons.percent_rounded,
                ),
            ],
          ),
          const SizedBox(height: 18),
          CustomText(
            text:
                '\$${(budget > 0 ? remaining : -spent).abs().toStringAsFixed(2)}',
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: budget <= 0
                ? 'Spent so far'
                : (isOver ? 'Over budget' : 'Remaining'),
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('Spent', '\$${spent.toStringAsFixed(2)}'),
              _stat('Budget',
                  budget > 0 ? '\$${budget.toStringAsFixed(2)}' : '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        const SizedBox(height: 2),
        CustomText(
          text: value,
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.item, required this.onDelete});
  final ExpenseItem item;
  final VoidCallback onDelete;

  IconData get _icon {
    switch (item.category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_filled_rounded;
      case 'Stay':
        return Icons.hotel_rounded;
      case 'Activity':
        return Icons.local_activity_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color get _tint {
    switch (item.category) {
      case 'Food':
        return const Color(0xFFFF7B5A);
      case 'Transport':
        return const Color(0xFF6C5CE7);
      case 'Stay':
        return const Color(0xFF0F766E);
      case 'Activity':
        return const Color(0xFFFFB347);
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tint.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: _tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(item.label, maxLines: 1),
                const SizedBox(height: 2),
                MutedText(
                  '${item.category} · ${DateFormat('MMM d').format(item.date)}',
                ),
              ],
            ),
          ),
          CustomText(
            text: '-\$${item.amount.toStringAsFixed(2)}',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 16, color: AppColors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
