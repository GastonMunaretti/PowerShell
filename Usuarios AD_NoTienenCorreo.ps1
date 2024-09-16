#Get-ADUser -Properties mail | where {$_.mail -ne $null} | Select SAMAccountName, mail #| Export-CSV -Path $userPath -NoTypeInformation


# USUARIOE EN AD SIN CUENTA DE CORREO ELECTRONICO 
ForEach-Object {Get-ADUser -Filter * -Properties Pager,samAccountName, mail } | where {$_.mail -eq $null} | select samAccountName ,mail