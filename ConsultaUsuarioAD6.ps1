Import-Module ActiveDirectory
Get-ADGroup -Filter { groupCategory -eq ‘security’ } | Select name | Export-CSV c:\GRUPOS.csv