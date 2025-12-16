# SAP Commissions XML Parser – Modernization TODO

## Scope

This fork modernizes the original SAP Commissions XML Excel parser to better
support current SAP Commissions XML (e.g. VERSION="33.0") and additional rule
types, while improving error handling and maintainability.

**Important:** No customer-specific XML (e.g. Animal Health plan files) should
be committed to this repository. Keep such files local for testing only.

---

## 1. Current State & Known Issues

- Codebase originally written for SAP Commissions XML VERSION="33.0".
- Parsing macros live in the Excel workbook VBA project.
- Error handling is minimal (`Stop` in `ErrHandler`), making it hard to see
  which node or attribute caused a failure.
- `CREDITRULES` parsing:
  - Known gap: **INDIRECT** rule types (or certain indirect rules) are not
    handled when generating the `creditrules` tab.
  - Some newer rule subtypes / attributes from current SAP exports may be
    missing from the parser logic.

---

## 2. High-Level Goals

1. **Schema Alignment**
   - Confirm the XML structure used by the latest SAP Commissions export
     (using a *local* sample plan file, not checked into GitHub).
   - Update parsing code to handle any new / changed:
     - Node names
     - Attributes
     - Rule types (especially INDIRECT rules)
     - Additional sets (if any)

2. **Robust Error Handling & Logging**
   - Replace `Stop`-only error handlers with:
     - Descriptive messages (procedure name, node name, error number, description).
     - Optional logging to a worksheet or the Immediate window.
   - Ensure errors don’t silently skip important data.

3. **Maintainability**
   - Keep module interfaces consistent (`Parse_*` patterns).
   - Add comments where we support new rule types or behavior.
   - Keep changes backwards-compatible with older XMLs as much as possible.

---

## 3. Work Breakdown

### 3.1 Setup & Baseline

- [X] Fork the original repo into personal or org GitHub account.
- [X] Create a working branch, e.g. `modernize-xml-v33`.
- [ ] Export the VBA modules from the current workbook (optional for diffing).
- [ ] Verify that the original code compiles in the VBA editor
      (`Debug` → `Compile VBAProject`).

### 3.2 Error Handling & Instrumentation

- [ ] Standardize error handlers in key entry points:
  - [ ] `mdInit.Parse`
  - [ ] `mdInit.Parse_Node`
- [ ] Add basic logging pattern:
  - [ ] Record node name and rule type when parsing fails.
  - [ ] Optionally create a simple `LOG` worksheet:
        - Columns: `Timestamp`, `Module`, `Procedure`, `NodeName`, `Details`.
- [ ] Replace bare `Stop` calls with:
  - A clear message/log entry.
  - Optional `Resume Next` for non-fatal issues (where appropriate).

### 3.3 XML Structure Review (Local Only)

> These steps use local files and should NOT result in committing any
> customer-specific XML to the repo.

- [ ] Take a representative sample XML export (e.g. Animal Health plan).
- [ ] Map high-level structure:
  - [ ] Top-level sets (`PLAN_SET`, `PLANCOMPONENT_SET`, `RULE_SET`, etc.).
  - [ ] Identify any **new** sets vs. the original code.
- [ ] For `RULE_SET`:
  - [ ] Enumerate all `TYPE` values present (e.g. `DIRECT_TRANSACTION_CREDIT`,
        `PRIMARY_MEASUREMENT`, `INDIRECT`, etc.).
  - [ ] Compare to cases handled in `CREDITRULES`, `MEASUREMENTS`,
        `INCENTIVES`, `DEPOSITS`, etc.

### 3.4 CREDITRULES Enhancements

- [ ] Identify which **INDIRECT** (or other) rule types exist in the XML and
      are currently **not** represented in the `creditrules` sheet.
- [ ] Extend the parsing logic:
  - [ ] Add `Case` branches for missing rule types in `RULE_SET` handling.
  - [ ] Update `CREDITRULES.Parse_CreditRules` (and related helpers) to:
        - [ ] Read required attributes/child nodes for those rules.
        - [ ] Populate the `creditrules` sheet with appropriate columns.
- [ ] Add comments documenting:
  - [ ] Each newly supported rule type.
  - [ ] Any assumptions made about XML attributes.

### 3.5 Regression Testing

- [ ] Using local XML samples (not in repo):
  - [ ] Run the `Parse` macro on the existing original XML used by the tool
        (if available).
  - [ ] Run the `Parse` macro on the current SAP XML export (e.g. Animal Health).
- [ ] Verify:
  - [ ] `creditrules` sheet includes indirect rule types as expected.
  - [ ] No runtime errors with representative data.
  - [ ] Unsupported sets/types are clearly logged (but don’t crash parsing).

### 3.6 Documentation & Cleanup

- [ ] Update `README.md` with:
  - [ ] Short “Modernization Notes” section.
  - [ ] Clarification that customer XML is never committed.
- [ ] Document any dev notes / caveats in this `TODO.md`:
  - [ ] Known but intentionally unsupported node types.
  - [ ] Any limitations due to legacy Excel/VBA constraints.
- [ ] Optionally, tag a release in GitHub once stable (e.g. `v1.1-modernized`).

---

## 4. Open Questions / Parking Lot

- [ ] Are there additional plan XML versions beyond `VERSION="33.0"` we want
      to remain compatible with?
- [ ] Any other sheets besides `creditrules` that are known to miss certain
      rule types?
- [ ] Do we want a simple config (e.g. a sheet) to toggle which rule types
      to parse or ignore?

---

## 5. Notes

- Test XML such as `Animal Health Comp Plan.xml` should remain **local only**
  and must **not** be added to this GitHub repository.
- When sharing issues or examples publicly, sanitize or fabricate XML samples
  instead of using real customer data.