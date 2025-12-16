Attribute VB_Name = "mdFunctions"
Option Explicit

Function Parse_Function(ByVal Node As MSXML2.IXMLDOMNode) As String
    On Error GoTo ErrHandler
    
    Dim Prefix As String, Suffix As String, Operator As String
    
    Select Case Node.nodeName
        Case _
            "UNIT_TYPE", _
            "CREDIT_TYPE", _
            "BOOLEAN", _
            "DATA_FIELD", _
            "PERIOD_TYPE", _
            "RELATION_TYPE"
                Parse_Function = Node.Text
        Case "MDLTVAR_REF"
            Parse_Function = Node.Attributes.getNamedItem("NAME").Text
        Case "RULE_ELEMENT_REF"
            Parse_Function = Node.Attributes.getNamedItem("NAME").Text
        Case "MEASUREMENT_REF"
            Parse_Function = Node.Attributes.getNamedItem("NAME").Text
        Case "INCENTIVE_REF"
            Parse_Function = Node.Attributes.getNamedItem("NAME").Text
        Case "MDLT_REF"
            Parse_Function = Node.Attributes.getNamedItem("NAME").Text
        Case "FUNCTION"
            Parse_Function = F_Parse(Node)
        Case "OPERATOR"
            Parse_Function = O_Parse(Node)
        Case "STRING_LITERAL"
            If Node.Text = "NULL" Then
                Parse_Function = "-"
            Else
                Parse_Function = """" & Node.Text & """"
            End If
        Case "VALUE"
            Parse_Function = Node.Attributes(0).Text
        Case Else
            Call mdLogger.LogWarning("mdFunctions", "Parse_Function", "Unsupported node type: " & Node.nodeName, "")
            Parse_Function = "[" & Node.nodeName & "]"
    End Select
    
    Dim NodeAttr As MSXML2.IXMLDOMAttribute
    
    For Each NodeAttr In Node.Attributes
        If NodeAttr.Name = "PERIOD_OFFSET" And NodeAttr.Text <> "0" Then
            Parse_Function = Parse_Function & "-" & NodeAttr.Text
        End If
        
        If NodeAttr.Name = "RELATION_TYPE" Then
            Parse_Function = Parse_Function & "(" & NodeAttr.Text & ")"
        End If

        If NodeAttr.Name = "PERIOD_TYPE" Then
            Parse_Function = Parse_Function & ":" & NodeAttr.Text
        End If
    Next NodeAttr
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("mdFunctions", "Parse_Function", Err.Number, Err.Description, "Node: " & Node.nodeName)
    Parse_Function = "[ERROR]"
    Resume CleanExit
End Function

Private Function F_Parse(ByVal Node As MSXML2.IXMLDOMNode) As String
    On Error GoTo ErrHandler
    
    Dim FuncName As String, FuncParts() As String
    FuncName = Node.Attributes.getNamedItem("ID").Text
    ReDim FuncParts(1 To Node.ChildNodes.Length)
    Dim i As Integer
    For i = 1 To Node.ChildNodes.Length
        FuncParts(i) = mdFunctions.Parse_Function(Node.ChildNodes(i - 1))
    Next i
    F_Parse = FuncName & "(" & Join(FuncParts, ", ") & ")"
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("mdFunctions", "F_Parse", Err.Number, Err.Description, "FuncName: " & FuncName)
    F_Parse = "[ERROR:" & FuncName & "]"
    Resume CleanExit
End Function

Private Function O_Parse(ByVal Node As MSXML2.IXMLDOMNode) As String
    On Error GoTo ErrHandler
    
    Dim Operator As String, Wrapped As Boolean
    
    Wrapped = Node.Attributes.Length = 2
    
    Select Case Node.Attributes.getNamedItem("ID").Text
        Case "ISEQUALTO_OPERATOR":          Operator = " = "
        Case "NOTEQUALTO_OPERATOR":         Operator = " <> "
        Case "AND_OPERATOR":                Operator = " AND "
        Case "OR_OPERATOR":                 Operator = " OR "
        Case "MULTIPLY_OPERATOR":           Operator = " * "
        Case "DIVISION_OPERATOR":           Operator = " / "
        Case "ADDITION_OPERATOR":           Operator = " + "
        Case "SUBTRACTION_OPERATOR":        Operator = " - "
        Case "LESSTHAN_OPERATOR":           Operator = " < "
        Case "LESSTHANOREQUALTO_OPERATOR":  Operator = " <= "
        Case "GREATERTHAN_OPERATOR":        Operator = " > "
        Case "GREATERTHANOREQUALTO_OPERATOR": Operator = " >= "
        Case "NOT_OPERATOR":                Operator = "NOT "
        Case Else
            Call mdLogger.LogWarning("mdFunctions", "O_Parse", "Unknown operator: " & Node.Attributes.getNamedItem("ID").Text, "")
            Operator = " [" & Node.Attributes.getNamedItem("ID").Text & "] "
    End Select
    
    Dim LeftSide As String, RightSide As String
    LeftSide = mdFunctions.Parse_Function(Node.ChildNodes(0))
    
    If Node.ChildNodes.Length > 1 Then
        RightSide = mdFunctions.Parse_Function(Node.ChildNodes(1))
        O_Parse = LeftSide & Operator & RightSide
    Else
        O_Parse = Operator & LeftSide
    End If
    
    If Wrapped Then
        O_Parse = "(" & O_Parse & ")"
    End If
    
CleanExit:
    Exit Function
    
ErrHandler:
    Call mdLogger.LogError("mdFunctions", "O_Parse", Err.Number, Err.Description, "Operator: " & Operator)
    O_Parse = "[ERROR]"
    Resume CleanExit
End Function    