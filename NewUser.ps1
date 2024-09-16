
Import-Module ActiveDirectory
#Importa la data a la variable
$nameU=Import-Csv c:\newuserad.csv
#Iniciamos a trabajar con la información
foreach ($i in $nameU)
{
#Verificamos si existe el usuario
$move=$i.usuario
$searchU=Get-ADUser -Filter {Name -like $move}
if (-not $searchU) {
#Si no existe entonces lo ingresamos
$path="OU=" + $i.ou + ",DC=wolverine,DC=com"
New-ADUser $i.usuario -DisplayName ($i.nombre +" " + $i.apellido) `
-SamAccountName ($i.nombre+"."+$i.apellido) -UserPrincipalName ($i.nombre+"."+$i.apellido+"@wolverine.com") `
-GivenName $i.nombre -Surname $i.apellido -Department $i.department -Title $i.title -Company $i.company `
-AccountPassword (ConvertTo-SecureString $i.password -AsPlainText -force) -ChangePasswordAtLogon $true `
-Path $path -Enabled $true
} else {
#Si existe no lo crea y guarda en nombre del usuario en archivo de texto
$file="c:\LogCreateUser.txt"
"Error: El siguiente usuario ya existe en tu AD - " + $i.usuario | out-file $file -Append
}
}