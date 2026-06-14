import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildGreeting(context, state),
                  const SizedBox(height: 12),
                  const SyncStatusBar(),
                  BalanceCard(
                    balance: state.totalBalance,
                    income: state.monthlyIncome,
                    expense: state.monthlyExpense,
                  ),
                  _buildHealthScore(),
                  _buildBudgetPreview(context, state),
                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Mục tiêu tiết kiệm',
                    actionLabel: 'Tất cả',
                    onAction: () => state.setTab(3),
                  ),
                  const SizedBox(height: 8),
                  _buildSavingsPreview(context, state),
                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Giao dịch gần đây',
                    actionLabel: 'Xem tất cả',
                    onAction: () => state.setTab(1),
                  ),
                  const SizedBox(height: 8),
                  _buildRecentTransactions(state),
                  const SizedBox(height: 12),
                  _buildMonthlyChart(state),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, AppState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào buổi sáng 👋', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
              Text('Nguyễn Minh Anh', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 26, color: AppColors.textSecondary),
              onPressed: () {},
            ),
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: Center(child: Text('3', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => state.setTab(4),
          child: Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(gradient: AppColors.gradientPrimary, shape: BoxShape.circle),
            child: Center(child: Text('MA', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScore() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Điểm sức khỏe tài chính', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
                child: Row(
                  children: [
                    const Text('😊 ', style: TextStyle(fontSize: 14)),
                    Text('Tốt', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mức độ tiết kiệm', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
              Text('72/100', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0.72,
              minHeight: 10,
              backgroundColor: AppColors.chipBg,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPreview(BuildContext context, AppState state) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          SectionHeader(
            title: 'Ngân sách tháng 6',
            actionLabel: 'Xem tất cả',
            onAction: () => state.setTab(2),
          ),
          const SizedBox(height: 12),
          ...state.budgets.take(3).map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${b.emoji} ${b.name}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${formatVND(b.spent)} / ${formatVND(b.limit)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: b.percentage,
                    minHeight: 7,
                    backgroundColor: AppColors.chipBg,
                    valueColor: AlwaysStoppedAnimation(b.statusColor),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSavingsPreview(BuildContext context, AppState state) {
    if (state.savingsGoals.isEmpty) return const SizedBox();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: state.savingsGoals.take(3).map((g) {
          return AppCard(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(g.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(g.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatVND(g.savedAmount), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800)),
                      Text('${(g.percentage * 100).toInt()}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: g.statusColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: g.percentage,
                      minHeight: 6,
                      backgroundColor: AppColors.chipBg,
                      valueColor: AlwaysStoppedAnimation(g.statusColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTransactions(AppState state) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: state.recentTransactions.map((t) {
          final isLast = t == state.recentTransactions.last;
          return Column(
            children: [
              TransactionItem(transaction: t),
              if (!isLast) const Divider(height: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyChart(AppState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan tháng 6', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              _legendDot(AppColors.primary, 'Thu nhập'),
              const SizedBox(width: 16),
              _legendDot(AppColors.error, 'Chi tiêu'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10000000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final labels = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'];
                        return Text(labels[v.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary));
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(state.monthlyData.length, (i) {
                  final d = state.monthlyData[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: d['income'] as double, color: AppColors.primary, width: 10, borderRadius: BorderRadius.circular(6)),
                      BarChartRodData(toY: d['expense'] as double, color: AppColors.error, width: 10, borderRadius: BorderRadius.circular(6)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }
}