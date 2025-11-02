import 'package:equatable/equatable.dart';
import 'transaction.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String emoji;
  final int colorValue;
  final TransactionType type;

  const Category({
    this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.type,
  });

  Category copyWith({
    int? id,
    String? name,
    String? emoji,
    int? colorValue,
    TransactionType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorValue': colorValue,
      'type': type.name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      colorValue: map['colorValue'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'expense'),
        orElse: () => TransactionType.expense,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, colorValue, type];
}

