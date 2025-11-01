## 💡 Project Name: **“LifeLens AI”**

A local-first **personal growth and finance tracker** powered by **Flutter + Hive**, with AI-driven insights (that can later connect to online LLM APIs if needed).

---

## 🧩 **Core Concept**

You’ll build an **offline-first** MVP app that:

* Tracks **income, expenses, and savings goals**
* Monitors **work habits and productivity**
* Measures **skills learned and growth rate**
* Analyzes **how time is spent daily**
* Gives **AI advice** on spending, time use, and goals

Later phases can bring cloud sync or GPT-like AI reasoning, but MVP stays offline using **Hive for data storage** and **rule-based “AI logic”** (built manually, no API dependency).

---

## 🏗️ **MVP Goal**

Make a **self-improving personal dashboard** that:

1. Logs **spending and income**
2. Categorizes expenses automatically (via rules)
3. Lets users set **smart savings goals**
4. Tracks **tasks, hours worked**, and **focus time**
5. Tracks **skills you’re learning**
6. Summarizes **daily/weekly insights**
7. Generates **AI-like tips** locally (“Based on your habits this week…”)

---

## 📱 **Modules Breakdown**

### 1. 💰 Budget & Expense System

* **Tables (Hive Boxes):**

  * `transactions` → {amount, category, date, note, type: expense/income}
  * `categories` → {name, color, emoji}
* **Features:**

  * Add/Edit/Delete transactions
  * Smart categorization (keyword-based)
  * Summary by day/week/month
* **AI Logic (offline rules):**

  * If Food > 30% of income → “You’re overspending on dining out.”
  * If savings < 10% → “Try setting aside 10% for emergencies.”

---

### 2. 🎯 Smart Savings Goal Tracker

* **Table:** `goals` → {goalName, targetAmount, savedAmount, dueDate}
* **Features:**

  * Visual progress bar (pie/linear)
  * “Suggested savings per week” AI logic
  * Reminder for upcoming due dates

---

### 3. ⏱️ Work Productivity Analyzer

* **Table:** `work_sessions` → {start, end, duration, taskName, category}
* **Features:**

  * Track working hours manually or via timer
  * Daily/Weekly productivity score
* **AI Logic:**

  * If average work duration < 3h/day → “You’re working less than your goal.”
  * Compare “productive vs. idle” time.

---

### 4. 🧠 Skill Growth Tracker

* **Table:** `skills` → {name, hoursSpent, goalHours, level}
* **Features:**

  * Add skills (e.g. “Python”, “Design”)
  * Track learning hours
  * Display progress toward mastery
* **AI Logic:**

  * If skill hours increasing weekly → “You’re improving your consistency.”
  * Suggest skill priorities based on time left.

---

### 5. 🕒 Time Allocation AI

* **Table:** `daily_logs` → {date, category, hours}
* **Features:**

  * User logs how they spent hours (Work, Leisure, Sleep, Study, etc.)
  * Pie chart breakdown
* **AI Logic:**

  * “You spent 35% of your time on leisure, consider reducing it to 20%.”
  * “Sleep dropped below 6 hours this week.”

---

### 6. 🚀 Goal Motivation Coach (AI Simulation)

* Combines insights from all modules.
* Displays a **Daily Motivation Summary:**

  ```
  🧭 LifeLens AI Summary:
  - You’re 65% on track to reach your saving goal.
  - Productivity improved by 12% this week.
  - You spent 4h learning Design — great progress!
  - Try cutting 1 coffee expense daily to reach your savings goal faster.
  ```
* This can be rule-based at first (MVP), later replaced with GPT-style text generation.

---

## ⚙️ **MVP Tech Stack**

| Layer            | Tool                                        |
| ---------------- | ------------------------------------------- |
| Frontend         | Flutter                                     |
| Local Database   | Hive                                        |
| State Management | Riverpod / Provider                         |
| Charts           | fl_chart                                    |
| AI Logic         | Custom Dart logic (rules engine)            |
| Offline          | 100% offline storage                        |
| Theme            | Light/Minimal Dashboard UI (Bootstrap-like) |

---

## 🧱 **MVP Architecture**

```
lib/
 ├─ main.dart
 ├─ models/
 │   ├─ transaction.dart
 │   ├─ goal.dart
 │   ├─ work_session.dart
 │   ├─ skill.dart
 │   └─ daily_log.dart
 ├─ services/
 │   ├─ hive_service.dart
 │   ├─ ai_advisor.dart  ← rule-based logic here
 ├─ screens/
 │   ├─ dashboard_screen.dart
 │   ├─ expense_screen.dart
 │   ├─ productivity_screen.dart
 │   ├─ skill_screen.dart
 │   ├─ goals_screen.dart
 │   └─ insights_screen.dart
 └─ widgets/
     ├─ chart_widget.dart
     ├─ progress_card.dart
     └─ stat_summary.dart
```

---

## 🧩 **MVP Flow**

1. **Dashboard:** Shows combined overview — total spending, work hours, skill hours, goals progress.
2. **Add Entries:** + button to log expense, session, or learning time.
3. **Insights Page:** Shows rule-based “AI feedback” generated from all data.
4. **Charts:** Visual overview (pie for expenses, line for productivity, bars for skill growth).

---

## 🧠 **Phase 2 (After MVP)**

* Integrate **LLM API** (like OpenAI or Gemini) for natural language advice.
* Add **budget forecast AI** (predict next month’s spending).
* Add **habit tracking + reminders**.
* Cloud sync (Firebase or Supabase).

---

## 🚀 **Next Steps**

### Week 1

* Setup Hive models + UI for Expense + Goal tracking
* Build dashboard summary cards

### Week 2

* Add Productivity & Skill tracker modules
* Create rule-based AI logic (offline advisor)

### Week 3

* Add charts + insights summary
* Polish UI & local notifications
* Prepare for MVP testing

