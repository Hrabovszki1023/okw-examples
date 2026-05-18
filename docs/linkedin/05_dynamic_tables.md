# Selenium Automation That Reads Like a Spec — Part 5: Dynamic Tables

**Series: Selenium Test Automation with OKW4Robot**

---

Here's a table that shuffles its columns on every page load. Chrome might be in row 3 today and row 1 tomorrow. CPU might be column 4 or column 2.

How do you test that?

Most Selenium solutions hardcode cell positions: `table/tr[3]/td[4]`. That breaks the moment the order changes. You end up writing helper methods to scan headers, match rows by name, and cross-reference columns. Fifty lines of code for one value.

## The OKW Solution

```robot
Dynamische Tabelle Chrome CPU Pruefen
    SelectWindow   DynamicTablePage
    MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
    VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
```

One keyword. Table name, row header, column header, variable name. OKW finds the cell regardless of where Chrome or CPU ended up.

`MemorizeTableCellValueByHeaders` reads the table by **header names**, not positions. It:

1. Finds the table element (`TaskManager`)
2. Reads the header row to build a column-name-to-index map
3. Scans rows to find the one containing "Chrome"
4. Returns the value at the "CPU" column intersection
5. Stores it in `${CHROME_CPU}` for later verification

## The YAML

```yaml
TaskManager:
  class: okw_web_selenium.widgets.webse_table.WebSe_Table
  locator: { css: '.lodash-table' }

ChromeCpuLabel:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '.cpu-value' }
```

The table is one widget. No column definitions. No row templates. OKW's table widget reads the HTML structure (`<thead>`, `<tr>`, `<td>`) and builds the lookup at runtime.

## Why Header-Based Lookup Matters

Dynamic tables appear everywhere:
- Task managers (processes reorder by CPU/memory usage)
- Dashboards (columns configurable by user)
- Search results (sort order changes)
- Admin panels (data refreshes between tests)

Position-based selectors (`tr[3]/td[4]`) are brittle by design. Header-based lookup is **semantically stable** — it finds "Chrome's CPU value" regardless of layout.

## Try It Yourself

The example runs against [practice.expandtesting.com/dynamic-table](https://practice.expandtesting.com/dynamic-table).

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*Next in this series: Hover effects — testing elements that only appear when you move the mouse over them.*

#Selenium #TestAutomation #RobotFramework #DynamicContent #QualityAssurance #SoftwareTesting
