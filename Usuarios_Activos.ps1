
#Usurios activos

Get-ADUser -Filter {Name = DisplayName} | Ft Name, UserPrincipalName, Enabled