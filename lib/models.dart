import 'package:flutter/material.dart';

enum TransactionType { income, expense }
enum SyncStatus { synced, pending, offline }

class Transaction {
  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final String category;
  final String categoryEmoji;
  final DateTime date;
  final String? note;
  final String paymentMethod;
  final SyncStatus syncStatus;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryEmoji,
    required this.date,
    this.note,
    this.paymentMethod = 'Thẻ ngân hàng',
    this.syncStatus = SyncStatus.synced,
  });

  Color get categoryColor {
    switch (category) {
      case 'Ăn uống': return const Color(0xFFEF4444);
      case 'Mua sắm': return const Color(0xFFF59E0B);
      case 'Di chuyển': return const Color(0xFF3B82F6);
      case 'Giải trí': return const Color(0xFF8B5CF6);
      case 'Y tế': return const Color(0xFFEC4899);
      case 'Học tập': return const Color(0xFF10B981);
      case 'Nhà ở': return const Color(0xFF6B7280);
      case 'Thu nhập': return const Color(0xFF22C55E);
      default: return const Color(0xFF9CA3AF);
    }
  }
}

class Budget {
  final String id;
  final String name;
  final String emoji;
  final double limit;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.name,
    required this.emoji,
    required this.limit,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });

  double get percentage => (spent / limit).clamp(0, 1);
  double get remaining => limit - spent;
  bool get isWarning => percentage >= 0.7 && percentage < 0.9;
  bool get isDanger => percentage >= 0.9;

  Color get statusColor {
    if (isDanger) return const Color(0xFFEF4444);
    if (isWarning) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
  });

  double get percentage => (savedAmount / targetAmount).clamp(0, 1);
  double get remainingAmount => targetAmount - savedAmount;
  bool get isCompleted => savedAmount >= targetAmount;

  Color get statusColor {
    if (isCompleted) return const Color(0xFF10B981); // Success green
    if (percentage >= 0.5) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFFF59E0B); // Amber
  }
}

class Category {
  final String name;
  final String emoji;
  final Color color;
  final IconData icon;

  const Category({
    required this.name,
    required this.emoji,
    required this.color,
    required this.icon,
  });
}

const List<Category> kCategories = [
  Category(name: 'Ăn uống', emoji: '🍔', color: Color(0xFFEF4444), icon: Icons.restaurant),
  Category(name: 'Mua sắm', emoji: '🛒', color: Color(0xFFF59E0B), icon: Icons.shopping_cart),
  Category(name: 'Di chuyển', emoji: '🚗', color: Color(0xFF3B82F6), icon: Icons.directions_car),
  Category(name: 'Giải trí', emoji: '🎮', color: Color(0xFF8B5CF6), icon: Icons.games),
  Category(name: 'Y tế', emoji: '💊', color: Color(0xFFEC4899), icon: Icons.favorite),
  Category(name: 'Học tập', emoji: '📚', color: Color(0xFF10B981), icon: Icons.book),
  Category(name: 'Nhà ở', emoji: '🏠', color: Color(0xFF6B7280), icon: Icons.home),
  Category(name: 'Khác', emoji: '📦', color: Color(0xFF9CA3AF), icon: Icons.more_horiz),
];