import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../common_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  String _amountStr = '';
  String _selectedCategory = 'Ăn uống';
  String _selectedEmoji = '🍔';
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _paymentMethod = 'Thẻ ngân hàng';
  
  String? _predictionText;

  double get _amount => double.tryParse(_amountStr) ?? 0;

  void _appendDigit(String d) => setState(() {
    if (_amountStr.length < 12) _amountStr += d;
  });

  void _backspace() => setState(() {
    if (_amountStr.isNotEmpty) _amountStr = _amountStr.substring(0, _amountStr.length - 1);
  });

  void _save(BuildContext context, {bool close = true}) {
    if (_amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền'), backgroundColor: AppColors.error),
      );
      return;
    }
    context.read<AppState>().addTransaction(Transaction(
      id: const Uuid().v4(),
      name: _noteCtrl.text.isEmpty ? _selectedCategory : _noteCtrl.text,
      amount: _amount,
      type: _type,
      category: _type == TransactionType.income ? 'Thu nhập' : _selectedCategory,
      categoryEmoji: _type == TransactionType.income ? '💼' : _selectedEmoji,
      date: _date,
      note: _noteCtrl.text,
      paymentMethod: _paymentMethod,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã lưu giao dịch!'), backgroundColor: AppColors.success),
    );
    if (close) {
      context.read<AppState>().setTab(0);
    } else {
      setState(() {
        _amountStr = '';
        _noteCtrl.clear();
        _predictionText = null;
      });
    }
  }

  void _applySuggestion(Map<String, dynamic> s) {
    setState(() {
      _amountStr = s['amount']!;
      _selectedCategory = s['category']!;
      _selectedEmoji = s['emoji']!;
      _noteCtrl.text = s['name']!;
      _predictionText = "Gợi ý số tiền dựa trên ${s['usedCount']} lần chi tiêu trước đó";
    });
    // Haptic feedback for fast, responsive feel
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(appState),
          _buildFloatingQuickActions(appState),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeBasedSuggestions(appState),
                  const SizedBox(height: 24),
                  _buildFrequentHabits(appState),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    // Calculate today's spending
    final todayStr = DateTime.now().toString().substring(0, 10);
    final todaysTransactions = appState.transactions.where((t) => 
      t.date.toString().substring(0, 10) == todayStr && t.type == TransactionType.expense
    );
    final todaysTotal = todaysTransactions.fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.read<AppState>().setTab(0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
                ),
              ),
              Text('Thêm giao dịch', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              _buildSyncStatus(appState),
            ],
          ),
          const SizedBox(height: 16),
          Text('Chi tiêu hôm nay', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(formatVND(todaysTotal), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(AppState appState) {
    bool hasPending = appState.transactions.any((t) => t.syncStatus == SyncStatus.pending);
    Color color;
    String text;
    if (appState.isOffline) {
      color = AppColors.error;
      text = 'Offline';
    } else if (hasPending) {
      color = AppColors.warning;
      text = 'Đang đồng bộ';
    } else {
      color = AppColors.success;
      text = 'Đã đồng bộ';
    }

    return GestureDetector(
      onTap: () => appState.toggleOffline(), // Temporary toggle for testing
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingQuickActions(AppState appState) {
    final actions = [
      {'name': 'Cà phê', 'emoji': '☕', 'amount': '35000', 'category': 'Ăn uống', 'usedCount': 24},
      {'name': 'Cơm trưa', 'emoji': '🍱', 'amount': '50000', 'category': 'Ăn uống', 'usedCount': 35},
      {'name': 'Grab', 'emoji': '🚗', 'amount': '35000', 'category': 'Di chuyển', 'usedCount': 15},
      {'name': 'Mua sắm', 'emoji': '🛒', 'amount': '150000', 'category': 'Mua sắm', 'usedCount': 12},
    ];
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: actions.map((a) => GestureDetector(
            onTap: () => _applySuggestion(a),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(a['emoji'].toString(), style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(a['name'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeBasedSuggestions(AppState appState) {
    final suggestions = appState.getTimeBasedSuggestions();
    String timeGreeting = "Gợi ý theo thời gian";
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) timeGreeting = "Gợi ý buổi sáng";
    else if (hour >= 11 && hour < 14) timeGreeting = "Gợi ý buổi trưa";
    else if (hour >= 17 && hour < 22) timeGreeting = "Gợi ý buổi tối";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(timeGreeting, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: suggestions.map((s) => Expanded(
            child: GestureDetector(
              onTap: () => _applySuggestion(s),
              child: AppCard(
                margin: EdgeInsets.only(right: s == suggestions.last ? 0 : 8),
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: Column(
                  children: [
                    Text(s['emoji'].toString(), style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(s['name'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(formatVND(double.parse(s['amount'].toString())), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text('${s['usedCount']} lần', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequentHabits(AppState appState) {
    final habits = appState.getFrequentHabits();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thường xuyên sử dụng", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: habits.map((h) => GestureDetector(
              onTap: () => _applySuggestion(h),
              child: AppCard(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.chipBg, shape: BoxShape.circle),
                      child: Text(h['emoji'].toString(), style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h['name'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(formatVND(double.parse(h['amount'].toString())), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent, // Form doesn't need border, just shadow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _typeBtn('Chi tiêu', TransactionType.expense)),
              const SizedBox(width: 8),
              Expanded(child: _typeBtn('Thu nhập', TransactionType.income)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Số tiền', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _amount == 0 ? '0 ₫' : formatVND(_amount),
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(onTap: _backspace, child: const Icon(Icons.backspace_outlined, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (_predictionText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(child: Text(_predictionText!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary))),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text('Danh mục & Ghi chú', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(14)),
                child: Text(_selectedEmoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Thêm ghi chú...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildCategoryGrid(),
          const SizedBox(height: 24),
          Text('Phương thức thanh toán', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Thẻ ngân hàng', 'Tiền mặt', 'Ví MoMo', 'Chuyển khoản'].map((v) {
                final isSelected = _paymentMethod == v;
                return GestureDetector(
                  onTap: () => setState(() => _paymentMethod = v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.background,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      v,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildNumpad(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _save(context, close: false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text('Lưu & Thêm', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _save(context, close: true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text('Lưu nhanh', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String label, TransactionType type) {
    final selected = _type == type;
    final color = type == TransactionType.expense ? AppColors.error : AppColors.success;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? color : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: kCategories.map((cat) {
        final selected = _selectedCategory == cat.name;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedCategory = cat.name;
            _selectedEmoji = cat.emoji;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(cat.name, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textSecondary), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumpad() {
    const keys = ['1','2','3','4','5','6','7','8','9','000','0',''];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: keys.map((k) => k.isEmpty ? const SizedBox() : GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _appendDigit(k);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(k, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
        ),
      )).toList(),
    );
  }
}