# DynamicTable — Dynamic Table with Changing Layout

**Page:** https://practice.expandtesting.com/dynamic-table

**Test file:** `tests/DynamicTable.robot`

## What This Example Demonstrates

- **Table keywords** (`MemorizeTableCellValueByHeaders`) for reading
  values from HTML tables.
- Handling **dynamic table layouts** where column order changes on
  every page load.
- **Cross-verification** between a table cell and a separate label
  on the page.
- The **Memorize/Verify pattern**: read a value, store it, verify it
  elsewhere.

## Page Specifics

The page displays a task manager table with processes (Chrome, Firefox,
etc.) and their resource usage (CPU, Memory, Disk, Network). The table
has two important characteristics:

1. **Column order changes** on every page load — CPU might be column 2
   on one load and column 4 on the next.
2. A **reference label** below the table shows the expected Chrome CPU
   value (e.g., "Chrome CPU: 3.2%").

This makes hardcoded column indices unreliable. OKW solves this with
header-based cell access.

## Implementation

### Header-Based Table Access

The YAML defines the table as a single `WebSe_Table` widget:

```yaml
TaskManager:
  class: okw_web_selenium.widgets.webse_table.WebSe_Table
  locator: { css: 'table' }
```

The test uses `MemorizeTableCellValueByHeaders` to read a cell by
**row name** and **column header** — independent of column position:

```robot
MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
```

This reads the cell at row "Chrome", column "CPU" and stores it as
`CHROME_CPU` in the OKW memory (`$MEM{CHROME_CPU}`).

### Cross-Verification

The stored value is then verified against the reference label:

```robot
VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
```

This confirms that the table and the label show the same CPU value —
regardless of column order.

### OnFailNOISE

The first four steps (phases 1-3: start app, navigate to page) are
wrapped with `OnFailNOISE`. If the browser fails to start or the page
doesn't load, the test is marked NOISE instead of FAIL.

## Test Cases

| Test | Verifies |
|---|---|
| Dynamische Tabelle Chrome CPU Pruefen | Chrome CPU value matches between table and label |
