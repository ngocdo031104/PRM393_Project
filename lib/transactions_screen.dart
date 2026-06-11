import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/app_theme.dart';
import '/app_state.dart';
import '/models.dart';
import '/common_widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _tab = 0; // 0=all, 1=income, 2=expense
  String _selectedCategory = 'Tất cả';
  final _search = TextEditingController();

  final _categories = ['Tất cả', 'Ăn uống', 'Mua sắm', 'Di chuyển', 'Giải trí'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    var filtered = state.transactions.where((t) {
      if (_tab == 1 && t.type != TransactionType.income) return false;
      if (_tab == 2 && t.type != TransactionType.expense) return false;
      if (_selectedCategory != 'Tất cả' && t.category != _selectedCategory) return false;
      if (_search.text.isNotEmpty && !t.name.toLowerCase().contains(_search.text.toLowerCase())) return false;
      return true;
    }).toList();

    // Group by date
    final Map<String, List<Transaction>> grouped = {};
    for (final t in filtered) {
      final key = _dateKey(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: StatCard(
                      label: 'Thu nhập', value: '8,2M ₫',
                      change: '↑ 12% so tháng trước', isPositive: true, valueColor: AppColors.success,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(
                      label: 'Chi tiêu', value: '5,75M ₫',
                      change: '↑ 8% so tháng trước', isPositive: false, valueColor: AppColors.error,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _tabBtn('Tất cả', 0),
                      _tabBtn('Thu nhập', 1),
                      _tabBtn('Chi tiêu', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Tìm giao dịch...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _search.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _search.clear(); setState(() {}); })
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip2(
                        label: c,
                        selected: _selectedCategory == c,
                        onTap: () => setState(() => _selectedCategory = c),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: grouped.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: .5)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: entry.value.asMap().entries.map((e) => Column(
                        children: [
                          TransactionItem(transaction: e.value),
                          if (e.key < entry.value.length - 1) const Divider(height: 1, color: AppColors.border),
                        ],
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('Không có giao dịch', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Thêm giao dịch đầu tiên của bạn', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _dateKey(DateTime d) {
    final now = DateTime.now();
    if (DateFormat('yyyyMMdd').format(d) == DateFormat('yyyyMMdd').format(now)) return 'Hôm nay — ${DateFormat('dd/MM').format(d)}';
    if (DateFormat('yyyyMMdd').format(d) == DateFormat('yyyyMMdd').format(now.subtract(const Duration(days: 1)))) return 'Hôm qua — ${DateFormat('dd/MM').format(d)}';
    return DateFormat('dd/MM/yyyy').format(d);
  }
}