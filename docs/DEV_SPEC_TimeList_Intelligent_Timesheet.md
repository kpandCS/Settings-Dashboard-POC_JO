# Developer Specification
## Time List — Intelligent Timesheet
### PocketLink Mobile Application

---

| Field | Detail |
|---|---|
| **Document Version** | 1.0 |
| **Status** | Ready for Development |
| **Platform** | Flutter (Android + iOS) |
| **Architecture** | MVVM with Provider |
| **Branch** | `AI-feature` |
| **Prepared by** | Mobile Team |
| **Date** | May 2025 |

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [API Contract](#2-api-contract)
3. [Data Models](#3-data-models)
4. [AI Gap Detection Logic](#4-ai-gap-detection-logic)
5. [ViewModel — State & Actions](#5-viewmodel--state--actions)
6. [UI Component Tree](#6-ui-component-tree)
7. [Component Specifications](#7-component-specifications)
8. [Navigation & Routing](#8-navigation--routing)
9. [Error & Edge Case Handling](#9-error--edge-case-handling)
10. [Design Tokens](#10-design-tokens)
11. [File Structure](#11-file-structure)
12. [Testing Requirements](#12-testing-requirements)
13. [POC Reference Code](#13-poc-reference-code)

---

## 1. Architecture Overview

The feature follows the existing **MVVM + Provider** pattern used throughout PocketLink.

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│                                                             │
│  TimeListScreen                                             │
│    ├── WeekNavigator        (stateless, receives sheet)     │
│    ├── AiInsightBanner      (stateless, receives sheet+cbs) │
│    ├── OvertimeBanner       (stateless, conditional)        │
│    └── DayEntryRow × 7     (stateless, receives DayEntry)  │
└────────────────────┬────────────────────────────────────────┘
                     │ context.watch<TimeListViewModel>()
┌────────────────────▼────────────────────────────────────────┐
│                    ViewModel Layer                           │
│                                                             │
│  TimeListViewModel extends ChangeNotifier                   │
│    • _sheet: WeeklyTimesheet                                │
│    • _weekOffset: int           (0 = current week)          │
│    • _isLoading: bool                                       │
│    • _aiDismissed: bool                                     │
│    • computed: canGoForward, showAiBanner                   │
│    • actions: previousWeek(), nextWeek(), fillGap(),        │
│               copyYesterdayHours(), dismissAiBanner(),      │
│               refresh()                                     │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP GET
┌────────────────────▼────────────────────────────────────────┐
│                    Data Layer                               │
│                                                             │
│  ApiClient.get('/api/v1/workReport/hourlist/{id}')          │
│    └── WeeklyTimesheet.fromJson(response)                   │
└─────────────────────────────────────────────────────────────┘
```

**Key principle:** All AI logic lives in the **model and ViewModel layer** — the UI is dumb and only renders what it receives. No business logic in widgets.

---

## 2. API Contract

### 2.1 Fetch Weekly Timesheet

```
GET /api/v1/workReport/hourlist/{employeeId}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `weekOffset` | `int` | Yes | `0` = current week, `-1` = last week, `-2` = two weeks ago, etc. |

**Example Request:**
```
GET /api/v1/workReport/hourlist/emp-001?weekOffset=-1
Authorization: Bearer {sessionToken}
```

**Response — 200 OK:**
```json
{
  "employeeId": "emp-001",
  "employeeName": "Kari Pedersen",
  "weekStart": "2025-05-19T00:00:00Z",
  "weeklyTargetHours": 40.0,
  "entries": [
    {
      "date": "2025-05-19T00:00:00Z",
      "hoursLogged": 8.0,
      "projectId": 101,
      "projectName": "Strand Bolig",
      "workReportId": "WR-2038",
      "workReportStatus": "Signed"
    },
    {
      "date": "2025-05-20T00:00:00Z",
      "hoursLogged": 7.5,
      "projectId": 102,
      "projectName": "Bergkvist Bolig",
      "workReportId": "WR-2039",
      "workReportStatus": "Signed"
    },
    {
      "date": "2025-05-21T00:00:00Z",
      "hoursLogged": 6.0,
      "projectId": 102,
      "projectName": "Bergkvist Bolig",
      "workReportId": "WR-2040",
      "workReportStatus": "Pending"
    },
    {
      "date": "2025-05-22T00:00:00Z",
      "hoursLogged": 0.0,
      "projectId": 103,
      "projectName": "Lofoten Hytte",
      "workReportId": "WR-2041",
      "workReportStatus": "Pending"
    },
    {
      "date": "2025-05-23T00:00:00Z",
      "hoursLogged": 0.0,
      "projectId": null,
      "projectName": null,
      "workReportId": null,
      "workReportStatus": null
    },
    {
      "date": "2025-05-24T00:00:00Z",
      "hoursLogged": 0.0,
      "projectId": null,
      "projectName": null,
      "workReportId": null,
      "workReportStatus": null
    },
    {
      "date": "2025-05-25T00:00:00Z",
      "hoursLogged": 0.0,
      "projectId": null,
      "projectName": null,
      "workReportId": null,
      "workReportStatus": null
    }
  ]
}
```

**⚠️ Critical assumption:** The API must return all 7 days of the week, including days with no data (zeros/nulls). If the backend only returns days that have entries, the app team must either:
- Request a backend change to always return 7 rows, OR
- Build a client-side "skeleton merge" (see Section 9.2)

**Response — 401 Unauthorized:**
```json
{ "error": "Unauthorised" }
```

**Response — 404 Not Found:**
```json
{ "error": "Employee not found" }
```

### 2.2 Create/Fill Hour Entry (CTA Action)

When the employee taps "Fill [Day]", navigate to the existing Work Report creation screen with pre-filled parameters.

```
POST /api/v1/workReport
Authorization: Bearer {sessionToken}
Content-Type: application/json

{
  "employeeId": "emp-001",
  "date": "2025-05-22T00:00:00Z",
  "hoursLogged": 8.0,
  "projectId": 103
}
```

> **Note:** This is handled by the existing Work Report screen. The Time List feature only needs to **navigate** to that screen with pre-filled parameters. No direct API call from the Time List itself.

### 2.3 Copy Previous Day's Hours (Optional CTA)

```
POST /api/v1/workReport/copy
Authorization: Bearer {sessionToken}
Content-Type: application/json

{
  "employeeId": "emp-001",
  "sourceDate": "2025-05-21T00:00:00Z",
  "targetDate": "2025-05-22T00:00:00Z"
}
```

---

## 3. Data Models

### 3.1 EntryStatus Enum

```dart
enum EntryStatus {
  /// Hours logged and WR signed/pending — normal day.
  logged,

  /// WR exists for this day but hoursLogged == 0.
  /// AI flags this as "open report without hour entry".
  workReportNoHours,

  /// No WR and no hours for a working day.
  /// AI flags this as a completely missing entry.
  gap,

  /// Saturday or Sunday — not expected to work.
  weekend,
}
```

**Derivation rule** (applied during `fromJson` / `_classifyEntry()`):

```
IF date.weekday == 6 (Saturday) OR date.weekday == 7 (Sunday)
  → EntryStatus.weekend

ELSE IF workReportId != null AND hoursLogged == 0
  → EntryStatus.workReportNoHours          // WR exists, no hours

ELSE IF workReportId == null AND hoursLogged == 0
  → EntryStatus.gap                        // nothing at all

ELSE
  → EntryStatus.logged                     // hours present (with or without WR)
```

### 3.2 DayEntry

```dart
class DayEntry {
  final DateTime date;
  final double hoursLogged;
  final double dailyTarget;        // typically 8.0h — from employee contract
  final String? projectName;
  final String? workReportId;
  final String? workReportStatus;  // "Signed" | "Pending" | null
  final EntryStatus status;        // derived — see 3.1

  // Computed
  double get progress =>
      dailyTarget > 0 ? (hoursLogged / dailyTarget).clamp(0.0, 1.0) : 0.0;

  bool get isGap =>
      status == EntryStatus.gap || status == EntryStatus.workReportNoHours;
}
```

**JSON mapping:**

| JSON field | Dart field | Notes |
|---|---|---|
| `date` | `date` | Parse as UTC DateTime |
| `hoursLogged` | `hoursLogged` | Default to 0.0 if null |
| `weeklyTargetHours / 5` | `dailyTarget` | Divide weekly target by 5 |
| `projectName` | `projectName` | Nullable |
| `workReportId` | `workReportId` | Nullable |
| `workReportStatus` | `workReportStatus` | "Signed" \| "Pending" \| null |
| *(derived)* | `status` | Apply classification rule from 3.1 |

### 3.3 WeeklyTimesheet

```dart
class WeeklyTimesheet {
  final DateTime weekStart;
  final double weeklyTarget;
  final List<DayEntry> entries;    // always 7 items, Mon → Sun
  final String employeeId;
  final String employeeName;

  // Computed getters
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  double get totalLogged =>
      entries.fold(0.0, (sum, e) => sum + e.hoursLogged);

  double get hoursRemaining =>
      (weeklyTarget - totalLogged).clamp(0.0, weeklyTarget);

  double get progressFraction =>
      weeklyTarget > 0
          ? (totalLogged / weeklyTarget).clamp(0.0, 1.0)
          : 0.0;

  // AI-computed lists
  List<DayEntry> get gaps =>
      entries.where((e) => e.status == EntryStatus.gap).toList();

  List<DayEntry> get reportsWithNoHours =>
      entries.where((e) => e.status == EntryStatus.workReportNoHours).toList();

  List<DayEntry> get aiFlags =>
      entries.where((e) => e.isGap).toList();   // gaps + reportsWithNoHours

  // Overtime detection
  bool get hasOvertimeRisk {
    final workDaysElapsed =
        entries.where((e) => e.status == EntryStatus.logged).length;
    if (workDaysElapsed < 3) return false;
    final pace = totalLogged / workDaysElapsed;
    return pace * 5 > 42;
  }
}
```

---

## 4. AI Gap Detection Logic

This section is the heart of the "AI" feature. All logic is deterministic and runs on-device.

### 4.1 Classification Algorithm (pseudocode)

```
function classifyEntry(entry, weeklyTarget):
  dailyTarget = weeklyTarget / 5

  if entry.date.weekday IN [6, 7]:           // Saturday = 6, Sunday = 7
    return EntryStatus.weekend

  if entry.hoursLogged == 0:
    if entry.workReportId != null:
      return EntryStatus.workReportNoHours   // WR open, forgot hours
    else:
      return EntryStatus.gap                 // nothing at all

  return EntryStatus.logged                  // normal day
```

### 4.2 Overtime Risk Algorithm

```
function hasOvertimeRisk(entries, weeklyTarget):
  loggedDays = entries.where(status == logged)
  
  if loggedDays.count < 3:
    return false                             // too early in week to project

  totalHoursLogged = sum(loggedDays.hoursLogged)
  dailyPace = totalHoursLogged / loggedDays.count
  projectedWeekly = dailyPace * 5

  return projectedWeekly > 42
```

**Why the 3-day minimum?**  
If an employee logs 10h on Monday (unusual day), the projection would be 50h — a false positive. After 3 days there is enough data to make a meaningful projection.

### 4.3 Weekly Progress Algorithm

```
totalLogged = sum of hoursLogged across all 7 entries
hoursRemaining = max(0, weeklyTarget - totalLogged)
progressFraction = clamp(totalLogged / weeklyTarget, 0.0, 1.0)
```

### 4.4 When Does Detection Run?

Detection runs automatically at these moments:
1. **Screen loads** — when `TimeListScreen` is first built
2. **Week changes** — when employee taps Previous or Next
3. **Manual refresh** — when employee pulls down to refresh
4. **After fill-gap action** — after the Work Report screen returns and data is reloaded

Detection does **not** require any server call — it processes the data already loaded from the API.

---

## 5. ViewModel — State & Actions

### 5.1 State Properties

```dart
class TimeListViewModel extends ChangeNotifier {
  WeeklyTimesheet _sheet;      // current week's data
  bool _isLoading = false;     // true while API call in flight
  bool _aiDismissed = false;   // true after user taps Dismiss
  int _weekOffset = 0;         // 0 = current week, -1 = last week, etc.

  // Public getters
  WeeklyTimesheet get sheet => _sheet;
  bool get isLoading => _isLoading;
  bool get canGoForward => _weekOffset < 0;
  bool get showAiBanner => !_aiDismissed && _sheet.aiFlags.isNotEmpty;
}
```

### 5.2 Actions

| Method | Triggers | Side Effects |
|---|---|---|
| `previousWeek()` | User taps ← | Decrements `_weekOffset`, calls `_loadWeek()` |
| `nextWeek()` | User taps → | Increments `_weekOffset` (if < 0), calls `_loadWeek()` |
| `fillGap(DayEntry)` | User taps "Fill [Day]" | Navigate to Work Report creation screen (see Section 8) |
| `copyYesterdayHours(DayEntry)` | User taps "Copy Yesterday" | POST to copy API, then call `refresh()` |
| `dismissAiBanner()` | User taps "Dismiss" | Sets `_aiDismissed = true`, notifyListeners() |
| `refresh()` | Pull-to-refresh | Calls `_loadWeek()` |

### 5.3 Data Loading Flow

```dart
Future<void> _loadWeek() async {
  _isLoading = true;
  _aiDismissed = false;      // reset banner state on every load
  notifyListeners();

  try {
    final response = await _apiClient.get(
      '/api/v1/workReport/hourlist/$_employeeId',
      queryParams: {'weekOffset': _weekOffset},
    );
    _sheet = WeeklyTimesheet.fromJson(response.data);
  } catch (e) {
    _error = _mapError(e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**Note:** `_aiDismissed` resets to `false` on every data load. This ensures that if the employee navigates away and returns, or refreshes, the banner reappears for any unresolved gaps.

---

## 6. UI Component Tree

```
TimeListScreen
│
├── SliverAppBar
│     ├── Title: "Time List"
│     └── Action: Refresh icon button
│
├── LinearProgressIndicator          (visible when _isLoading == true)
│
└── SliverList
      │
      ├── WeekNavigator
      │     ├── IconButton ← (previous week)
      │     ├── Column (centre)
      │     │     ├── Text: "Week of 19–25 May 2025"
      │     │     ├── LinearProgressIndicator (week progress)
      │     │     └── Text: "Total: 21.5 h / 40 h"
      │     └── IconButton → (next week, disabled if canGoForward==false)
      │
      ├── AiInsightBanner             (visible when showAiBanner == true)
      │     ├── Row: sparkle icon + "AI Insight" + dismiss ✕
      │     ├── Text: "You are 18.5 h short of your 40 h target"
      │     ├── _FlagLine × n         (one per aiFlag entry)
      │     └── Wrap: [Fill Thu] [Fill Fri] [Dismiss]
      │
      ├── OvertimeBanner              (visible when hasOvertimeRisk == true)
      │     └── Row: clock icon + warning text
      │
      └── Card: "Daily Breakdown"
            ├── Row: calendar icon + "Daily Breakdown"
            ├── Divider
            ├── DayEntryRow × 7      (one per sheet.entries)
            │     ├── Text: "Mon"    (day abbreviation)
            │     ├── LinearProgressIndicator  (entry.progress)
            │     ├── Text: "8.0 h"
            │     └── _InfoSection
            │           ├── Text: project name / gap reason
            │           ├── _WrChip  (if WR exists and status == logged)
            │           └── Icon: ⚠ warningCircle (if isGap)
            ├── Divider
            └── _WeekTotalsRow
                  ├── Text: "Weekly total"
                  └── Text: "21.5 h / 40 h  (18.5 h remaining)"
```

---

## 7. Component Specifications

### 7.1 WeekNavigator

**File:** `lib/view/widgets/timelist/week_navigator.dart`

| Property | Type | Description |
|---|---|---|
| `sheet` | `WeeklyTimesheet` | Data source for week dates and progress |
| `canGoForward` | `bool` | If false, Next button is disabled |
| `onPrevious` | `VoidCallback` | Called when ← tapped |
| `onNext` | `VoidCallback` | Called when → tapped |

**Progress bar colour logic:**

```dart
valueColor: AlwaysStoppedAnimation<Color>(
  sheet.progressFraction >= 1.0
      ? AppColors.successGreen    // #2E7D32 — target reached
      : AppColors.brandOrange,    // #A24907 — in progress
)
```

**Week label format:**

```dart
// Same month:    "Week of 19–25 May"
// Cross-month:   "Week of 28 Apr – 4 May"
```

---

### 7.2 DayEntryRow

**File:** `lib/view/widgets/timelist/day_entry_row.dart`

| Property | Type | Description |
|---|---|---|
| `entry` | `DayEntry` | Single day's data |

**Row colour logic:**

| Day state | Day label colour | Bar colour | Hours colour |
|---|---|---|---|
| `logged` | textPrimary | brandOrange (< 100%) / successGreen (= 100%) | textPrimary |
| `workReportNoHours` | errorRed | errorRed | errorRed |
| `gap` | errorRed | errorRed | errorRed |
| `weekend` | textSecondary | outlineVariant (flat bar) | textSecondary (shows —) |

**WR Status chip:**

| Status | Background | Text colour |
|---|---|---|
| "Signed" | successGreen @ 12% opacity | successGreen |
| "Pending" | brandOrangeContainer | brandOrange |
| null | not shown | — |

---

### 7.3 AiInsightBanner

**File:** `lib/view/widgets/timelist/ai_insight_banner.dart`

| Property | Type | Description |
|---|---|---|
| `sheet` | `WeeklyTimesheet` | Source of `aiFlags` and `hoursRemaining` |
| `onFillGap` | `Function(DayEntry)` | Called when "Fill [Day]" tapped |
| `onCopyYesterday` | `Function(DayEntry)` | Called when "Copy Yesterday" tapped |
| `onDismiss` | `VoidCallback` | Called when Dismiss tapped |

**Flag line description logic:**

```dart
if (entry.status == EntryStatus.workReportNoHours)
  → "[Weekday] — open work report with no hours logged"

if (entry.status == EntryStatus.gap)
  → "[Weekday] — no work report recorded"
```

**CTA buttons:** One "Fill [Day]" `FilledButton` per flagged entry + one `Dismiss` `OutlinedButton`.

---

### 7.4 TimeListScreen

**File:** `lib/view/screens/time_list_screen.dart`

- Uses `ChangeNotifierProvider` to scope `TimeListViewModel` to this screen only (not app-wide)
- `CustomScrollView` with `AlwaysScrollableScrollPhysics` to allow pull-to-refresh on short content
- `RefreshIndicator` wraps the scroll view
- `SafeArea` for notch/home-indicator avoidance
- Bottom padding: **104dp** (80dp NavigationBar + 24dp breathing room)

---

## 8. Navigation & Routing

### 8.1 "Fill [Day]" Action

When the employee taps "Fill Thursday":

```dart
void fillGap(DayEntry entry) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => WorkReportCreateScreen(
        prefilledDate: entry.date,
        prefilledProjectId: _suggestProject(entry),   // most recent project from WR history
        suggestedHours: entry.dailyTarget,
      ),
    ),
  );
}
```

After the Work Report screen pops (success or cancel), call `refresh()` to reload the timesheet.

```dart
await Navigator.of(context).push(workReportRoute);
await vm.refresh();   // reload regardless of outcome
```

### 8.2 Main Navigation

The Time List tab is the **middle tab** in the 3-tab NavigationBar:

| Index | Tab | Screen |
|---|---|---|
| 0 | My Day | `DashboardScreen` |
| 1 | Time List | `TimeListScreen` |
| 2 | Settings | `SettingsScreen` |

Icon: `PhosphorIcons.clockCounterClockwise` (regular/fill variants)

---

## 9. Error & Edge Case Handling

### 9.1 API Failure

| Scenario | Behaviour |
|---|---|
| Network timeout | Show error card with retry button; log error |
| 401 Unauthorized | Redirect to login screen |
| 404 Not Found | Show "No timesheet data found" empty state |
| 500 Server Error | Show generic error with retry button |

### 9.2 API Returns Fewer Than 7 Days

If the backend only returns days with data (not all 7 days), the app must generate a full week skeleton and merge:

```dart
static WeeklyTimesheet fromJson(Map<String, dynamic> json) {
  final weekStart = DateTime.parse(json['weekStart']);
  final target = (json['weeklyTargetHours'] as num).toDouble();
  
  // Build full 7-day skeleton
  final allDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
  
  // Index API entries by date
  final apiEntries = {
    for (final e in json['entries'])
      DateTime.parse(e['date']).toLocal().toString().substring(0, 10): e
  };
  
  // Merge: use API data if present, otherwise default to zero/null
  final entries = allDays.map((date) {
    final key = date.toString().substring(0, 10);
    final raw = apiEntries[key];
    return DayEntry(
      date: date,
      hoursLogged: (raw?['hoursLogged'] as num?)?.toDouble() ?? 0.0,
      dailyTarget: target / 5,
      projectName: raw?['projectName'],
      workReportId: raw?['workReportId'],
      workReportStatus: raw?['workReportStatus'],
      status: _classifyEntry(date, raw?['hoursLogged'], raw?['workReportId']),
    );
  }).toList();
  
  return WeeklyTimesheet(
    weekStart: weekStart,
    weeklyTarget: target,
    entries: entries,
    employeeId: json['employeeId'],
    employeeName: json['employeeName'],
  );
}
```

### 9.3 Future Week Navigation

If `_weekOffset == 0` (current week), the Next Week button is:
- Visually disabled (grey colour)
- `onPressed: null` (Flutter disables the button automatically)

The ViewModel also guards the action:
```dart
void nextWeek() {
  if (_weekOffset >= 0) return;
  _weekOffset++;
  _loadWeek();
}
```

### 9.4 Empty Week (All Zeros)

If an employee has no entries at all for a week (e.g. was on leave):
- All 5 weekdays show as `gap` and are flagged
- AI banner will appear listing all 5 days
- This is technically correct behaviour — if on leave, the manager should add a leave/absence record
- A future enhancement: detect approved leave and exclude those days from gap detection

### 9.5 Part-Time Employees

If the weekly target is not 40h (e.g. part-time = 20h, daily target = 4h):
- The progress bar percentages adjust automatically
- Overtime threshold (42h) is hardcoded — for part-time, this threshold may need to be configurable
- **For v1:** Use 42h as a fixed threshold; part-time overtime detection is out of scope

---

## 10. Design Tokens

All colours and sizing must use the existing `AppColors`, `AppRadius`, and `AppSpacing` tokens from `lib/core/theme/app_theme.dart`.

### 10.1 Colours

| Token | Hex | Usage |
|---|---|---|
| `AppColors.brandOrange` | `#A24907` | Progress bars, icons, primary actions, AI banner border |
| `AppColors.brandOrangeContainer` | `#FFF0E6` | AI banner background, Pending chip background |
| `AppColors.brandOrangeDark` | `#6B2E03` | Body text inside AI banner |
| `AppColors.successGreen` | `#2E7D32` | Completed progress bar, Signed chip text |
| `AppColors.errorRed` | `#B00020` | Gap indicator, warning icon, flagged day text |
| `AppColors.textPrimary` | `#000000` | Day labels, hours text |
| `AppColors.textSecondary` | `#5D6472` | Project names, sub-labels |
| `AppColors.surfaceHover` | `#EFF0F8` | Progress bar background track |
| `AppColors.outline` | `#E0E0E0` | Dividers, dev hint border |
| `AppColors.outlineVariant` | `#EEEEEE` | Weekend bar fill |

### 10.2 Radius

| Token | Value | Usage |
|---|---|---|
| `AppRadius.medium` | `12dp` | Card corners, banner corners |
| `AppRadius.small` | `8dp` | Progress bar clip |
| `AppRadius.pill` | `120dp` | WR status chips, dismiss badge |

### 10.3 Spacing

| Area | Value |
|---|---|
| Screen horizontal padding | `16dp` |
| Between major sections | `12dp` |
| Between day rows | `6dp vertical` |
| Bottom padding (above NavBar) | `104dp` (80dp NavBar + 24dp) |

---

## 11. File Structure

```
lib/
├── model/
│   └── time_entry.dart               ← EntryStatus, DayEntry, WeeklyTimesheet
│
├── viewmodel/
│   └── time_list_viewmodel.dart      ← ChangeNotifier, week nav, AI state
│
└── view/
    ├── screens/
    │   └── time_list_screen.dart     ← Main screen, CustomScrollView assembly
    │
    └── widgets/
        └── timelist/
            ├── week_navigator.dart   ← Week header with ← progress bar →
            ├── day_entry_row.dart    ← Single day row with bar + chips
            └── ai_insight_banner.dart ← AI gap alert card with CTAs

lib/main.dart                         ← Updated: adds Time List tab (index 1)
```

---

## 12. Testing Requirements

### 12.1 Unit Tests — Gap Detection

```dart
// File: test/model/time_entry_test.dart

test('weekday with WR and zero hours → workReportNoHours', () {
  final entry = DayEntry(
    date: DateTime(2025, 5, 22),   // Thursday
    hoursLogged: 0.0,
    dailyTarget: 8.0,
    workReportId: 'WR-2041',
    workReportStatus: 'Pending',
    status: EntryStatus.workReportNoHours,
  );
  expect(entry.isGap, true);
});

test('weekday with no WR and zero hours → gap', () {
  final entry = DayEntry(
    date: DateTime(2025, 5, 23),   // Friday
    hoursLogged: 0.0,
    dailyTarget: 8.0,
    workReportId: null,
    status: EntryStatus.gap,
  );
  expect(entry.isGap, true);
});

test('Saturday → weekend, never flagged', () {
  final entry = DayEntry(
    date: DateTime(2025, 5, 24),   // Saturday
    hoursLogged: 0.0,
    dailyTarget: 0.0,
    status: EntryStatus.weekend,
  );
  expect(entry.isGap, false);
});

test('overtime risk triggers after 3 logged days over pace', () {
  // 3 days × 9h = 27h total → pace 9h/day → projected 45h > 42h threshold
  final sheet = buildMockSheet(loggedHours: [9.0, 9.0, 9.0, 0.0, 0.0]);
  expect(sheet.hasOvertimeRisk, true);
});

test('overtime risk does not trigger before 3 logged days', () {
  final sheet = buildMockSheet(loggedHours: [10.0, 10.0, 0.0, 0.0, 0.0]);
  expect(sheet.hasOvertimeRisk, false);   // only 2 days logged
});

test('progress fraction clamps to 1.0 when over target', () {
  final sheet = buildMockSheet(loggedHours: [9.0, 9.0, 9.0, 9.0, 9.0]);
  expect(sheet.progressFraction, 1.0);
});
```

### 12.2 Unit Tests — ViewModel

```dart
// File: test/viewmodel/time_list_viewmodel_test.dart

test('canGoForward is false on current week', () {
  final vm = TimeListViewModel();
  expect(vm.canGoForward, false);
});

test('canGoForward is true after going back one week', () {
  final vm = TimeListViewModel();
  vm.previousWeek();
  expect(vm.canGoForward, true);
});

test('showAiBanner is false after dismiss', () {
  final vm = TimeListViewModel();
  // Assumes mock data has gaps
  expect(vm.showAiBanner, true);
  vm.dismissAiBanner();
  expect(vm.showAiBanner, false);
});

test('showAiBanner resets after refresh', () async {
  final vm = TimeListViewModel();
  vm.dismissAiBanner();
  expect(vm.showAiBanner, false);
  await vm.refresh();
  expect(vm.showAiBanner, true);   // gaps still exist in mock
});
```

### 12.3 Widget Tests

```dart
// File: test/view/time_list_screen_test.dart

testWidgets('AI banner appears when gaps exist', (tester) async {
  await tester.pumpWidget(buildTestApp(TimeListScreen()));
  await tester.pumpAndSettle();
  expect(find.text('AI Insight'), findsOneWidget);
});

testWidgets('AI banner hidden after dismiss', (tester) async {
  await tester.pumpWidget(buildTestApp(TimeListScreen()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dismiss'));
  await tester.pumpAndSettle();
  expect(find.text('AI Insight'), findsNothing);
});

testWidgets('all 7 day rows render', (tester) async {
  await tester.pumpWidget(buildTestApp(TimeListScreen()));
  await tester.pumpAndSettle();
  expect(find.byType(DayEntryRow), findsNWidgets(7));
});
```

---

## 13. POC Reference Code

A working proof-of-concept is available on the `AI-feature` branch of the repository:

```
https://github.com/kpandCS/Settings-Dashboard-POC_JO
Branch: AI-feature
```

The POC uses mock data (`WeeklyTimesheet.mock()`) in place of real API calls.
The mock mirrors the exact JSON shape described in Section 2.1.

**To swap mock for real API, change one method in `TimeListViewModel`:**

```dart
// CURRENT (mock):
Future<void> _loadWeek() async {
  await Future.delayed(const Duration(milliseconds: 600));
  _sheet = WeeklyTimesheet.mock();
}

// PRODUCTION (real API):
Future<void> _loadWeek() async {
  _isLoading = true;
  notifyListeners();
  try {
    final response = await _apiClient.get(
      '/api/v1/workReport/hourlist/$_employeeId',
      queryParams: {'weekOffset': _weekOffset},
    );
    _sheet = WeeklyTimesheet.fromJson(response.data);
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

Everything else — gap detection, AI banner, progress bars, week navigation — works identically with real data.

---

*Developer Specification v1.0 — May 2025. For questions contact the PocketLink mobile team.*
