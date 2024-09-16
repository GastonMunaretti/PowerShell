Get-ADUser -Filter * -Property DisplayName | Select-Object
Name | Export-CSV
c:\ADcomputerslist.csv