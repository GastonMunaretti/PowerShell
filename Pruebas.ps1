#Get-ADUser -Identity sapopp -Properties  Enabled | Ft Name, SamAccountName , Enabled ,userAccountControl


#Get-ADUser -Filter {Enabled -eq "False"} -Properties  SamAccountName,userAccountControl,Enabled  | Select-Object SamAccountName,userAccountControl,Enabled | Format-Table


#Get-ADUser -Filter {Enabled -eq "False"} | Ft Name, UserPrincipalName, Enabled ,userAccountControl


$SA = "mbuni"


#Get-ADUser -Filter {SamAccountName -eq $SA  } -Properties  SamAccountName,Name,Surname,GivenName,EmployeeID,userAccountControl,Enabled  | Select-Object SamAccountName,Name,Surname,GivenName,EmployeeID, userAccountControl, Enabled | Format-Table


$User = Get-ADUser -Filter {SamAccountName -eq $SA}  -Properties Enabled, userAccountControl


if ($User -eq $null)
{
    Write-Host "Vacio"


}
Else
{

    Write-Host "Datos"
}
               
                
# $User.l = $location.ToString()
#Write-Host $User.Enabled
#Write-Host $User.userAccountControl

#Disable-ADAccount -Identity $SA

#Enable-ADAccount  -Identity $SA
                   
# Actualizacion de datos
#Set-ADUser -Instance $User 


#Get-ADUser -Filter {SamAccountName -eq $SA  } -Properties  SamAccountName,Name,Surname,GivenName,EmployeeID,userAccountControl  | Select-Object SamAccountName,Name,Surname,GivenName,EmployeeID, userAccountControl | Format-Table