Attribute VB_Name = "mdLogger"
' ============================================================================
' Module: mdLogger
' Purpose: Centralized error logging and debugging support
' ============================================================================

Option Explicit

Private Const LOG_SHEET_NAME As String = "LOG"

Public Sub LogError(ByVal ModuleName As String, _
                   ByVal ProcedureName As String, _
                   ByVal ErrNumber As Long, _
                   ByVal ErrDescription As String, _
                   Optional ByVal Context As String = "")
    
    On Error Resume Next
    
    Dim ws As Worksheet
    Dim lRow As Long
    
    Set ws = GetOrCreateLogSheet()
    
    If Not ws Is Nothing Then
        lRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row + 1
        
        ws.Cells(lRow, 1).Value = Now
        ws.Cells(lRow, 2).Value = ModuleName
        ws.Cells(lRow, 3).Value = ProcedureName
        ws.Cells(lRow, 4).Value = ErrNumber
        ws.Cells(lRow, 5).Value = ErrDescription
        ws.Cells(lRow, 6).Value = Context
    End If
    
    Debug.Print Now & " | ERROR in " & ModuleName & "." & ProcedureName & _
                " | Err: " & ErrNumber & " - " & ErrDescription & _
                IIf(Len(Context) > 0, " | Context: " & Context, "")
    
End Sub

Public Sub LogWarning(ByVal ModuleName As String, _
                     ByVal ProcedureName As String, _
                     ByVal Message As String, _
                     Optional ByVal Context As String = "")
    
    On Error Resume Next
    
    Dim ws As Worksheet
    Dim lRow As Long
    
    Set ws = GetOrCreateLogSheet()
    
    If Not ws Is Nothing Then
        lRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row + 1
        
        ws.Cells(lRow, 1).Value = Now
        ws.Cells(lRow, 2).Value = ModuleName
        ws.Cells(lRow, 3).Value = ProcedureName
        ws.Cells(lRow, 4).Value = "WARNING"
        ws.Cells(lRow, 5).Value = Message
        ws.Cells(lRow, 6).Value = Context
    End If
    
    Debug.Print Now & " | WARNING in " & ModuleName & "." & ProcedureName & _
                " | " & Message & _
                IIf(Len(Context) > 0, " | Context: " & Context, "")
    
End Sub

Public Sub ClearLog()
    On Error Resume Next
    
    Dim ws As Worksheet
    Set ws = GetLogSheet()
    
    If Not ws Is Nothing Then
        Dim lo As ListObject
        Set lo = ws.ListObjects(1)
        
        If Not lo Is Nothing Then
            lo.AutoFilter.ShowAllData
            While lo.ListRows.Count > 0
                lo.ListRows(1).Delete
            Wend
        End If
    End If
    
End Sub

Private Function GetOrCreateLogSheet() As Worksheet
    On Error Resume Next
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(LOG_SHEET_NAME)
    
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = LOG_SHEET_NAME
        
        ws.Cells(1, 1).Value = "Timestamp"
        ws.Cells(1, 2).Value = "Module"
        ws.Cells(1, 3).Value = "Procedure"
        ws.Cells(1, 4).Value = "Error Number"
        ws.Cells(1, 5).Value = "Description"
        ws.Cells(1, 6).Value = "Context"
        
        ws.Range("A1:F1").Font.Bold = True
        ws.Columns("A:F").AutoFit
        
        Dim lo As ListObject
        Set lo = ws.ListObjects.Add(xlSrcRange, ws.Range("A1:F1"), , xlYes)
        lo.Name = "LogTable"
        lo.TableStyle = "TableStyleMedium2"
    End If
    
    Set GetOrCreateLogSheet = ws
    
End Function

Private Function GetLogSheet() As Worksheet
    On Error Resume Next
    Set GetLogSheet = ThisWorkbook.Worksheets(LOG_SHEET_NAME)
End Function