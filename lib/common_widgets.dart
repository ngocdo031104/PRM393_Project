import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';
import 'models.dart';

final _vnd = NumberFormat('#,###', 'vi_VN');

String formatVND(double amount) => '${_vnd.format(amount.toInt())} ₫';

// ── Common Card ──────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 20.0,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? AppColors.border, width: borderWidth),
        boxShadow: hasShadow
            ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}

// ── Section header ────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
      ],
    );
  }
}

// ── Balance Card ────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  final double balance, income, expense;
  const BalanceCard({super.key, required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng số dư', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(formatVND(balance), style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SubItem(label: 'Thu nhập', amount: income, icon: Icons.arrow_downward)),
              const SizedBox(width: 12),
              Expanded(child: _SubItem(label: 'Chi tiêu', amount: expense, icon: Icons.arrow_upward)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  const _SubItem({required this.label, required this.amount, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
          ]),
          const SizedBox(height: 8),
          Text(formatVND(amount), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

// ── Transaction Item ───────────────────────────────────
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: transaction.categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(transaction.categoryEmoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.category} • ${DateFormat('HH:mm, dd/MM').format(transaction.date)}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${formatVND(transaction.amount)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Budget Progress Card ───────────────────────────────
class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  const BudgetProgressCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: budget.isDanger ? AppColors.error.withOpacity(0.02) : AppColors.surface,
      borderColor: budget.isDanger ? AppColors.error.withOpacity(0.5) : AppColors.border,
      borderWidth: budget.isDanger ? 1.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(budget.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('01/06 — 30/06', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: budget.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${(budget.percentage * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: budget.statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(formatVND(budget.spent), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('/ ${formatVND(budget.limit)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: budget.percentage,
              minHeight: 8,
              backgroundColor: AppColors.chipBg,
              valueColor: AlwaysStoppedAnimation(budget.statusColor),
            ),
          ),
          if (budget.isDanger) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Gần vượt ngân sách! Còn ${formatVND(budget.remaining)}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? change;
  final bool isPositive;
  final Color? valueColor;

  const StatCard({super.key, required this.label, required this.value, this.change, this.isPositive = true, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      hasShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor ?? AppColors.textPrimary)),
          if (change != null) ...[
            const SizedBox(height: 2),
            Text(change!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isPositive ? AppColors.success : AppColors.error)),
          ],
        ],
      ),
    );
  }
}

// ── AI Insight Card ─────────────────────────────────────
class AiInsightCard extends StatelessWidget {
  final String title;
  final String body;
  const AiInsightCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFE0F2FE)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF1D4ED8)),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1D4ED8))),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF374151), height: 1.5)),
        ],
      ),
    );
  }
}

// ── Sync Status Bar ──────────────────────────────────────
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Đã đồng bộ', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          Text('2 phút trước', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Category Chip ────────────────────────────────────────
class FilterChip2 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChip2({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.chipBg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}