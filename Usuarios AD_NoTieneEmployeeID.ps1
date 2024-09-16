

# Consulta usuarios AD con employeeID vacio

ForEach-Object {Get-ADUser -Filter * -Properties Pager,sAMAccountName, employeeID, name, UserAccountControl, title} | where {($_.employeeID -eq $null) -and ($_.UserAccountControl -eq '512')} | select samAccountName ,Pager, employeeID, name, title | Sort-Object name |Format-Table















<#  Reporte

$reportData = ForEach-Object {Get-ADUser -Filter * -Properties Pager,sAMAccountName, employeeID, name, UserAccountControl} | where {$_.employeeID -eq $null} | select samAccountName ,Pager, employeeID, name, UserAccountControl | Sort-Object name

$reportData | Out-GridView -Title ReporteUsuarios

#>




<#$consulta = ForEach-Object {Get-ADUser -Filter * -Properties Pager,sAMAccountName, employeeID, name, UserAccountControl, title} | where {($_.employeeID -eq $null) -and ($_.UserAccountControl -eq '512')} | select samAccountName ,Pager, employeeID, name, title 


ForEach($c in $consulta){

$usuario = $c.samAccountName
$legajo = $c.Pager

 Set-ADUser -Identity $usuario -Replace @{employeeID = $legajo}

}
#>

<#

#----------------------------------------------------
# Buscamos los Usuarios Contenidos en la Unidad Organizativa y los pasamos a una Variable
#----------------------------------------------------
 
$Usuarios = Get-ADUser -Filter * -SearchBase "OU=Publicidad,DC=abiurrunc,DC=es" -Propertie sAMAccountName, TelephoneNumber, Mobile
 
#------------------------------------------------------------------------------
# Para cada Usuario Contenido en la VAriable ejecutaremos el siguiente grupo de comandos contenido entre los Corchetes
#------------------------------------------------------------------------------
 
foreach ($Usuario in $Usuarios) 
{  
    #----------------------------------------------------
    # Almacenamos la cuenta de Usuario en una Variable.
    #----------------------------------------------------
   
    $CuentaDeUsuario    = $Usuario.sAMAccountName
 
    #------------------------------------------------------------------------------
    # Le damos formato al número según nos han pedido ("915 555 555;ext=")
    # Extraemos los 3 últimos números del Mobile ($Usuario.Mobile.Substring(6)
    # Lo Unimos y lo almacenamos en una Variable  
    #------------------------------------------------------------------------------
   
    $NumerodeTelefono   = "915 555 777;ext=" + $Usuario.Mobile.Substring(6)
   
    #------------------------------------------------------------------------------
    # Para ver como ocurre el Proceso lo presentamos en Pantalla conforme se ejecuta.
    #------------------------------------------------------------------------------
 
    Write-Host "Usuario: $CuentaDeUsuario" " $NumerodeTelefono" -ForegroundColor White
 
    #------------------------------------------------------------------------------
    # Añadimos a la cuenta del Usuario El número de teléfono con su extensión
    #------------------------------------------------------------------------------
    Set-ADUser -Identity $CuentaDeUsuario -Replace @{TelephoneNumber=$NumerodeTelefono;employeeID='4555'}
} 


#>