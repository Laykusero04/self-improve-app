import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add type column to categories table if it doesn't exist
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN type TEXT NOT NULL DEFAULT "expense"');
      } catch (e) {
        // Column might already exist, ignore error
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        emoji TEXT NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        emoji TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Income Categories
      Category(name: 'Salary', emoji: '💼', colorValue: 0xFF4CAF50, type: TransactionType.income), // Green
      Category(name: 'Freelance', emoji: '💻', colorValue: 0xFF2196F3, type: TransactionType.income), // Blue
      Category(name: 'Investment', emoji: '📈', colorValue: 0xFF9C27B0, type: TransactionType.income), // Purple
      Category(name: 'Gift', emoji: '🎁', colorValue: 0xFFE91E63, type: TransactionType.income), // Pink
      Category(name: 'Bonus', emoji: '🎉', colorValue: 0xFFFF9800, type: TransactionType.income), // Orange
      Category(name: 'Other Income', emoji: '💰', colorValue: 0xFF4CAF50, type: TransactionType.income), // Green
      // Expense Categories
      Category(name: 'Food', emoji: '🍔', colorValue: 0xFFFF9800, type: TransactionType.expense), // Orange
      Category(name: 'Transport', emoji: '🚗', colorValue: 0xFF2196F3, type: TransactionType.expense), // Blue
      Category(name: 'Housing', emoji: '🏠', colorValue: 0xFF9C27B0, type: TransactionType.expense), // Purple
      Category(name: 'Entertainment', emoji: '🎮', colorValue: 0xFFE91E63, type: TransactionType.expense), // Pink
      Category(name: 'Shopping', emoji: '🛒', colorValue: 0xFF4CAF50, type: TransactionType.expense), // Green
      Category(name: 'Health', emoji: '🏥', colorValue: 0xFFF44336, type: TransactionType.expense), // Red
      Category(name: 'Education', emoji: '📚', colorValue: 0xFF3F51B5, type: TransactionType.expense), // Indigo
      Category(name: 'Bills', emoji: '📄', colorValue: 0xFF795548, type: TransactionType.expense), // Brown
      Category(name: 'Other Expense', emoji: '💸', colorValue: 0xFF607D8B, type: TransactionType.expense), // Blue Grey
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? category,
  }) async {
    final db = await database;
    var query = 'SELECT * FROM transactions WHERE 1=1';
    final List<dynamic> args = [];

    if (startDate != null) {
      query += ' AND date >= ?';
      args.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      query += ' AND date <= ?';
      args.add(endDate.millisecondsSinceEpoch);
    }
    if (type != null) {
      query += ' AND type = ?';
      args.add(type.name);
    }
    if (category != null) {
      query += ' AND category = ?';
      args.add(category);
    }

    query += ' ORDER BY date DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // Summary operations
  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.income,
    );
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.expense,
    );
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, double>> getCategoryTotals({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );

    final Map<String, double> totals = {};
    for (final transaction in transactions) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0.0) + transaction.amount;
    }

    return totals;
  }
}

