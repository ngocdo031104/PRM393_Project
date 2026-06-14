import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../common_widgets.dart';
import '../models.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final totalBudget = state.budgets.fold(0.0, (s, b) => s + b.limit);
    final totalSpent = state.budgets.fold(0.0, (s, b) => s + b.spent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddBudgetSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(totalBudget, totalSpent),
          const SizedBox(height: 8),
          ...state.budgets.map((b) => BudgetProgressCard(budget: b)),
          const SizedBox(height: 8),
          _buildAiTip(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total, double spent) {
    final pct = spent / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng ngân sách tháng 6', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(formatVND(total), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
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
              Text('Đã chi: ${formatVND(spent)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
              Text('Còn: ${formatVND(total - spent)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiTip() {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderColor: const Color(0xFFBFDBFE),
      borderWidth: 1.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 20, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trợ lý AI', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A))),
                const SizedBox(height: 6),
                Text(
                  'Ngân sách Giải trí của bạn gần đạt giới hạn (95%). Hãy tránh thêm chi tiêu giải trí trong tuần này nhé! 💡',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF4B5563), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            Text('Thêm ngân sách mới', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text('Danh mục', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(),
              items: kCategories.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.emoji} ${c.name}'))).toList(),
              onChanged: (_) {},
              hint: const Text('Chọn danh mục'),
            ),
            const SizedBox(height: 12),
            Text('Số tiền giới hạn', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Nhập số tiền (₫)', suffixText: '₫'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tạo ngân sách'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}