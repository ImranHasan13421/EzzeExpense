// ============================================================
//  core/constants.dart — App-wide constants & default data
// ============================================================

const String kAppName     = 'EzzeExpense';
const String kExpenseBox  = 'expenses';
const String kCategoryBox = 'categories';
const String kBudgetBox   = 'budgets';
const String kSettingsBox = 'settings';

const List<String> kCurrencies = ['BDT', 'USD'];
const Map<String, String> kCurrencySymbols = {'BDT': '৳', 'USD': '\$'};

// Special category names — matched by name at runtime
const String kCatFriendlyLoan = 'Friendly Loan';
const String kCatBills        = 'Bills';
const String kCatOther        = 'Other';

const List<String> kBillsSubCategories = [
  'Electricity', 'Gas', 'Wifi', 'Trash', 'Cook', 'Extra',
];
const List<String> kOtherSubCategories = [
  'Entertainment', 'Personal Care', 'Gift', 'Miscellaneous',
];

final List<Map<String, dynamic>> kDefaultCategories = [
  {'name': 'Food',          'icon': '🍔', 'color': 0xFFE53935},
  {'name': 'Transport',     'icon': '🚗', 'color': 0xFF1E88E5},
  {'name': 'Shopping',      'icon': '🛍️', 'color': 0xFF8E24AA},
  {'name': 'Bills',         'icon': '💡', 'color': 0xFFFB8C00},
  {'name': 'Health',        'icon': '💊', 'color': 0xFF00ACC1},
  {'name': 'House Rent',    'icon': '🏠', 'color': 0xFF43A047},
  {'name': 'Education',     'icon': '📚', 'color': 0xFF6D4C41},
  {'name': 'Other',         'icon': '📦', 'color': 0xFF757575},
  {'name': 'Friendly Loan', 'icon': '🤝', 'color': 0xFF26A69A},
];
