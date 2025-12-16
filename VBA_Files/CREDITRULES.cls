VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CREDITRULES"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Sub Clear_CreditRules()
    On Error Resume Next
    Dim LO As ListObject
    Set LO = CREDITRULES.ListObjects(CREDITRULES.CodeName)
    If Not LO Is Nothing Then
        LO.AutoFilter.ShowAllData
        While LO.ListRows.Count > 0
            LO.ListRows(1).Delete
        Wend
    End If
End Sub

Sub Parse_CreditRules(ByVal Node As MSXML2.IXMLDOMNode)
    On Error GoTo ErrHandler
    
    Dim LO As Excel.ListObject, _
        LR As Excel.ListRow
    Set LO = CREDITRULES.ListObjects(CREDITRULES.CodeName)
    
    Dim O As Scripting.Dictionary
    Set O = RULE(Node)
    
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
        i = i + 1: LR.Range(i) = O("EVENT_TYPE")
        i = i + 1: LR.Range(i) = O("TYPE")
        i = i + 1: LR.Range(i) = O("RELATION_TYPE")
        i = i + 1: LR.Range(i) = v("NAME")
        i = i + 1: LR.Range(i) = v("DISPLAY_NAME_FOR_REPORTS")
        i = i + 1: LR.Range(i) = v("IS_REPORTABLE")
        i = i + 1: LR.Range(i) = v("PERIOD_TYPE")
        i = i + 1: LR.Range(i) = v("TYPE")
        i = i + 1: LR.Range(i) = v("UNIT_TYPE")
        i = i + 1: LR.Range(i) = v("VALUE")
        i = i + 1: LR.Range(i) = v("HOLD_REF_NAME")
        i = i + 1: LR.Range(i) = v("HOLD_REF_PERIOD_TYPE")
        i = i + 1: LR.Range(i) = v("CONDITION")
        i = i + 1: LR.Range(i) = v("CREDIT_TYPE")
        i = i + 1: LR.Range(i) = v("DUPLICATE")
        i = i + 1: LR.Range(i) = v("ROLL_UP")
        i = i + 1: LR.Range(i) = v("ROLL_DATE")
        
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
    Next v
    
CleanExit:
    Exit Sub
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "Parse_CreditRules", Err.Number, Err.Description, "Rule: " & O("NAME"))
    Resume CleanExit
End Sub

Private Function RULE(ByVal Node As MSXML2.IXMLDOMNode) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Set RULE = New Scripting.Dictionary
    
    Dim Attr As MSXML2.IXMLDOMAttribute
    For Each Attr In Node.Attributes
        RULE.Add Attr.Name, Attr.Text
    Next Attr
    
    If Not RULE.Exists("RELATION_TYPE") Then
        RULE.Add "RELATION_TYPE", ""
    End If
    
    Dim n As MSXML2.IXMLDOMNode
    Dim ACTION_EXPRESSION_SET As New VBA.Collection
    For Each n In Node.ChildNodes
        Select Case n.nodeName
            Case "ACTION_EXPRESSION_SET"
                Set ACTION_EXPRESSION_SET = ACTION_SET(n, RULE("TYPE"))
                
            Case "CONDITION_EXPRESSION"
                RULE.Add "CONDITION", mdFunctions.Parse_Function(n.FirstChild)
                
            Case "EVENT_TYPE_EXPRESSION"
                RULE.Add "EVENT_TYPE", mdFunctions.Parse_Function(n.FirstChild)
                
            Case "ROLLUP_EXPRESSION_SET"
                Dim rollupNode As MSXML2.IXMLDOMNode
                Set rollupNode = n.SelectSingleNode("ROLLUP_EXPRESSION/RELATION_TYPE")
                If Not rollupNode Is Nothing Then
                    RULE("RELATION_TYPE") = rollupNode.Text
                End If
                
            Case Else
                Call mdLogger.LogWarning("CREDITRULES", "RULE", "Unsupported child node: " & n.nodeName, "Rule: " & RULE("NAME"))
        End Select
    Next n
    RULE.Add "OUTPUT", ACTION_EXPRESSION_SET
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "RULE", Err.Number, Err.Description, "Node: " & Node.nodeName)
    Resume CleanExit
End Function

Private Function ACTION_SET(ByVal Node As MSXML2.IXMLDOMNode, ByVal RuleType As String) As VBA.Collection
    On Error GoTo ErrHandler
    
    Set ACTION_SET = New VBA.Collection
    
    Dim n As MSXML2.IXMLDOMNode
    For Each n In Node.ChildNodes
        If n.FirstChild.nodeName = "FUNCTION" Then
            ACTION_SET.Add ACTION_FUNCTION(n.FirstChild, RuleType)
        Else
            Call mdLogger.LogWarning("CREDITRULES", "ACTION_SET", "Unexpected ACTION_EXPRESSION child: " & n.FirstChild.nodeName, "")
        End If
    Next n
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "ACTION_SET", Err.Number, Err.Description, "Node: " & Node.nodeName)
    Resume CleanExit
End Function

Private Function ACTION_FUNCTION(ByVal Node As MSXML2.IXMLDOMNode, ByVal RuleType As String) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Dim n As MSXML2.IXMLDOMNode, Attr As MSXML2.IXMLDOMAttribute, i As Integer
    Set ACTION_FUNCTION = New Scripting.Dictionary
    
    Dim FunctionID As String
    FunctionID = Node.Attributes.getNamedItem("ID").Text
    
    Select Case RuleType
        Case "DIRECT_TRANSACTION_CREDIT"
            If FunctionID <> "DIRECT_TRANSACTION_CREDIT_ALLGAs" Then
                Call mdLogger.LogWarning("CREDITRULES", "ACTION_FUNCTION", "Unexpected FUNCTION ID for DIRECT_TRANSACTION_CREDIT: " & FunctionID, "")
            End If
            Set ACTION_FUNCTION = ACTION_DIRECT(Node)
            
        Case "ROLLUP_TRANSACTION_CREDIT"
            If FunctionID <> "INDIRECT_TRANSACTION_CREDIT_ALLGAs" Then
                Call mdLogger.LogWarning("CREDITRULES", "ACTION_FUNCTION", "Unexpected FUNCTION ID for ROLLUP_TRANSACTION_CREDIT: " & FunctionID, "")
            End If
            Set ACTION_FUNCTION = ACTION_ROLLUP(Node)
            
        Case Else
            Call mdLogger.LogWarning("CREDITRULES", "ACTION_FUNCTION", "Unsupported credit rule type: " & RuleType, "")
    End Select
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "ACTION_FUNCTION", Err.Number, Err.Description, "FunctionID: " & FunctionID)
    Resume CleanExit
End Function

Private Function ACTION_DIRECT(ByVal Node As MSXML2.IXMLDOMNode) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Dim n As MSXML2.IXMLDOMNode, Attr As MSXML2.IXMLDOMAttribute, i As Integer
    Set ACTION_DIRECT = New Scripting.Dictionary
    
    Set n = Node.ChildNodes(0)
    For Each Attr In n.Attributes
        ACTION_DIRECT.Add Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(1)
    ACTION_DIRECT.Add "VALUE", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(2)
    For Each Attr In n.Attributes
        ACTION_DIRECT.Add "HOLD_REF_" & Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(3)
    ACTION_DIRECT.Add "CONDITION", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(4)
    ACTION_DIRECT.Add "CREDIT_TYPE", n.Text
    
    Set n = Node.ChildNodes(5)
    ACTION_DIRECT.Add "DUPLICATE", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(6)
    ACTION_DIRECT.Add "ROLL_UP", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(7)
    ACTION_DIRECT.Add "ROLL_DATE", mdFunctions.Parse_Function(n)
    
    For i = 1 To 16
        Set n = Node.ChildNodes(i + 7)
        ACTION_DIRECT.Add "GA" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 23)
        ACTION_DIRECT.Add "GN" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 29)
        ACTION_DIRECT.Add "GD" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 35)
        ACTION_DIRECT.Add "GB" & i, mdFunctions.Parse_Function(n)
    Next i
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "ACTION_DIRECT", Err.Number, Err.Description, "ChildNode index: " & i)
    Resume CleanExit
End Function

Private Function ACTION_ROLLUP(ByVal Node As MSXML2.IXMLDOMNode) As Scripting.Dictionary
    On Error GoTo ErrHandler
    
    Dim n As MSXML2.IXMLDOMNode, Attr As MSXML2.IXMLDOMAttribute, i As Integer
    Set ACTION_ROLLUP = New Scripting.Dictionary
    
    Set n = Node.ChildNodes(0)
    For Each Attr In n.Attributes
        ACTION_ROLLUP.Add Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(1)
    ACTION_ROLLUP.Add "VALUE", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(2)
    For Each Attr In n.Attributes
        ACTION_ROLLUP.Add "HOLD_REF_" & Attr.Name, Attr.Text
    Next Attr
    
    Set n = Node.ChildNodes(3)
    ACTION_ROLLUP.Add "CONDITION", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(4)
    ACTION_ROLLUP.Add "CREDIT_TYPE", n.Text
    
    Set n = Node.ChildNodes(5)
    ACTION_ROLLUP.Add "DUPLICATE", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(6)
    ACTION_ROLLUP.Add "ROLL_UP", mdFunctions.Parse_Function(n)
    
    Set n = Node.ChildNodes(7)
    ACTION_ROLLUP.Add "ROLL_DATE", mdFunctions.Parse_Function(n)
    
    For i = 1 To 16
        Set n = Node.ChildNodes(i + 7)
        ACTION_ROLLUP.Add "GA" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 23)
        ACTION_ROLLUP.Add "GN" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 29)
        ACTION_ROLLUP.Add "GD" & i, mdFunctions.Parse_Function(n)
    Next i
    
    For i = 1 To 6
        Set n = Node.ChildNodes(i + 35)
        ACTION_ROLLUP.Add "GB" & i, mdFunctions.Parse_Function(n)
    Next i
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("CREDITRULES", "ACTION_ROLLUP", Err.Number, Err.Description, "ChildNode index: " & i)
    Resume CleanExit
End Function