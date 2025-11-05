import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/goal.dart';

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
      version: 6,
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
    if (oldVersion < 3) {
      // Create goals table
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          emoji TEXT NOT NULL,
          current REAL NOT NULL,
          target REAL NOT NULL,
          targetDate INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT "active",
          completedDate INTEGER,
          createdAt INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add new columns for enhanced goals
      try {
        await db.execute('ALTER TABLE goals ADD COLUMN type TEXT NOT NULL DEFAULT "saving"');
        await db.execute('ALTER TABLE goals ADD COLUMN colorValue INTEGER');
        await db.execute('ALTER TABLE goals ADD COLUMN startDate INTEGER');
        await db.execute('ALTER TABLE goals ADD COLUMN repeatType TEXT NOT NULL DEFAULT "daily"');
        await db.execute('ALTER TABLE goals ADD COLUMN selectedDaysOfWeek TEXT');
        await db.execute('ALTER TABLE goals ADD COLUMN intervalDays INTEGER NOT NULL DEFAULT 1');
        await db.execute('ALTER TABLE goals ADD COLUMN timesPerDay INTEGER NOT NULL DEFAULT 1');
        await db.execute('ALTER TABLE goals ADD COLUMN reminderTime TEXT');
        await db.execute('ALTER TABLE goals ADD COLUMN showOnPeriods TEXT');
        await db.execute('ALTER TABLE goals ADD COLUMN checklistItems TEXT');
        await db.execute('ALTER TABLE goals ADD COLUMN endConditionType TEXT NOT NULL DEFAULT "never"');
        await db.execute('ALTER TABLE goals ADD COLUMN endConditionValue INTEGER');
        
        // Migrate existing data - set startDate to createdAt if it exists, or targetDate
        await db.execute('''
          UPDATE goals 
          SET startDate = createdAt,
              colorValue = ${0xFF2196F3},
              type = "saving"
          WHERE startDate IS NULL
        ''');
      } catch (e) {
        // Columns might already exist, ignore error
      }
    }
    if (oldVersion < 5) {
      // Fix targetDate to be nullable - SQLite doesn't support direct ALTER, so we need to recreate the table
      try {
        // Create backup table with nullable targetDate
        await db.execute('''
          CREATE TABLE goals_backup (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            emoji TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT "financial",
            colorValue INTEGER NOT NULL DEFAULT ${0xFF2196F3},
            current REAL NOT NULL,
            target REAL NOT NULL,
            startDate INTEGER NOT NULL,
            targetDate INTEGER,
            status TEXT NOT NULL DEFAULT "active",
            completedDate INTEGER,
            createdAt INTEGER NOT NULL,
            repeatType TEXT NOT NULL DEFAULT "daily",
            selectedDaysOfWeek TEXT,
            intervalDays INTEGER NOT NULL DEFAULT 1,
            timesPerDay INTEGER NOT NULL DEFAULT 1,
            reminderTime TEXT,
            showOnPeriods TEXT,
            checklistItems TEXT,
            endConditionType TEXT NOT NULL DEFAULT "never",
            endConditionValue INTEGER
          )
        ''');

        // Copy data with explicit column mapping
        await db.execute('''
          INSERT INTO goals_backup (
            id, title, emoji, type, colorValue, current, target, startDate, targetDate,
            status, completedDate, createdAt, repeatType, selectedDaysOfWeek,
            intervalDays, timesPerDay, reminderTime, showOnPeriods, checklistItems,
            endConditionType, endConditionValue
          )
          SELECT
            id, title, emoji,
            COALESCE(type, "financial") as type,
            COALESCE(colorValue, ${0xFF2196F3}) as colorValue,
            current, target,
            COALESCE(startDate, createdAt) as startDate,
            targetDate,
            status, completedDate, createdAt,
            COALESCE(repeatType, "daily") as repeatType,
            selectedDaysOfWeek,
            COALESCE(intervalDays, 1) as intervalDays,
            COALESCE(timesPerDay, 1) as timesPerDay,
            reminderTime, showOnPeriods, checklistItems,
            COALESCE(endConditionType, "never") as endConditionType,
            endConditionValue
          FROM goals
        ''');

        // Drop old table
        await db.execute('DROP TABLE goals');

        // Rename backup to goals
        await db.execute('ALTER TABLE goals_backup RENAME TO goals');
      } catch (e) {
        // If migration fails, the table structure might already be correct
        // or there might be a different issue - log but don't fail
        print('Migration to version 5 completed with note: $e');
      }
    }
    if (oldVersion < 6) {
      // Create goal_entries table for tracking individual progress entries
      try {
        await db.execute('''
          CREATE TABLE goal_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goalId INTEGER NOT NULL,
            amount REAL NOT NULL,
            entryDate INTEGER NOT NULL,
            entryType TEXT NOT NULL,
            note TEXT,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
          )
        ''');

        // Create goal_notes table for notes
        await db.execute('''
          CREATE TABLE goal_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goalId INTEGER NOT NULL,
            content TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
          )
        ''');

        // Create index for faster queries
        await db.execute('CREATE INDEX idx_goal_entries_goalId ON goal_entries(goalId)');
        await db.execute('CREATE INDEX idx_goal_entries_entryDate ON goal_entries(entryDate)');
        await db.execute('CREATE INDEX idx_goal_notes_goalId ON goal_notes(goalId)');
      } catch (e) {
        print('Migration to version 6 completed with note: $e');
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

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        emoji TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT "financial",
        colorValue INTEGER NOT NULL DEFAULT ${0xFF2196F3},
        current REAL NOT NULL,
        target REAL NOT NULL,
        startDate INTEGER NOT NULL,
        targetDate INTEGER,
        status TEXT NOT NULL DEFAULT "active",
        completedDate INTEGER,
        createdAt INTEGER NOT NULL,
        repeatType TEXT NOT NULL DEFAULT "daily",
        selectedDaysOfWeek TEXT,
        intervalDays INTEGER NOT NULL DEFAULT 1,
        timesPerDay INTEGER NOT NULL DEFAULT 1,
        reminderTime TEXT,
        showOnPeriods TEXT,
        checklistItems TEXT,
        endConditionType TEXT NOT NULL DEFAULT "never",
        endConditionValue INTEGER
      )
    ''');

    // Create goal_entries table for tracking individual progress entries
    await db.execute('''
      CREATE TABLE goal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        amount REAL NOT NULL,
        entryDate INTEGER NOT NULL,
        entryType TEXT NOT NULL,
        note TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    // Create goal_notes table for notes
    await db.execute('''
      CREATE TABLE goal_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_goal_entries_goalId ON goal_entries(goalId)');
    await db.execute('CREATE INDEX idx_goal_entries_entryDate ON goal_entries(entryDate)');
    await db.execute('CREATE INDEX idx_goal_notes_goalId ON goal_notes(goalId)');

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

  // Goal CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals({GoalStatus? status}) async {
    final db = await database;
    var query = 'SELECT * FROM goals';
    final List<dynamic> args = [];

    if (status != null) {
      query += ' WHERE status = ?';
      args.add(status.name);
    }

    query += ' ORDER BY createdAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<Goal?> getGoal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addContribution(int goalId, double amount, {bool markAsCompleted = false, String? note, String entryType = 'complete'}) async {
    final goal = await getGoal(goalId);
    if (goal == null) return 0;

    final newCurrent = (goal.current + amount).clamp(0.0, goal.target);

    // Auto-complete goal if reached or exceeded target, or if explicitly marking as completed
    GoalStatus newStatus = goal.status;
    DateTime? completedDate = goal.completedDate;

    if (markAsCompleted && goal.status == GoalStatus.active) {
      newStatus = GoalStatus.completed;
      completedDate = DateTime.now();
    } else if (newCurrent >= goal.target && goal.status == GoalStatus.active) {
      newStatus = GoalStatus.completed;
      completedDate = DateTime.now();
    }

    final updatedGoal = goal.copyWith(
      current: newCurrent,
      status: newStatus,
      completedDate: completedDate,
    );

    // Insert goal entry to track this contribution
    final now = DateTime.now();
    await insertGoalEntry(
      goalId: goalId,
      amount: amount,
      entryDate: now,
      entryType: entryType,
      note: note,
    );

    return await updateGoal(updatedGoal);
  }

  // Goal entry operations
  Future<int> insertGoalEntry({
    required int goalId,
    required double amount,
    required DateTime entryDate,
    required String entryType,
    String? note,
  }) async {
    final db = await database;
    return await db.insert('goal_entries', {
      'goalId': goalId,
      'amount': amount,
      'entryDate': entryDate.millisecondsSinceEpoch,
      'entryType': entryType,
      'note': note,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getGoalEntries(int goalId, {DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    var query = 'SELECT * FROM goal_entries WHERE goalId = ?';
    final List<dynamic> args = [goalId];

    if (startDate != null) {
      query += ' AND entryDate >= ?';
      args.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      query += ' AND entryDate <= ?';
      args.add(endDate.millisecondsSinceEpoch);
    }

    query += ' ORDER BY entryDate DESC';

    return await db.rawQuery(query, args);
  }

  Future<int> deleteGoalEntry(int id) async {
    final db = await database;
    return await db.delete(
      'goal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal notes operations
  Future<int> insertGoalNote({
    required int goalId,
    required String content,
  }) async {
    final db = await database;
    return await db.insert('goal_notes', {
      'goalId': goalId,
      'content': content,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getGoalNotes(int goalId) async {
    final db = await database;
    return await db.query(
      'goal_notes',
      where: 'goalId = ?',
      whereArgs: [goalId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> deleteGoalNote(int id) async {
    final db = await database;
    return await db.delete(
      'goal_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateGoalNote(int id, String content) async {
    final db = await database;
    return await db.update(
      'goal_notes',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

