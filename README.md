# 💰 EzzeExpense

> **Track smart. Spend wise.**
> A personal expense tracker built with Flutter — fast, beautiful, and fully offline.

---

## ✨ Features

### 🏠 Home
- Live summary cards — **This Month**, **Today**, **Monthly Budget**, **Remaining**
- Budget cards appear automatically once a monthly budget is set
- Swipe right to **edit**, swipe left to **delete** any transaction
- Real-time search bar with instant filtering
- Category filter chips with animated selection
- Time-aware greeting (Good morning ☀️ / afternoon 🌤️ / evening 🌙)

### ➕ Add / Edit Expense
- Title, amount, date, notes
- Category selection with color-coded chips
- **Bills** → subcategory dropdown (Electricity, Gas, Wifi, Trash, Cook, Extra)
- **Other** → subcategory dropdown (Entertainment, Personal Care, Gift, Miscellaneous)
- **Friendly Loan** 🤝 → person name field
- Themed date picker

### 📊 Stats & Analytics
- **Overview tab** — Weekly / Monthly / Yearly toggle
- Pie chart breakdown by category
- Bar chart trend (last 7 days or last 6 months)
- Insight cards: Top Category 🏆, Daily Average 📉, Transactions 🧾
- **Monthly Summary tab** — navigate month by month, vs last month comparison, full category breakdown with sub-breakdowns

### 🎯 Budget
- Set a monthly total budget
- Per-category budgets with progress bars
- Three-state budget bar: 🟢 green (<80%) → 🟠 orange (80–100%) → 🔴 red (>100%)
- Smart warnings:
  - *Almost at budget limit for Food*
  - *You have used all your budget!*
  - *You are overspending on Food! ৳500 over budget*
- Exceed warning dialog when adding a category budget beyond the monthly total

### 🏷️ Categories
- 9 default categories including House Rent 🏠 and Friendly Loan 🤝
- Add custom categories with emoji icon + color picker
- Edit or delete non-default categories
- Add button in AppBar (no FAB blocking edit/delete)

### ⚙️ Settings
- 🌙 Dark / ☀️ Light mode toggle
- 💱 Currency — BDT (৳) or USD ($)
- 📤 Export data as JSON backup
- 📥 Import data from JSON backup
- 🗑️ Clear all data

---

## 🎨 Theme

**Neon City** — Fully adaptive Light + Dark theme.

| Color | Hex | Role |
|---|---|---|
| ⚡ Electric Cyan | `#00F5FF` | Primary actions, FAB, nav |
| 🌸 Neon Pink | `#FF3366` | Danger, alerts |
| 💛 Vivid Yellow | `#FFDD00` | Warnings, budget |
| 🟢 Neon Green | `#39FF14` | Success, savings |
| 💜 Electric Purple | `#CC00FF` | Categories, accents |

Dark base: deep cool black `#0A0A0F` — neons pop maximally.
Light base: crisp cool white `#F5F5FF` — clean contrast.

---

## 🗂️ Project Structure

```
lib/
├── main.dart                          # Entry point + MainShell
├── core/
│   ├── constants.dart                 # App constants, default categories
│   ├── theme.dart                     # Adaptive Neon City theme + EzzeTheme helper
│   └── providers.dart                 # SettingsProvider, CategoryProvider,
│                                      # ExpenseProvider, BudgetProvider
├── models/
│   ├── expense_model.dart             # ExpenseModel (with subCategory)
│   ├── category_model.dart            # CategoryModel
│   └── budget_model.dart              # BudgetModel
├── widgets/
│   ├── summary_card.dart              # Home summary cards
│   ├── expense_tile.dart              # Swipeable transaction tile
│   ├── category_chip.dart             # Animated category chip
│   └── budget_progress_bar.dart       # 3-color progress bar
└── screens/
    ├── home/home_screen.dart
    ├── add_edit/add_edit_screen.dart
    ├── search/search_filter_sheet.dart
    ├── stats/stats_screen.dart
    ├── budget/budget_screen.dart
    ├── category/category_screen.dart
    └── settings/settings_screen.dart
```

---

## 📦 Dependencies

```yaml
provider: ^6.1.1          # State management
hive: ^2.2.3              # Local storage
hive_flutter: ^1.1.0      # Hive Flutter integration
fl_chart: ^0.68.0         # Charts (pie + bar)
path_provider: ^2.1.2     # File system access
share_plus: ^7.2.2        # JSON export/share
uuid: ^4.3.3              # Unique IDs
cupertino_icons: ^1.0.6   # Icons
```

---

## 🚀 Getting Started

**1. Clone and install dependencies**
```bash
flutter pub get
```

**2. Run the app**
```bash
flutter run
```

**3. Build release APK**
```bash
flutter build apk --release
```

> Minimum SDK: Android 5.0 (API 21)
> Flutter: ≥ 3.10.0 | Dart SDK: ≥ 3.0.0

---

## 💾 Data Storage

All data is stored **locally on device** using Hive (no internet required, no accounts).

| Box | Contents |
|---|---|
| `expenses` | All expense records |
| `categories` | Category list |
| `budgets` | Monthly + category budgets |
| `settings` | Theme, currency preferences |

Export your data anytime via **Settings → Export Data** as a `.json` file.

---

## 🧠 How EzzeTheme Works

Instead of hardcoded colors, every widget uses the adaptive `EzzeTheme` helper:

```dart
final t = EzzeTheme.of(context);

// Automatically resolves to dark or light value:
t.bgCard        // Dark: #111118  |  Light: #FFFFFF
t.textPrimary   // Dark: #F0F0FF  |  Light: #08081A
t.border        // Dark: #20203A  |  Light: #C0C0E0
t.glowCard()    // Dark: card + neon glow  |  Light: card + subtle shadow
t.accentCard()  // Tinted accent surface for both modes
```

Toggling dark/light mode in Settings instantly re-renders the entire app.

---

## 📋 Default Categories

| Category | Icon | Color |
|---|---|---|
| Food | 🍔 | Red |
| Transport | 🚗 | Blue |
| Shopping | 🛍️ | Purple |
| Bills | 💡 | Orange |
| Health | 💊 | Cyan |
| House Rent | 🏠 | Green |
| Education | 📚 | Brown |
| Other | 📦 | Grey |
| Friendly Loan | 🤝 | Teal |

---

## 📄 License

```
EzzeExpense © 2024
Built with Flutter 💙
```
