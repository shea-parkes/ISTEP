

Sub WriteOutFlat()
'OBJECTIVE: Flatten the source data into a fully long format for import into analytic software
'
'
'DEVELOPER NOTES:
'  * Data source: http://www.doe.in.gov/sites/default/files/accountability/2013-istep-school-results-grade.xlsx
'  * Must strip worksheet names to just the year for this to work
'  * This does not output the legacy scores for grades 9+ in the oldest years

Dim OutFile As String
OutFile = ActiveWorkbook.FullName & ".txt"
If Dir(OutFile) <> "" Then Kill (OutFile)
Open OutFile For Output As #1

'Put in a header
Print #1, "district|school|year|grade|subject|n_pass|pct_pass"


Dim year As Integer
For year = 2007 To 2013

    Dim i_row As Integer
    i_row = 3
    
    Do Until IsEmpty(Sheets(CStr(year)).Cells(i_row, 4))
    
        Dim grade As Integer
        For grade = 3 To 8
        
            Dim col_grade_start As Integer
            col_grade_start = 5 * (grade - 2)
            
            If (Not IsEmpty(Sheets(CStr(year)).Cells(i_row, col_grade_start))) _
                And (Sheets(CStr(year)).Cells(i_row, col_grade_start).Value <> "***") Then
                Print #1, Sheets(CStr(year)).Cells(i_row, 1).Value; "-"; Sheets(CStr(year)).Cells(i_row, 2).Value;
                Print #1, "|"; Sheets(CStr(year)).Cells(i_row, 3).Value; "-"; Sheets(CStr(year)).Cells(i_row, 4).Value;
                Print #1, "|"; CStr(year);
                Print #1, "|"; CStr(grade);
                Print #1, "|"; "ELA";
                Print #1, "|"; Trim(Sheets(CStr(year)).Cells(i_row, col_grade_start).Value);
                If Sheets(CStr(year)).Cells(i_row, col_grade_start + 1).Value = "100.00%" Then
                    Print #1, "|1"
                Else
                    Print #1, "|"; Trim(Sheets(CStr(year)).Cells(i_row, col_grade_start + 1).Value)
                End If
            End If
            
            If (Not IsEmpty(Sheets(CStr(year)).Cells(i_row, col_grade_start + 2))) _
                And (Sheets(CStr(year)).Cells(i_row, col_grade_start + 2).Value <> "***") Then
                Print #1, Sheets(CStr(year)).Cells(i_row, 1).Value; "-"; Sheets(CStr(year)).Cells(i_row, 2).Value;
                Print #1, "|"; Sheets(CStr(year)).Cells(i_row, 3).Value; "-"; Sheets(CStr(year)).Cells(i_row, 4).Value;
                Print #1, "|"; CStr(year);
                Print #1, "|"; CStr(grade);
                Print #1, "|"; "Math";
                Print #1, "|"; Trim(Sheets(CStr(year)).Cells(i_row, col_grade_start + 2).Value);
                If Sheets(CStr(year)).Cells(i_row, col_grade_start + 3).Value = "100.00%" Then
                    Print #1, "|1"
                Else
                    Print #1, "|"; Trim(Sheets(CStr(year)).Cells(i_row, col_grade_start + 3).Value)
                End If
            End If
            
        Next grade
        i_row = i_row + 1
        
    Loop

Next year

Close #1

End Sub
