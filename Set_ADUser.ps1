Get-ADUser -Filter {EmployeeiD -Like "00000"} | Format-List


$User = Get-ADUser -Filter {EmployeeiD -Like "00000"} -Properties title,department
$User.title = "Gerente"
$User.department = "Legales"
Set-ADUser -Instance $User 
