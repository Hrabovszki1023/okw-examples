# ExpandTesting Dynamic Table -- OKW Selenium Example

Test against the [Dynamic Table](https://practice.expandtesting.com/dynamic-table)
page on practice.expandtesting.com.

## Run

```bash
pip install -r ../../requirements.txt
robot tests/
```

## Test Results

<details>
<summary>Dynamic Table -- 1 test, 1 passed (click to expand)</summary>

```
==============================================================================
DynamicTable
==============================================================================
Dynamische Tabelle Chrome CPU Pruefen :: Prueft den CPU-Wert von C... | PASS |
------------------------------------------------------------------------------
DynamicTable                                                          | PASS |
1 test, 1 passed, 0 failed
==============================================================================
```

</details>

**Detailed Reports (interactive):**
- [Log -- full keyword trace with screenshots](results/log.html)
- [Report -- test summary](results/report.html)

## What This Demonstrates

The dynamic table page shows system processes (Chrome, Firefox, etc.) with
columns like CPU, Memory, Disk, and Network. **Rows and columns change order
on every page load.**

Standard approaches require iterating over rows and columns to find the right
cell. OKW's table keywords handle this with header-based cell access:

```robot
MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
```

This finds the cell at the intersection of the "Chrome" row and "CPU" column,
regardless of their position in the table.

## YAML Locator Files

| File | Purpose |
|---|---|
| `MyAppChrome.yaml` | App definition: Chrome browser + all pages |
| `Chrome.yaml` | Browser window (URL bar, maximize) |
| `DynamicTablePage.yaml` | Page: table element and CPU label |
| `Allpages.yaml` | Page collector |

## Related

- [practice.expandtesting.com](https://practice.expandtesting.com/) -- Free practice pages for test automation
