/// Shared financial state — read by WalletPage, HomePage, StabilityPage,
/// and now written to by MarketplacePage checkout.
class FinancialHealth {
  // ── Core figures ──────────────────────────────────────────────
  static double monthlyBudget = 3000.0;
  static double income        = 4200.0;
  static double _totalSpent   = 1830.0;   // backing field

  static double get totalSpent => _totalSpent;

  // ── Called by marketplace checkout ───────────────────────────
  /// Records a marketplace purchase: increments spending so
  /// WalletPage and StabilityPage reflect the purchase immediately.
  static void recordSpend(double amount, [String? description]) {
    _totalSpent += amount;
  }

  // ── Derived values ────────────────────────────────────────────
  static double get score {
    final ratio = _totalSpent / monthlyBudget;
    if (ratio <= 0.5)  return 85.0;
    if (ratio <= 0.75) return 70.0;
    if (ratio <= 0.90) return 50.0;
    if (ratio <= 1.10) return 35.0;
    return 15.0;
  }

  static bool get needsWarning => score < 60;
  static bool get needsAlert   => score < 35;

  static String get label {
    if (score >= 75) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 45) return 'Fair';
    if (score >= 30) return 'Poor';
    return 'Critical';
  }

  static String get emoji {
    if (score >= 75) return '✅';
    if (score >= 60) return '🟡';
    if (score >= 45) return '🟠';
    return '🔴';
  }

  static String get statusBadge {
    if (score >= 75) return 'On Track';
    if (score >= 60) return 'Watch Budget';
    if (score >= 45) return 'Over Budget';
    return 'Financial Stress';
  }

  static String get homepageSubtitle {
    if (score >= 75) return 'Your finances are healthy this month.';
    if (score >= 60) return 'Keep an eye on your spending this month.';
    if (score >= 45) return 'You\'ve exceeded your budget — check your wallet.';
    return 'Critical financial stress detected. Please review your wallet.';
  }

  static int get colorValue {
    if (score >= 75) return 0xFF10B981;
    if (score >= 60) return 0xFFF59E0B;
    if (score >= 45) return 0xFFEF4444;
    return 0xFF7F1D1D;
  }

  static int get badgeColorValue => colorValue;
}