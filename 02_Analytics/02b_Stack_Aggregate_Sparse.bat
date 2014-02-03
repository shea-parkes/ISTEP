SETLOCAL
rem OBJECTIVE: Stack the components we want predicted
rem
rem DEVELOPER NOTES:
rem   Needs to be stacked in exactly the same order as the data.frames are stacked in R

cd /D "%~1"
type Source_Sparse.txt > Aggregate_Sparse.txt
type District_Sparse.txt >> Aggregate_Sparse.txt
type School_Sparse.txt >> Aggregate_Sparse.txt
type Year_Sparse.txt >> Aggregate_Sparse.txt
type Grade_Sparse.txt >> Aggregate_Sparse.txt
