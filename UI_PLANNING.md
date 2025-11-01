# 🎨 LifeLens AI - UI Planning Document

## 📱 Navigation Structure

### Bottom Navigation Bar (5 Tabs)
1. **Dashboard** 🏠 - Main overview
2. **Budget** 💰 - Expenses & Income
3. **Goals** 🎯 - Savings Goals
4. **Productivity** ⏱️ - Work & Time Tracking
5. **Insights** 🧠 - AI Feedback & Analytics

---

## 🏠 Screen 1: Dashboard

### Layout Structure
```
┌─────────────────────────────┐
│  LifeLens AI                │  ← AppBar
├─────────────────────────────┤
│                             │
│  💰 Budget Summary Card     │
│  ┌───────────────────────┐  │
│  │ Total Balance: $2,450 │  │
│  │ This Month: +$500     │  │
│  │ Expenses: $1,200      │  │
│  └───────────────────────┘  │
│                             │
│  🎯 Active Goals Card       │
│  ┌───────────────────────┐  │
│  │ Vacation Goal         │  │
│  │ ▓▓▓▓▓▓▓░░░ 65%        │  │
│  │ $3,250 / $5,000       │  │
│  └───────────────────────┘  │
│                             │
│  ⏱️ Productivity Card       │
│  ┌───────────────────────┐  │
│  │ Today: 6.5h           │  │
│  │ This Week: 32h        │  │
│  │ Avg Daily: 6.4h       │  │
│  └───────────────────────┘  │
│                             │
│  🧠 Skills Card             │
│  ┌───────────────────────┐  │
│  │ Python: 120h          │  │
│  │ Design: 45h           │  │
│  └───────────────────────┘  │
│                             │
│  💡 Quick AI Insight        │
│  ┌───────────────────────┐  │
│  │ "You're on track!     │  │
│  │  Keep up the good     │  │
│  │  work this week."     │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
      [➕ Floating Action Button]
```

### Components Needed
- **Summary Cards**: Rounded corners, shadow, colored header bar
- **Progress Bars**: Linear progress indicators for goals
- **Quick Stats**: Large numbers, small labels
- **AI Insight Card**: Highlighted with accent color

---

## 💰 Screen 2: Budget & Expenses

### Layout Structure
```
┌─────────────────────────────┐
│  Budget 💰           [➕]   │  ← AppBar with FAB
├─────────────────────────────┤
│                             │
│  Balance Summary            │
│  ┌───────────────────────┐  │
│  │ Income: $3,000        │  │
│  │ Expenses: $1,200      │  │
│  │ Balance: $1,800       │  │
│  └───────────────────────┘  │
│                             │
│  [📊 Chart] [📋 List]       │  ← Toggle Buttons
│                             │
│  Category Breakdown         │
│  ┌───────────────────────┐  │
│  │ 🍔 Food      $450     │  │
│  │ 🚗 Transport $200     │  │
│  │ 🏠 Housing   $300     │  │
│  │ 🎮 Leisure   $250     │  │
│  └───────────────────────┘  │
│                             │
│  Recent Transactions         │
│  ┌───────────────────────┐  │
│  │ 🍔 Coffee      -$5.50 │  │
│  │ 💰 Salary     +$1500 │  │
│  │ 🚗 Gas        -$45.00 │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

### Components Needed
- **Transaction List Tile**: Icon, description, amount, date
- **Category Card**: Emoji, name, total amount, color indicator
- **Chart Widget**: Pie chart for categories (can use fl_chart)
- **Add Transaction Dialog**: Form with fields (amount, category, date, note)

---

## 🎯 Screen 3: Goals Tracker

### Layout Structure
```
┌─────────────────────────────┐
│  Goals 🎯            [➕]   │  ← AppBar
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐  │
│  │ 🏖️ Vacation Fund      │  │
│  │ ▓▓▓▓▓▓▓▓░░ 65%        │  │
│  │ $3,250 / $5,000        │  │
│  │ Due: Dec 2024          │  │
│  │ [Edit] [Delete]        │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 💻 New Laptop          │  │
│  │ ▓▓▓▓░░░░░░ 30%        │  │
│  │ $900 / $3,000          │  │
│  │ Due: Mar 2025          │  │
│  │ [Edit] [Delete]        │  │
│  └───────────────────────┘  │
│                             │
│  Completed Goals            │
│  ┌───────────────────────┐  │
│  │ ✅ Emergency Fund     │  │
│  │    $5,000 ✓          │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

### Components Needed
- **Goal Card**: Progress bar, target/saved amounts, due date
- **Progress Indicator**: Custom linear progress bar with percentage
- **Add Goal Dialog**: Name, target amount, due date
- **Empty State**: "No goals yet" message when list is empty

---

## ⏱️ Screen 4: Productivity Tracker

### Layout Structure
```
┌─────────────────────────────┐
│  Productivity ⏱️     [⏺️]   │  ← AppBar with Timer
├─────────────────────────────┤
│                             │
│  Today's Summary            │
│  ┌───────────────────────┐  │
│  │ Focus Hours: 6.5h     │  │
│  │ Sessions: 3           │  │
│  │ Avg Session: 2.2h     │  │
│  └───────────────────────┘  │
│                             │
│  [📊 This Week] [📊 This Month]
│                             │
│  Work Sessions Today        │
│  ┌───────────────────────┐  │
│  │ 🎨 Design Work        │  │
│  │ 09:00 - 11:30 (2.5h) │  │
│  │                       │  │
│  │ 💻 Coding             │  │
│  │ 14:00 - 17:00 (3.0h) │  │
│  │                       │  │
│  │ 📚 Learning           │  │
│  │ 19:00 - 20:00 (1.0h) │  │
│  └───────────────────────┘  │
│                             │
│  [➕ Add Manual Entry]      │
│                             │
└─────────────────────────────┘
```

### Components Needed
- **Timer Widget**: Start/Stop/Pause buttons, time display
- **Session Card**: Task name, time range, duration
- **Time Input Dialog**: Start time, end time, task name
- **Chart Widget**: Line chart showing daily/weekly productivity trends

---

## 🧠 Screen 5: Insights & AI Feedback

### Layout Structure
```
┌─────────────────────────────┐
│  Insights 🧠                │  ← AppBar
├─────────────────────────────┤
│                             │
│  💡 Daily Summary           │
│  ┌───────────────────────┐  │
│  │ 🧭 LifeLens AI says:  │  │
│  │                       │  │
│  │ You're 65% on track   │  │
│  │ to reach your saving  │  │
│  │ goal. Productivity    │  │
│  │ improved by 12% this  │  │
│  │ week. Great progress! │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  📊 Weekly Analytics        │
│  ┌───────────────────────┐  │
│  │ Time Allocation Chart │  │
│  │ [Pie Chart]           │  │
│  │                       │  │
│  │ Work: 35%             │  │
│  │ Leisure: 25%          │  │
│  │ Sleep: 30%            │  │
│  │ Study: 10%            │  │
│  └───────────────────────┘  │
│                             │
│  💰 Spending Insights       │
│  ┌───────────────────────┐  │
│  │ Food spending is 30%  │  │
│  │ above your target.    │  │
│  │ Consider reducing     │  │
│  │ dining out.           │  │
│  └───────────────────────┘  │
│                             │
│  🎯 Goal Suggestions        │
│  ┌───────────────────────┐  │
│  │ To reach your goal    │  │
│  │ faster, save $125/week│  │
│  │ instead of $100.      │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

### Components Needed
- **AI Insight Card**: Styled message box with icon
- **Chart Widgets**: Pie chart for time allocation
- **Recommendation Cards**: Actionable suggestions
- **Empty State**: When no data available

---

## 🎨 Design System

### Color Palette
```
Primary: #2196F3 (Blue)
Secondary: #4CAF50 (Green - for positive values)
Accent: #FF9800 (Orange - for warnings)
Error: #F44336 (Red - for expenses/negative)
Background: #F5F5F5 (Light Gray)
Card: #FFFFFF (White)
Text Primary: #212121 (Dark Gray)
Text Secondary: #757575 (Medium Gray)
```

### Typography
```
Headings: 
  - H1: 24px, Bold
  - H2: 20px, SemiBold
  - H3: 18px, SemiBold

Body:
  - Large: 16px, Regular
  - Medium: 14px, Regular
  - Small: 12px, Regular

Numbers:
  - Large Numbers: 32px, Bold (for important stats)
  - Medium Numbers: 20px, SemiBold
```

### Spacing
```
Padding:
  - Screen Padding: 16px
  - Card Padding: 16px
  - Item Spacing: 12px

Margins:
  - Between Cards: 16px
  - Section Spacing: 24px
```

### Components Style
```
Cards:
  - Border Radius: 12px
  - Shadow: elevation 2
  - Padding: 16px
  - Margin: 8px vertical

Buttons:
  - Border Radius: 8px
  - Primary: Filled, Blue
  - Secondary: Outlined
  - Floating Action: Circular, Blue

Input Fields:
  - Border Radius: 8px
  - Border: 1px solid #E0E0E0
  - Padding: 12px
```

---

## 📐 Layout Patterns

### Card Pattern
- White background
- Rounded corners (12px)
- Shadow for depth
- Colored top border or icon header
- Padding inside (16px)

### List Item Pattern
- Horizontal layout
- Leading icon (emoji or material icon)
- Title and subtitle
- Trailing amount/value
- Tap to edit/delete

### Empty State Pattern
- Centered layout
- Large icon (emoji or illustration)
- Title text
- Subtitle with call-to-action
- Button to add first item

---

## 🚀 Implementation Priority

### Phase 1: Core UI Structure
1. ✅ Setup bottom navigation bar
2. ✅ Create dashboard screen layout
3. ✅ Create basic card widgets
4. ✅ Add app theme/colors

### Phase 2: Functional Screens
1. ✅ Budget screen with transaction list
2. ✅ Goals screen with progress bars
3. ✅ Productivity screen with timer
4. ✅ Insights screen with placeholder AI text

### Phase 3: Interactive Components
1. ✅ Add transaction dialog
2. ✅ Add goal dialog
3. ✅ Chart widgets (using fl_chart)
4. ✅ Timer functionality

### Phase 4: Polish
1. ✅ Animations
2. ✅ Empty states
3. ✅ Loading states
4. ✅ Error handling UI

---

## 📱 Screen Flow

```
Start App
    ↓
Dashboard (Default)
    ↓
[User can navigate to any tab]
    ↓
Budget → Add Transaction → Form Dialog → Save → Back to Budget
    ↓
Goals → Add Goal → Form Dialog → Save → Back to Goals
    ↓
Productivity → Start Timer → Stop Timer → Save Session → Back to Productivity
    ↓
Insights → (Auto-generated from data)
```

---

## 💡 UI/UX Principles

1. **Simple & Clean**: Minimal design, focus on data
2. **Color Coding**: 
   - Green for income/positive
   - Red for expenses/negative
   - Blue for neutral/info
   - Orange for warnings
3. **Quick Actions**: FAB for primary actions (add expense, start timer)
4. **Visual Feedback**: Progress bars, charts, trends
5. **Easy Navigation**: Bottom nav for quick switching
6. **Readable**: Large numbers, clear labels
7. **Responsive**: Works on different screen sizes

---

## 🎯 Next Steps

1. Create basic theme file (`lib/theme/app_theme.dart`)
2. Create reusable card widget (`lib/widgets/stat_card.dart`)
3. Setup bottom navigation (`lib/main.dart`)
4. Create placeholder screens for each tab
5. Implement dashboard with mock data
6. Add forms/dialogs for adding data
7. Integrate charts library (fl_chart)
8. Connect to Hive for data persistence (later phase)

---

**Note**: This is a planning document for UI structure. Actual implementation will follow Flutter best practices and Material Design guidelines.

