# Dev Notes

## VBA / Excel

- Main entry point: `mdInit.Parse`
- Node dispatcher: `mdInit.Parse_Node`
- Functional modules (examples):
  - `PLANS`          – plan metadata
  - `COMPONENTS`     – plan components
  - `CREDITRULES`    – credit rule definitions
  - `MEASUREMENTS`   – measurement rules
  - `INCENTIVES`     – incentive rules
  - `DEPOSITS`       – deposit rules
  - `LOOKUP_TABLES`  – lookup table definitions
  - `RATE_TABLES`    – rate tables
  - `QUOTA_TABLES`   – quotas
  - `FIXED_VALUES`   – fixed values
  - `VARIABLES`      – variables
  - `FORMULAS`       – formulas

## Error Handling Pattern (proposed)

Standard structure for key procedures:

```vb
Sub ExampleProc(...)
    On Error GoTo ErrHandler

    ' ... normal logic ...

CleanExit:
    Exit Sub

ErrHandler:
    ' Log or show details, then optionally resume
    Debug.Print "Error in ExampleProc: " & Err.Number & " - " & Err.Description
    Resume CleanExit
End Sub