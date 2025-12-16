# Contributing Guidelines

## Working with VBA Code

1. **Never commit customer XML files** - Keep test files local only
2. **Export VBA modules** before committing changes (optional workflow)
3. **Test with local XML** before pushing changes

## Error Handling Standards

All parsing procedures should follow this pattern:

```vb
Public Sub Parse_Something(ByVal oNode As MSXML2.IXMLDOMNode)
    On Error GoTo ErrHandler
    
    ' Main logic
    
CleanExit:
    Exit Sub
    
ErrHandler:
    Call LogError "ModuleName", "Parse_Something", Err.Number, Err.Description, oNode.nodeName
    Resume CleanExit
End Sub

Testing Checklist
 Code compiles without errors (Debug > Compile VBAProject)
 Tested with sample XML (local only)
 Error handling logs useful information
 No customer data in commits