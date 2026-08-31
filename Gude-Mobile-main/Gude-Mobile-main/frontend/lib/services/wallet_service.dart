import 'package:flutter/material.dart';
import 'package:gude_app/services/user_role_service.dart';

class Pocket {
  final String id;
  String name;
  double balance;
  Color color;
  String emoji;
  List<PocketTransaction> transactions;
  final bool isMainAccount; // ← NEW flag

  Pocket({
    required this.id,
    required this.name,
    required this.balance,
    required this.color,
    required this.emoji,
    List<PocketTransaction>? transactions,
    this.isMainAccount = false,
  }) : transactions = transactions ?? [];
}

class PocketTransaction {
  final String label;
  final double amount;
  final bool isCredit;
  final DateTime date;
  PocketTransaction(this.label, this.amount, this.isCredit, this.date);
}

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  bool _initialised = false;
  double initialMainAccountBalance = 0.0;
  double _gudeEarningsBalance = 0.0;
  int _gudePoints = 250;

  /// Marketplace earnings are kept separate from personal wallet money.
  double get gudeEarningsBalance => _gudeEarningsBalance;
  int get gudePoints => _gudePoints;

  void recordGudeEarning(double amount, String source) {
    if (amount <= 0) return;
    _gudeEarningsBalance += amount;
    _gudePoints += 20;
    notifyListeners();
  }

  void awardGudePoints(int points, String reason) {
    if (points <= 0) return;
    _gudePoints += points;
    notifyListeners();
  }

  // ── Main Account pocket ID ────────────────────────────────
  static const _mainPocketId = 'main_account';

  // ── Pockets ───────────────────────────────────────────────
  final List<Pocket> _pockets = [];
  List<Pocket> get pockets => List.unmodifiable(_pockets);

  /// The special Main Account pocket (always index 0).
  Pocket get _mainPocket => _pockets.firstWhere((p) => p.id == _mainPocketId);

  /// Public balance helper used by the UI.
  double get mainAccountBalance => _mainPocket.balance;
  double get availableBalance => mainAccountBalance;

  // Kept for backwards-compat but now delegates to the pocket.
  final List<PocketTransaction> _mainTransactions = [];
  List<PocketTransaction> get mainTransactions =>
      List.unmodifiable(_mainTransactions);

  // ── Init ──────────────────────────────────────────────────
  /// Call once after onboarding so the Main Account pocket is created
  /// with the user's income as its opening balance.
  void initFromOnboarding() {
    if (_initialised) {
      // Re-capture initial balance if it was missed on a previous init
      if (initialMainAccountBalance == 0.0 && _pockets.isNotEmpty) {
        initialMainAccountBalance = mainAccountBalance;
      }
      return;
    }
    _initialised = true;

    final income = UserRoleService().monthlyIncome;

    _pockets.insert(
      0,
      Pocket(
        id: _mainPocketId,
        name: 'Main Account',
        emoji: '🏦',
        color: const Color(0xFF1A1A1A),
        balance: income,
        isMainAccount: true,
        transactions: income > 0
            ? [
                PocketTransaction(
                    'Monthly Income (${UserRoleService().fundingType})',
                    income,
                    true,
                    DateTime.now())
              ]
            : [],
      ),
    );

    // Ready-made, zero-balance pockets demonstrate the flexible wallet
    // without moving any of the student's real available balance.
    _pockets.addAll([
      Pocket(
        id: 'savings_pocket',
        name: 'Savings',
        emoji: '\u{1F4B0}',
        color: const Color(0xFF10B981),
        balance: 0,
      ),
      Pocket(
        id: 'budget_pocket',
        name: 'Monthly Budget',
        emoji: '\u{1F4CA}',
        color: const Color(0xFF7C3AED),
        balance: 0,
      ),
      Pocket(
        id: 'allowance_pocket',
        name: 'Allowance',
        emoji: '\u{1F392}',
        color: const Color(0xFFF59E0B),
        balance: 0,
      ),
    ]);

    initialMainAccountBalance =
        income; // ← set directly from income, not balance
    notifyListeners();
  }

  // ── Add pocket (deducts from Main Account) ────────────────
  bool addPocket(
      String name, String emoji, Color color, double initialDeposit) {
    if (initialDeposit > mainAccountBalance) return false;

    // Deduct from Main Account pocket.
    if (initialDeposit > 0) {
      _mainPocket.balance -= initialDeposit;
      _mainPocket.transactions.insert(
        0,
        PocketTransaction(
          'Transfer to $name pocket',
          initialDeposit,
          false,
          DateTime.now(),
        ),
      );
      // Keep legacy list in sync.
      _mainTransactions.insert(
        0,
        PocketTransaction(
          'Transfer to $name pocket',
          initialDeposit,
          false,
          DateTime.now(),
        ),
      );
    }

    _pockets.add(Pocket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      balance: initialDeposit,
      color: color,
      emoji: emoji,
      transactions: initialDeposit > 0
          ? [
              PocketTransaction(
                'From Main Account',
                initialDeposit,
                true,
                DateTime.now(),
              )
            ]
          : [],
    ));

    notifyListeners();
    return true;
  }

  // ── Add funds to an existing pocket ──────────────────────
  bool addFundsToPocket(String pocketId, double amount) {
    if (amount > mainAccountBalance) return false;
    final pocket = _pockets.firstWhere((p) => p.id == pocketId);

    _mainPocket.balance -= amount;
    _mainPocket.transactions.insert(
      0,
      PocketTransaction(
        'Transfer to ${pocket.name}',
        amount,
        false,
        DateTime.now(),
      ),
    );
    _mainTransactions.insert(
      0,
      PocketTransaction(
        'Transfer to ${pocket.name}',
        amount,
        false,
        DateTime.now(),
      ),
    );

    pocket.balance += amount;
    pocket.transactions.insert(
      0,
      PocketTransaction('From Main Account', amount, true, DateTime.now()),
    );

    notifyListeners();
    return true;
  }

  // ── Return funds from a pocket back to Main Account ───────
  bool returnFundsToMain(String pocketId, double amount) {
    final pocket = _pockets.firstWhere((p) => p.id == pocketId);
    if (amount > pocket.balance) return false;

    pocket.balance -= amount;
    pocket.transactions.insert(
      0,
      PocketTransaction(
        'Returned to Main Account',
        amount,
        false,
        DateTime.now(),
      ),
    );

    _mainPocket.balance += amount;
    _mainPocket.transactions.insert(
      0,
      PocketTransaction(
        'Return from ${pocket.name}',
        amount,
        true,
        DateTime.now(),
      ),
    );
    _mainTransactions.insert(
      0,
      PocketTransaction(
        'Return from ${pocket.name}',
        amount,
        true,
        DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  // ── Spend directly from a pocket ─────────────────────────
  void spendFromPocket(String pocketId, String label, double amount) {
    final pocket = _pockets.firstWhere((p) => p.id == pocketId);
    if (amount > pocket.balance) return;
    pocket.balance -= amount;
    pocket.transactions.insert(
      0,
      PocketTransaction(label, amount, false, DateTime.now()),
    );
    notifyListeners();
  }

  // ── Remove a pocket (balance returns to Main Account) ─────
  void removePocket(String pocketId) {
    // Prevent deleting the Main Account pocket.
    if (pocketId == _mainPocketId) return;

    final pocket = _pockets.firstWhere((p) => p.id == pocketId);

    if (pocket.balance > 0) {
      _mainPocket.balance += pocket.balance;
      _mainPocket.transactions.insert(
        0,
        PocketTransaction(
          'Return from ${pocket.name} (deleted)',
          pocket.balance,
          true,
          DateTime.now(),
        ),
      );
      _mainTransactions.insert(
        0,
        PocketTransaction(
          'Return from ${pocket.name} (deleted)',
          pocket.balance,
          true,
          DateTime.now(),
        ),
      );
    }

    _pockets.removeWhere((p) => p.id == pocketId);
    notifyListeners();
  }

  // ── Transfer between two pockets ─────────────────────────
  bool transferBetweenPockets(String fromId, String toId, double amount) {
    final from = _pockets.firstWhere((p) => p.id == fromId);
    final to = _pockets.firstWhere((p) => p.id == toId);
    if (amount > from.balance) return false;

    from.balance -= amount;
    from.transactions.insert(
      0,
      PocketTransaction(
        'Transfer to ${to.name}',
        amount,
        false,
        DateTime.now(),
      ),
    );

    to.balance += amount;
    to.transactions.insert(
      0,
      PocketTransaction(
        'Transfer from ${from.name}',
        amount,
        true,
        DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  // ── Debit a pocket (used by SendMoneyScreen) ──────────────
  /// Deducts [amount] from the pocket with [pocketId] and prepends
  /// a debit transaction labelled [label].
  /// Returns `false` if the pocket is not found or has insufficient balance.
  bool debitPocket(String pocketId, double amount, String label) {
    final matches = _pockets.where((p) => p.id == pocketId).toList();
    if (matches.isEmpty) return false;

    final pocket = matches.first;
    if (pocket.balance < amount) return false;

    pocket.balance -= amount;
    pocket.transactions.insert(
      0,
      PocketTransaction(label, amount, false, DateTime.now()),
    );

    // If debiting the Main Account, keep the legacy list in sync too
    if (pocketId == _mainPocketId) {
      _mainTransactions.insert(
        0,
        PocketTransaction(label, amount, false, DateTime.now()),
      );
    }

    notifyListeners();
    return true;
  }
}
