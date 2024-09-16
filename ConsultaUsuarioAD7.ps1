Import-Module Activedirectory
Get-ADUser -Filter * -Properties DisplayName,memberof | % {
$Name = $_.DisplayName
$_.memberof | Get-ADGroup | Select @{N=”User”;E={$Name}},Name
} | Export-Csv -path C:\USUARIOSYGRUPOS.csv