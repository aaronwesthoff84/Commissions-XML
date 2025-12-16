VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "INCENTIVES"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Sub Clear_Incentives()
    Dim LO As ListObject
    Set LO = INCENTIVES.ListObjects(INCENTIVES.CodeName)
    LO.AutoFilter.ShowAllData
    While LO.ListRows.Count > 0
        LO.ListRows(1).Delete
    Wend
End Sub

Sub Parse_Incentives(ByVal Node As MSXML2.IXMLDOMNode)
    On Error GoTo ErrHandler
    
    Dim LO As Excel.ListObject, _
        LR As Excel.ListRow
    Set LO = INCENTIVES.ListObjects(INCENTIVES.CodeName)
    
    Dim O As Scripting.Dictionary
    Set O = RULE(Node)
    If Err.Number > 0 Then: Stop
    
    Dim v As Variant, i As Integer, y As Integer
    For Each v In O("OUTPUT")
        Set LR = LO.ListRows.Add
        i = 0
        i = i + 1: LR.Range(i) = O("CALENDAR")
        i = i + 1: LR.Range(i) = O("NAME")
        i = i + 1: LR.Range(i) = O("DESCRIPTION")
        i = i + 1: LR.Range(i) = O("EFFECTIVE_START_DATE")
        i = i + 1: LR.Range(i) = O("EFFECTIVE_END_DATE")
        i = i + 1: LR.Range(i) = O("CONDITION")
        i = i + 1: LR.Range(i) = O("TYPE")
        i = i + 1: LR.Range(i) = v("NAME")
        i = i + 1: LR.Range(i) = v("DISPLAY_NAME_FOR_REPORTS")
        i = i + 1: LR.Range(i) = v("IS_REPORTABLE")
        i = i + 1: LR.Range(i) = v("PERIOD_TYPE")
        i = i + 1: LR.Range(i) = v("TYPE")
        i = i + 1: LR.Range(i) = v("UNIT_TYPE")
        i = i + 1: LR.Range(i) = v("VALUE")
        i = i + 1: LR.Range(i) = v("RATE")
        i = i + 1: LR.Range(i) = v("HOLD_REF_NAME")
        i = i + 1: LR.Range(i) = v("HOLD_REF_PERIOD_OFFSET")
        i = i + 1: LR.Range(i) = v("HOLD_REF_PERIOD_TYPE")
        
        If O("TYPE") = "BULK_COMMISSION" Then
            y = 0
            For i = i + 1 To i + 16
                y = y + 1
                LR.Range(i) = v("GA" & y)
            Next i
            y = 0
            For i = i To i + 5
                y = y + 1
                LR.Range(i) = v("GN" & y)
            Next i
            y = 0
            For i = i To i + 5
                y = y + 1
                LR.Range(i) = v("GD" & y)
            Next i
            y = 0
            For i = i To i + 5
                y = y + 1
                LR.Range(i) = v("GB" & y)
            Next i
        End If
        
    Next v
Exit Sub
ErrHandler:
    Stop
End Sub

Private Function RULE(ByVal Node As MSXML2.IXMLDOMNode) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Set RULE = New Scripting.Dictionary
    
    Dim Attr As MSXML2.IXMLDOMAttribute
    For Each Attr In Node.Attributes
        RULE.Add Attr.Name, Attr.Text
    Next Attr
    
    Dim n As MSXML2.IXMLDOMNode
    Dim ACTION_EXPRESSION_SET As New VBA.Collection
    For Each n In Node.ChildNodes
        Select Case n.nodeName
            Case "ACTION_EXPRESSION_SET"
                Set ACTION_EXPRESSION_SET = ACTION_SET(n)
            Case "CONDITION_EXPRESSION"
                RULE.Add "CONDITION", mdFunctions.Parse_Function(n.FirstChild)
            Case Else
                Debug.Print "Incentive Rule '" & n.nodeName & "' is currently not supported."
        End Select
    Next n
    RULE.Add "OUTPUT", ACTION_EXPRESSION_SET
Exit Function
ErrHandler:
    Stop 'expected here
End Function

Private Function ACTION_SET(ByVal Node As MSXML2.IXMLDOMNode) As VBA.Collection
    On Error GoTo ErrHandler
    
    Set ACTION_SET = New VBA.Collection
    
    Dim n As MSXML2.IXMLDOMNode
    For Each n In Node.ChildNodes
        ACTION_SET.Add ACTION(n.FirstChild)
    Next n
Exit Function
ErrHandler:
    Stop 'Or here now?
End Function

Private Function ACTION(ByVal Node As MSXML2.IXMLDOMNode) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Dim n As MSXML2.IXMLDOMNode, Attr As MSXML2.IXMLDOMAttribute, i As Integer, x As Integer
    Set ACTION = New Scripting.Dictionary
    
    Set n = Node.ChildNodes(0)      'OUTPUT_REFERENCE
    For Each Attr In n.Attributes
        ACTION.Add Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(1)      'VALUE
    ACTION.Add "VALUE", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(2)      'HOLD
    For Each Attr In n.Attributes
        ACTION.Add "HOLD_REF_" & Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(3)      'HOLD_CONDITION
    ACTION.Add "RATE", mdFunctions.Parse_Function(n)
    
    If Node.Attributes.getNamedItem("RULE_TYPES").Text = "BULK_COMMISSION" Then
        x = Node.ChildNodes.Length - 35
        'TODO Debug.Print Node.Attributes.getNamedItem("ID").Text, Node.ChildNodes.Length
        
        For i = 1 To 16
            Set n = Node.ChildNodes(i + x)    'GA's 1 trough 16
            ACTION.Add "GA" & i, mdFunctions.Parse_Function(n)
        Next i
        x = x + i - 1
        
        For i = 1 To 6
            Set n = Node.ChildNodes(i + x)    'GN's 1 trough 6
            ACTION.Add "GN" & i, mdFunctions.Parse_Function(n)
        Next i
        x = x + i - 1
        
        For i = 1 To 6
            Set n = Node.ChildNodes(i + x)    'GD's 1 trough 6
            ACTION.Add "GD" & i, mdFunctions.Parse_Function(n)
        Next i
        x = x + i - 1
        
        For i = 1 To 6
            Set n = Node.ChildNodes(i + x)    'GB's 1 trough 6
            ACTION.Add "GB" & i, mdFunctions.Parse_Function(n)
        Next i
    End If
Exit Function
ErrHandler:
    Stop
End Function
