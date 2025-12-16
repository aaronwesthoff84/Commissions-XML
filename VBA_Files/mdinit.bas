Attribute VB_Name = "mdInit"
' Creator:      Niels Perfors
' Github:       https://github.com/niro1987/SAP-Commissions-XML
' License:      SAP-Commissions-XML is licensed under the GNU General Public License v3.0
' Modernized:   Added ROLLUP_TRANSACTION_CREDIT support, improved error handling

Option Explicit

Sub Select_Plan_File_Path()
    On Error GoTo ErrHandler
    
    With Application.FileDialog(msoFileDialogFilePicker)
        
        .AllowMultiSelect = False
        .Filters.Clear
        .Filters.Add "Plan.xml", "*.xml", 1
        .InitialFileName = ThisWorkbook.Names("Plan_File_Path").RefersToRange.Text
        
        If .Show Then
            ThisWorkbook.Names("Plan_File_Path").RefersToRange = .SelectedItems(1)
        End If
        
    End With
    
CleanExit:
    Exit Sub
    
ErrHandler:
    Call mdLogger.LogError("mdInit", "Select_Plan_File_Path", Err.Number, Err.Description)
    MsgBox "Error selecting file: " & Err.Description, vbCritical, "File Selection Error"
    Resume CleanExit
End Sub

Sub Parse()
Attribute Parse.VB_ProcData.VB_Invoke_Func = "P\n14"
    On Error GoTo ErrHandler
    
    Dim PlanFilePath As String
    PlanFilePath = ThisWorkbook.Names("Plan_File_Path").RefersToRange.Text
    
    If Len(PlanFilePath) = 0 Then
        MsgBox "Please select a plan file first.", vbExclamation, "No File Selected"
        Exit Sub
    End If
    
    Dim FSO As New Scripting.FileSystemObject
    If Not FSO.FileExists(PlanFilePath) Then
        MsgBox "File not found: " & PlanFilePath, vbCritical, "File Not Found"
        Exit Sub
    End If
    
    Dim PlanFile As Scripting.TextStream
    Set PlanFile = FSO.OpenTextFile(PlanFilePath)
    
    Dim PlanXML As New MSXML2.DOMDocument60
    PlanXML.LoadXML PlanFile.ReadAll
    Set PlanFile = Nothing
    Set FSO = Nothing
    
    Dim PlanData As MSXML2.IXMLDOMNode
    Set PlanData = PlanXML.ChildNodes(1)
    Set PlanXML = Nothing
    
    mdLogger.ClearLog
    
    PLANS.Clear_Plans
    COMPONENTS.Clear_Components
    CREDITRULES.Clear_CreditRules
    MEASUREMENTS.Clear_Measurements
    INCENTIVES.Clear_Incentives
    DEPOSITS.Clear_Deposits
    LOOKUP_TABLES.Clear_LookupTables
    RATE_TABLES.Clear_RateTables
    QUOTA_TABLES.Clear_QuotaTables
    FIXED_VALUES.Clear_FixedValues
    VARIABLES.Clear_Variables
    FORMULAS.Clear_Formulas
    
    Dim n As MSXML2.IXMLDOMNode
    For Each n In PlanData.ChildNodes
        Parse_Node n
    Next n
    
    MsgBox "Parsing complete! Check the LOG sheet for any warnings or errors.", vbInformation, "Parse Complete"
    
CleanExit:
    Exit Sub
    
ErrHandler:
    Call mdLogger.LogError("mdInit", "Parse", Err.Number, Err.Description, "File: " & PlanFilePath)
    MsgBox "Error parsing XML: " & Err.Description & vbCrLf & vbCrLf & _
           "Check the LOG sheet for details.", vbCritical, "Parse Error"
    Resume CleanExit
End Sub

Sub Parse_Node(ByVal Node As MSXML2.IXMLDOMNode)
    On Error GoTo ErrHandler
    
    Dim n As MSXML2.IXMLDOMNode
    Dim RuleType As String
    
    Select Case Node.nodeName
        Case "PLAN_SET"
            PLANS.Parse_Plans Node
            
        Case "PLANCOMPONENT_SET"
            COMPONENTS.Parse_Components Node
            
        Case "RULE_SET"
            For Each n In Node.ChildNodes
                On Error Resume Next
                RuleType = n.Attributes.getNamedItem("TYPE").Text
                On Error GoTo ErrHandler
                
                If Len(RuleType) = 0 Then
                    Call mdLogger.LogWarning("mdInit", "Parse_Node", "RULE node missing TYPE attribute", "Rule: " & n.Attributes.getNamedItem("NAME").Text)
                    GoTo NextRule
                End If
                
                Select Case RuleType
                    Case "DIRECT_TRANSACTION_CREDIT"
                        CREDITRULES.Parse_CreditRules n
                        
                    Case "ROLLUP_TRANSACTION_CREDIT"
                        CREDITRULES.Parse_CreditRules n
                        
                    Case "PRIMARY_MEASUREMENT", "SECONDARY_MEASUREMENT"
                        MEASUREMENTS.Parse_Measurements n
                        
                    Case "BULK_COMMISSION"
                        INCENTIVES.Parse_Incentives n
                        
                    Case "DEPOSIT"
                        DEPOSITS.Parse_Deposits n
                        
                    Case Else
                        Call mdLogger.LogWarning("mdInit", "Parse_Node", "Unsupported RULE TYPE: " & RuleType, "Rule: " & n.Attributes.getNamedItem("NAME").Text)
                End Select
NextRule:
            Next n
            
        Case "MD_LOOKUP_TABLE_SET"
            LOOKUP_TABLES.Parse_LookupTables Node
            
        Case "RATETABLE_SET"
            RATE_TABLES.Parse_RateTables Node
        
        Case "QUOTA_SET"
            QUOTA_TABLES.Parse_QuotaTables Node
            
        Case "FIXED_VALUE_SET"
            FIXED_VALUES.Parse_FixedValues Node
            
        Case "VARIABLE_SET"
            VARIABLES.Parse_Variables Node
            
        Case "FORMULA_SET"
            FORMULAS.Parse_Formulas Node
            
        Case Else
            Call mdLogger.LogWarning("mdInit", "Parse_Node", "Unsupported SET type: " & Node.nodeName, "")
            
    End Select
    
CleanExit:
    Exit Sub
    
ErrHandler:
    Call mdLogger.LogError("mdInit", "Parse_Node", Err.Number, Err.Description, "Node: " & Node.nodeName)
    Resume CleanExit
End Sub