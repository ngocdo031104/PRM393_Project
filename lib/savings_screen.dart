import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'common_widgets.dart';
import 'models.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final totalTarget = state.savingsGoals.fold(0.0, (s, g) => s + g.targetAmount);
    final totalSaved = state.savingsGoals.fold(0.0, (s, g) => s + g.savedAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddGoalSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(totalTarget, totalSaved),
          const SizedBox(height: 8),
          ...state.savingsGoals.map((g) => _buildSavingsGoalCard(context, g)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalTarget, double totalSaved) {
    final pct = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng tiền đang tiết kiệm', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(formatVND(totalSaved), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(pct * 100).toStringAsFixed(1)}% hoàn thành', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
              Text('Mục tiêu: ${formatVND(totalTarget)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard(BuildContext context, SavingsGoal goal) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      'Hạn chót: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                onPressed: () => _showAddFundsSheet(context, goal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(formatVND(goal.savedAmount), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('/ ${formatVND(goal.targetAmount)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: goal.percentage,
              minHeight: 8,
              backgroundColor: AppColors.chipBg,
              valueColor: AlwaysStoppedAnimation(goal.statusColor),
            ),
          ),
          if (goal.isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Chúc mừng! Đã hoàn thành mục tiêu.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Còn thiếu ${formatVND(goal.remainingAmount)}',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    // Placeholder cho chức năng thêm mục tiêu mới
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng tạo mục tiêu mới đang được phát triển')),
    );
  }

  void _showAddFundsSheet(BuildContext context, SavingsGoal goal) {
    if (goal.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mục tiêu này đã hoàn thành!')),
      );
      return;
    }

    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Góp tiền vào quỹ', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
                        Text(goal.name, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Số tiền (₫)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: '0',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0;
                    if (amt > 0) {
                      context.read<AppState>().addFundsToGoal(goal.id, amt);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã góp ${formatVND(amt)} vào ${goal.name}'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Xác nhận góp tiền'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
