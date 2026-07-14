# Product Requirements Document
## Meridian Analytics — HR People Dashboard (V1)

**Owner:** Total Rewards / HR Leadership Team | **Status:** Draft for build | **Date:** 2026-07-13

---

## 1. Purpose

Meridian Analytics' HR leadership team (CHRO + HR leaders) currently reviews headcount, turnover, learning, compensation, and recruiting data by manually assembling spreadsheets before each leadership review. This dashboard replaces that manual assembly: an HR leader uploads the employee master file (and, optionally, the AI Readiness results file), clicks **Update**, and gets a live analytics snapshot on screen plus a downloadable report — with no manual pivot tables, no formulas, no waiting on an analyst.

**Primary outcome:** one person, one upload, one click, a boardroom-ready snapshot.

## 2. Scope — Version 1

**In scope:**
- Single-user, browser-based tool (local app or internal web app) — no login/roles needed for V1; assume the person operating it is trusted with full data access.
- Two file inputs: (a) Employee Master (Excel/CSV, required), (b) AI Readiness Results (Excel, optional — powers the L&D tab only).
- Manual **Update** action that reprocesses whichever files are currently loaded and refreshes all three tabs.
- Three tabs: **Executive Dashboard**, **Learning & Development**, **Compensation & Recruitment**.
- One-click **Download Report** producing a static snapshot (PDF or PPTX) of the current view.
- All computation is client-side or in an ephemeral backend process — no data is persisted to a database in V1.

**Out of scope for V1** (explicitly deferred):
- Uploading the separate Compensation History, Performance Review History, or Recruiting Funnel workbooks — V1 computes compensation and recruiting metrics only from fields already present in the Employee Master. Ingesting those richer files is a V2 candidate.
- Multi-user accounts, permissions, or audit logging.
- Historical trending across multiple saved snapshots (V1 shows the state of the file(s) uploaded "as of" that upload; no time-series database).
- Automated data refresh from HRIS (this is upload-driven only).

## 3. Users

- **CHRO** — reviews the Executive Dashboard before leadership/board meetings; primary consumer of the downloadable report.
- **HR Leadership Team** (Total Rewards, Talent Acquisition, L&D, HRBPs) — uploads updated files, drills into their functional tab, exports cuts for their own reviews.

## 4. User Stories

1. As the CHRO, I upload the latest employee master export and click Update so the whole picture — headcount, turnover, comp, recruiting — refreshes at once, without asking anyone to rebuild slides.
2. As an HR leader, I upload the AI Readiness results file separately so the L&D tab shows adoption/capability scores without touching the employee master.
3. As the CHRO, I download a report at the end of the session so I can share a static snapshot with the CEO/board without giving them access to the tool.
4. As an HR leader, I see headcount broken down by department, location, and level in one view so I can answer "where are our people" without cross-referencing three spreadsheets.
5. As an HR leader, I see turnover (voluntary vs. involuntary) so I can flag retention risk by function or location before it becomes a board question.
6. As the CHRO, if I upload a file with missing or malformed columns, I want a clear error message telling me what's wrong, not a silent blank dashboard.

## 5. Functional Requirements

### 5.1 Upload
- Accept **Employee Master** as `.xlsx` or `.csv`. Required columns (minimum): `employee_id`, `employment_status` (Active/Terminated), `department`, `function`, `office_location`, `career_track`, `career_level`, `hire_date`, `termination_date`, `termination_type` (Voluntary/Involuntary), `base_salary`, `currency`, `compa_ratio`, `range_penetration`, `target_bonus_pct`, `last_promotion_date`, `source_of_hire`.
- Accept **AI Readiness Results** as `.xlsx` (optional, separate upload control). Expected sheet `Individual Results` with columns: `Emp ID`, `Name`, `Title`, `Level`, `Overall Score`, `Tier`, plus per-dimension scores (e.g., HR Tech & AI, Data & Analytics, Change Mgmt, Ethical AI, Strategic, Vendor Mgmt, Cross-func Collab, User Experience, Agentic AI, Governance & Risk).
- Validate on upload: required columns present, no duplicate `employee_id`, dates parse correctly. On failure, show a specific error (missing column name, row number of bad data) — never fail silently.
- Replacing a file (re-upload) fully replaces the prior dataset for that input; no merge logic in V1.

### 5.2 Update button
- A single **Update** control reprocesses all currently loaded files and re-renders all three tabs from scratch. No auto-refresh on upload alone — the user must click Update, so they control exactly when the view changes.
- Show a last-updated timestamp and the source filename(s) currently loaded, visible on every tab.

### 5.3 Tab: Executive Dashboard
- **Headcount by department** — bar chart + table, active employees only, with total.
- **Headcount by location** — bar chart + table (Boston, Denver, Toronto, Dublin, Remote-US, or whatever values are present in the file).
- **Headcount by level** — distribution across `career_level` (IC: P1–P7, Mgmt: M3–M8), split by `career_track`.
- **Turnover** — voluntary and involuntary turnover rate, computed as terminations of that type ÷ average active headcount, for the trailing 12 months from the file's most recent `termination_date`/`hire_date` data; shown overall and by department.
- All charts must cross-filter or at minimum be individually filterable by department and location.

### 5.4 Tab: Learning & Development
- Dedicated upload control for the AI Readiness Results file (independent of the employee master upload).
- Summary view: average Overall Score and Tier distribution across the People function (or whichever population is in the file).
- Dimension breakdown: average score per dimension (e.g., HR Tech & AI, Data & Analytics, Ethical AI, Agentic AI, etc.), highlighting strongest and weakest dimensions.
- Individual-level table (Name, Title, Level, Overall Score, Tier) sortable/filterable — treat as sensitive; see Section 6.
- If no AI Readiness file has been uploaded, this tab shows an empty state prompting upload — it must not block the other two tabs.

### 5.5 Tab: Compensation & Recruitment
- **Compensation:** compa-ratio and range-penetration distribution (overall and by department/level), average base salary by department/level/location, % of employees below 0.90 compa-ratio (a standard flag for below-range pay), bonus target % by level.
- **Recruitment:** new hires in trailing 12 months (by `hire_date`) broken down by department and `source_of_hire`; average tenure at level; recent promotions count (`last_promotion_date` within trailing 12 months) by department.
- Note in-app that deeper recruiting funnel metrics (time-to-fill, offer acceptance, pipeline by stage) require the separate Recruiting Funnel file and are planned for V2.

### 5.6 Downloadable report
- One **Download Report** button generates a PDF (preferred) or PPTX snapshot containing: title page with upload timestamp/filenames, then one page/slide per tab reproducing its key charts and headline numbers.
- Report must be generated from whatever is currently on screen (respecting any active filters) so what the CHRO downloads matches what they were just looking at.

## 6. Data & Privacy

- The Employee Master contains compensation, performance, and demographic fields (e.g., `race_ethnicity`, `gender`, `disability_self_id`). V1 must **not** display or aggregate demographic self-ID fields on any tab — they are out of scope for this dashboard's purpose and should be ignored by the parser even if present in the file.
- Individual-level compensation and AI Readiness data (name-level rows) should be visible only within the tool session and the downloaded report — no data leaves the local environment via API calls to third parties.
- No file is persisted after the session ends unless the user explicitly saves/exports it; treat uploaded files as transient working data, consistent with the Baladna/PIH principle of not retaining sensitive HR data beyond its working purpose.
- All monetary figures must respect the `currency` field per employee (USD/CAD/EUR) — do not silently sum across currencies without conversion or clear labeling.

## 7. Acceptance Criteria

- [ ] Uploading a valid Employee Master `.xlsx` or `.csv` and clicking Update populates all fields on the Executive Dashboard and Compensation & Recruitment tabs with no errors.
- [ ] Uploading a valid AI Readiness `.xlsx` and clicking Update populates the L&D tab; the other two tabs are unaffected by this upload.
- [ ] Re-uploading a corrected file and clicking Update fully replaces the prior snapshot (no stale numbers remain from the first upload).
- [ ] Uploading a file missing a required column produces a specific, readable error naming the missing column — the app does not crash or render a blank/broken dashboard.
- [ ] Headcount totals shown on the Executive Dashboard tab match a manual count of `employment_status = Active` rows in the source file.
- [ ] Turnover rate shown matches a manual calculation of (voluntary or involuntary terminations in trailing 12 months) ÷ (average active headcount over the same period).
- [ ] Demographic self-ID fields (`gender`, `race_ethnicity`, `veteran_status`, `disability_self_id`) do not appear anywhere in the UI or the downloaded report.
- [ ] Clicking Download Report produces a file that matches what is currently displayed on screen, including any active filters.
- [ ] The entire flow — upload employee master, upload AI readiness file, click Update, review three tabs, download report — can be completed by a non-technical HR leader in under 5 minutes without instructions.
