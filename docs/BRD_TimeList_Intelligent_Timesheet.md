# Business Requirements Document
## Time List — Intelligent Timesheet
### PocketLink Mobile Application — EG A/S

---

| Field | Detail |
|---|---|
| **Document Version** | 1.0 |
| **Status** | Draft for Review |
| **Product** | PocketLink (Mobile App) |
| **Feature Name** | Time List — Intelligent Timesheet |
| **Prepared by** | Product Team |
| **Date** | May 2025 |
| **Stakeholders** | Operations, HR, Finance, IT, Field Employees |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Business Context & Problem Statement](#2-business-context--problem-statement)
3. [Objectives & Success Metrics](#3-objectives--success-metrics)
4. [Stakeholders & User Personas](#4-stakeholders--user-personas)
5. [Current State vs. Proposed State](#5-current-state-vs-proposed-state)
6. [Functional Requirements](#6-functional-requirements)
7. [User Stories & Acceptance Criteria](#7-user-stories--acceptance-criteria)
8. [Non-Functional Requirements](#8-non-functional-requirements)
9. [Out of Scope](#9-out-of-scope)
10. [Assumptions & Dependencies](#10-assumptions--dependencies)
11. [Risks & Mitigations](#11-risks--mitigations)
12. [Glossary](#12-glossary)

---

## 1. Executive Summary

PocketLink is the mobile companion app for field employees at EG A/S construction and facility management projects. Field workers currently rely on back-office staff or manual memory to catch missing time entries — a process that generates payroll errors, compliance gaps, and administrative overhead.

The **Time List — Intelligent Timesheet** feature introduces an AI-assisted timesheet view inside PocketLink. It analyses each employee's logged hours against their weekly target, automatically detects gaps and incomplete entries, and presents actionable prompts to fill them — without requiring any additional backend infrastructure or AI cloud service.

This document defines the business requirements for the initial release of this feature.

---

## 2. Business Context & Problem Statement

### 2.1 Background

EG A/S field employees submit time through two mechanisms:
- **Work Reports (WR)** — records that a employee was present on a project site on a given day
- **Hour Entries** — the number of hours worked, attached to the Work Report

Both records are stored in the existing backend system and are accessible via the Holetportalen API.

### 2.2 The Problem

Currently, employees and managers face three recurring issues:

| # | Problem | Business Impact |
|---|---|---|
| 1 | **Silent gaps** — an employee forgets to log hours on a working day and no one notices until payroll processing | Incorrect salary calculations, delays, corrections needed |
| 2 | **Orphaned Work Reports** — a WR exists for a day but the hour entry is missing (employee was on site but didn't enter hours) | Compliance gaps, project cost reporting inaccurate |
| 3 | **Overtime blind spots** — an employee's pace mid-week projects them over the 42h threshold by Friday but they are unaware | Unauthorised overtime, HR compliance issues |

### 2.3 Root Cause

Employees have no proactive, at-a-glance summary of their week's status. They must manually cross-reference their calendar, Work Reports, and hour entries to spot problems — a cognitive task most field workers skip until prompted by their manager or a payroll error.

### 2.4 Opportunity

The existing API already returns all the data needed to detect these gaps automatically. A lightweight intelligent layer in the mobile app can run this analysis on the employee's own device and surface clear, actionable prompts — at zero additional infrastructure cost.

---

## 3. Objectives & Success Metrics

### 3.1 Business Objectives

| Objective | Description |
|---|---|
| **Reduce payroll corrections** | Fewer incomplete timesheet submissions reaching the payroll cut-off |
| **Improve compliance** | All working days have both a Work Report and hour entry before week close |
| **Reduce manager workload** | Managers spend less time chasing employees for missing entries |
| **Improve employee experience** | Employees feel guided and informed, not blamed for missing entries |

### 3.2 Key Performance Indicators (KPIs)

| Metric | Baseline (Current) | Target (6 months post-launch) |
|---|---|---|
| % of working days with both WR and hours logged by Friday | TBD (measure at launch) | +15 percentage points |
| Number of payroll correction requests per month | TBD | −30% |
| Average time to fill a flagged gap after notification | N/A | < 2 minutes |
| Manager hours spent chasing missing timesheets per week | TBD | −40% |
| Feature adoption rate (employees who open Time List tab weekly) | N/A | ≥ 70% within 3 months |

---

## 4. Stakeholders & User Personas

### 4.1 Primary User — Field Employee ("Kari")

> **Kari Pedersen**, Site Worker, 38  
> Works across multiple construction projects in a week. Submits Work Reports from site using PocketLink. Often forgets to add hour entries when she's busy. Gets a call from her manager every second week about missing timesheets.

**Goals:** Finish the week without admin hassle. Know she's on track without having to think about it.  
**Frustrations:** Too many steps to find what's missing. Embarrassed when payroll is delayed because of her.

### 4.2 Secondary User — Site Manager ("Thomas")

> **Thomas Berg**, Site Manager, 45  
> Oversees 12 field employees across 3 active projects. Spends 2–3 hours each Friday chasing incomplete timesheets before payroll cut-off.

**Goals:** Confident that all timesheets are complete before Friday 3pm.  
**Frustrations:** Has to remember who always forgets. Would prefer the app to handle reminders.

### 4.3 Tertiary Stakeholders

| Stakeholder | Interest |
|---|---|
| HR / Payroll team | Accurate data at payroll cut-off, fewer corrections |
| Finance | Accurate project cost reporting based on logged hours |
| IT / Backend team | No new infrastructure required; existing API is sufficient |
| Compliance / Legal | Documented working hours meeting labour regulation requirements |

---

## 5. Current State vs. Proposed State

### 5.1 Current State (As-Is)

```
Employee finishes working day
         ↓
Optionally opens PocketLink → submits Work Report
         ↓
May or may not add hours to that WR
         ↓
Nothing happens if hours are missing
         ↓
Friday: Manager calls/messages employees with missing entries
         ↓
Employee has to remember what they did 3-4 days ago
         ↓
Payroll submitted with gaps or corrections needed
```

### 5.2 Proposed State (To-Be)

```
Employee opens PocketLink on any day of the week
         ↓
Taps "Time List" tab
         ↓
Sees full week at a glance — progress bar, daily rows
         ↓
IF gaps exist → AI Insight banner appears automatically
  "Thursday: open WR with no hours. Friday: no entry."
         ↓
Employee taps "Fill Thursday" → pre-filled form opens
         ↓
Submits in < 2 minutes → gap resolved
         ↓
Banner disappears. Week shows updated progress.
         ↓
Payroll cut-off: complete and accurate data
```

---

## 6. Functional Requirements

### 6.1 Weekly View (FR-01 to FR-05)

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | The app shall display a weekly timesheet view showing all 7 days (Mon–Sun) for the selected week | Must Have |
| FR-02 | Each day row shall show: day name, hours logged, project name, Work Report status, and a visual progress bar | Must Have |
| FR-03 | Weekend days (Sat/Sun) shall be displayed in a visually distinct greyed-out state and excluded from gap detection | Must Have |
| FR-04 | The employee shall be able to navigate to previous weeks using back/forward controls | Must Have |
| FR-05 | Navigation to future weeks (beyond the current week) shall be disabled | Must Have |

### 6.2 Weekly Summary (FR-06 to FR-09)

| ID | Requirement | Priority |
|---|---|---|
| FR-06 | The app shall display the total hours logged for the current week | Must Have |
| FR-07 | The app shall display the employee's weekly target hours (e.g. 40h) | Must Have |
| FR-08 | The app shall display a progress bar showing logged hours vs. target hours | Must Have |
| FR-09 | The progress bar shall change colour from orange to green when 100% of the target is reached | Should Have |

### 6.3 AI Gap Detection (FR-10 to FR-14)

| ID | Requirement | Priority |
|---|---|---|
| FR-10 | The app shall automatically identify any working day (Mon–Fri) where a Work Report exists but no hours have been logged ("WR with no hours") | Must Have |
| FR-11 | The app shall automatically identify any working day (Mon–Fri) where neither a Work Report nor hours have been logged ("missing entry") | Must Have |
| FR-12 | Detected gaps shall be visually highlighted in the daily row (red indicator, warning icon) | Must Have |
| FR-13 | The gap detection shall run on device using data already retrieved from the API — no additional server call required | Must Have |
| FR-14 | Gap detection shall re-run each time the week's data is loaded or refreshed | Must Have |

### 6.4 AI Insight Banner (FR-15 to FR-21)

| ID | Requirement | Priority |
|---|---|---|
| FR-15 | When one or more gaps are detected, the app shall display an AI Insight Banner at the top of the screen | Must Have |
| FR-16 | The banner shall state the total hours remaining to reach the weekly target | Must Have |
| FR-17 | The banner shall list each flagged day with a plain-language description of the issue | Must Have |
| FR-18 | The banner shall provide a "Fill [Day]" button for each flagged day | Must Have |
| FR-19 | Tapping "Fill [Day]" shall navigate the employee to a Work Report / hour entry form pre-filled with the flagged date and suggested project | Must Have |
| FR-20 | The banner shall include a "Dismiss" button that hides the banner for the current session | Must Have |
| FR-21 | If no gaps exist, the AI Insight Banner shall not be shown | Must Have |

### 6.5 Overtime Risk Detection (FR-22 to FR-24)

| ID | Requirement | Priority |
|---|---|---|
| FR-22 | The app shall calculate the employee's current daily pace (total hours logged ÷ days worked so far this week) | Should Have |
| FR-23 | If the projected weekly total (pace × 5) exceeds 42 hours, an overtime risk warning shall be displayed | Should Have |
| FR-24 | The overtime risk check shall only activate if at least 3 working days have elapsed (to avoid false positives early in the week) | Should Have |

### 6.6 Data Refresh (FR-25 to FR-27)

| ID | Requirement | Priority |
|---|---|---|
| FR-25 | The employee shall be able to manually refresh the timesheet data by pulling down on the screen | Must Have |
| FR-26 | A loading indicator shall be shown while data is being fetched | Must Have |
| FR-27 | The AI banner state (dismissed/visible) shall reset each time new data is loaded | Must Have |

---

## 7. User Stories & Acceptance Criteria

---

### US-01 — View Weekly Timesheet

**As a** field employee,  
**I want to** see all my logged hours for the current week in one view,  
**so that** I know where I stand without opening multiple screens.

**Acceptance Criteria:**
- [ ] All 7 days of the week are displayed (Mon–Sun)
- [ ] Each day shows: day abbreviation, hours logged, project name (if any), WR status badge
- [ ] A progress bar shows current week completion %
- [ ] Total logged hours and weekly target are displayed in text below the progress bar
- [ ] Weekends are visually distinct and show a dash (—) for hours

---

### US-02 — AI detects missing time entries

**As a** field employee,  
**I want the** app to automatically spot days where I forgot to log hours,  
**so that** I can fix them without my manager having to call me.

**Acceptance Criteria:**
- [ ] Days with a Work Report but 0 hours show a red indicator and warning icon
- [ ] Days with no Work Report and no hours show a red indicator and warning icon
- [ ] Weekends are never flagged as gaps
- [ ] The AI Insight Banner appears when any gap is detected
- [ ] The banner lists each flagged day with a human-readable reason
- [ ] The banner shows how many hours I need to reach my target

---

### US-03 — Fill a gap with one tap

**As a** field employee,  
**I want to** tap a button next to a flagged day and be taken to a pre-filled form,  
**so that** I can fix the gap in under 2 minutes.

**Acceptance Criteria:**
- [ ] Each flagged day has a "Fill [Day]" button in the AI banner
- [ ] Tapping it opens the Work Report / hour entry creation screen
- [ ] The form is pre-filled with: the correct date, the most likely project (from recent WRs), and the daily target hours as a suggested value
- [ ] After submission, the Time List refreshes and the filled day is no longer flagged

---

### US-04 — Dismiss the AI banner

**As a** field employee,  
**I want to** dismiss the AI banner if I've already noted the gaps,  
**so that** I'm not distracted by an alert I'm aware of.

**Acceptance Criteria:**
- [ ] A "Dismiss" button is visible in the AI banner
- [ ] Tapping Dismiss hides the banner for the current session
- [ ] The banner reappears the next time the screen is loaded if gaps still exist
- [ ] The daily row indicators (red/warning) remain visible even after dismissal

---

### US-05 — Navigate to previous weeks

**As a** field employee,  
**I want to** go back to a previous week to check or correct entries,  
**so that** I can catch anything I missed earlier.

**Acceptance Criteria:**
- [ ] A "previous week" button navigates back one week at a time
- [ ] A "next week" button navigates forward (disabled if on the current week)
- [ ] The week label updates to show the correct date range (e.g. "Week of 12–18 May")
- [ ] Gap detection and AI banner run for whichever week is displayed

---

### US-06 — Overtime risk warning

**As a** field employee,  
**I want to** be warned if I'm on track to exceed the 42h week limit,  
**so that** I can flag this to my manager before it becomes a compliance issue.

**Acceptance Criteria:**
- [ ] Warning only appears if 3 or more working days have hours logged this week
- [ ] Warning shows if projected weekly total (daily pace × 5) exceeds 42h
- [ ] Warning is separate from the AI gap banner (can appear independently)
- [ ] Warning is informational only — no action required

---

## 8. Non-Functional Requirements

### 8.1 Performance

| ID | Requirement |
|---|---|
| NFR-01 | Timesheet data shall load within 2 seconds on a standard 4G connection |
| NFR-02 | Gap detection shall complete within 100ms of data being received (it runs on-device) |
| NFR-03 | The screen shall remain responsive (no freeze) during data loading — use a loading indicator |

### 8.2 Reliability

| ID | Requirement |
|---|---|
| NFR-04 | If the API call fails, the screen shall show an error state with a retry option — not a blank screen |
| NFR-05 | If the API returns partial data (some days missing), the app shall display what is available and flag the rest as unknown |

### 8.3 Accessibility

| ID | Requirement |
|---|---|
| NFR-06 | All icons used for gap indicators must have accessible labels (screen reader support) |
| NFR-07 | Colour alone shall not be the only indicator of status — icons and text must accompany colour changes |
| NFR-08 | Minimum touch target size for all buttons: 44×44dp |

### 8.4 Security & Privacy

| ID | Requirement |
|---|---|
| NFR-09 | The Time List shall only display data for the currently authenticated employee — never another employee's timesheet |
| NFR-10 | No timesheet data shall be cached locally beyond the active session |
| NFR-11 | All API calls shall use the existing authenticated session token — no new auth mechanism |

### 8.5 Compatibility

| ID | Requirement |
|---|---|
| NFR-12 | The feature shall work on Android 8.0+ and iOS 14+ |
| NFR-13 | The feature shall adapt to both phone and tablet screen sizes |

---

## 9. Out of Scope

The following items are explicitly **not** included in this release:

| Item | Reason |
|---|---|
| Submitting or editing Work Reports directly from the Time List screen | This is handled by the existing Work Report flow; Time List is read + navigate only |
| Push notifications for missing time entries | Scheduled for a future notification feature |
| Manager view (seeing other employees' timesheets) | Separate feature with different access controls and data scope |
| Automatic time logging / background tracking | Raises privacy and legal concerns; not appropriate for this release |
| Historical reports or exports (PDF/Excel) | Separate reporting feature |
| AI model training or machine learning | This release uses deterministic rule-based logic only |

---

## 10. Assumptions & Dependencies

### 10.1 Assumptions

| # | Assumption |
|---|---|
| A-01 | The existing API endpoint `GET /api/v1/workReport/hourlist/{employeeId}` returns all 7 days of the requested week, including days with no entries |
| A-02 | The API response includes: date, hoursLogged, workReportId (null if none), workReportStatus, projectName |
| A-03 | The employee's weekly target hours (e.g. 40h) is available from the employee profile API or included in the hourlist response |
| A-04 | Saturday and Sunday are always non-working days (no support for weekend shifts in this release) |
| A-05 | The authenticated employee ID is available from the existing login session |

### 10.2 Dependencies

| Dependency | Owner | Risk if unavailable |
|---|---|---|
| `GET /api/v1/workReport/hourlist/{employeeId}` API | Backend / IT team | Feature cannot function without this endpoint |
| Work Report creation screen (for the "Fill [Day]" navigation) | Mobile team | The gap fill CTA cannot be completed; banner still shows |
| Existing authentication / session management | Backend / Mobile team | No user-specific data can be loaded |
| Weekly target hours per employee | HR system / API | Progress bar and remaining hours cannot be calculated |

---

## 11. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| API does not return days with no entries (only returns days that have data) | Medium | High | Backend team to confirm API contract; if needed, app generates the full 7-day skeleton and merges API data into it |
| Employee weekly target varies (part-time, variable hours) | Medium | Medium | Use per-employee target from API; if not available, default to 40h with a visible note |
| "Fill [Day]" pre-fill fails to determine the right project | Low | Low | Pre-fill with date only; employee selects project manually |
| Employees dismiss the banner habitually and stop seeing gaps | Medium | Medium | Daily row indicators remain visible after dismissal; manager-level view in future release |
| Overtime risk false positives (e.g. employee frontloads hours on purpose) | Low | Low | Minimum 3-day threshold before warning shows; informational only, no action required |

---

## 12. Glossary

| Term | Definition |
|---|---|
| **Work Report (WR)** | A record confirming an employee was present on a project site on a given date |
| **Hour Entry** | The number of hours logged against a Work Report for a specific day |
| **Gap** | A working day (Mon–Fri) with no Work Report and no hours logged |
| **WR with No Hours** | A working day where a Work Report exists but no hours have been recorded against it |
| **Weekly Target** | The contracted number of hours an employee is expected to work in a week (typically 40h) |
| **AI Gap Detection** | On-device logic that automatically identifies missing or incomplete time entries |
| **AI Insight Banner** | The in-app alert card that surfaces detected gaps and provides one-tap fixes |
| **Overtime Risk** | When an employee's mid-week pace projects their weekly total to exceed 42h |
| **PocketLink** | The EG A/S mobile application for field employees |
| **Holetportalen** | The backend platform powering EG A/S project and workforce management |

---

*Document prepared for internal review. Version 1.0 — May 2025.*
