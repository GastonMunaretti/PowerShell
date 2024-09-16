# Se obtiene la lista de usuarios que estan en "Usuarios del dominio" 
$Usuarios = Get-ADGroupMember “Usuarios del dominio” -recursive | Select-Object samaccountname

# Se recorre la lista y cada objeto se agrega al grupo "NavegacionRestringido"
$Usuarios | ForEach-Object {Add-ADGroupMember -Identity "NavegacionRestringido" -Members $_}

