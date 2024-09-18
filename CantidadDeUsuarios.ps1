#############################################################################
# PowerShell para extraer información de Active Directory.		    #
# Se crea directorio C:\FSO y los outputs se guardan en outcommand.txt	    #
# Informacion que extrae:						    #
#	>Numero total de usuarios					    #
#	>Numero total de maquinas					    #
#	>Numero total de servidores					    #
#	>Numero total de administradores del dominio			    #
#	>Lista de GPO's activas en el Dominio				    #
#############################################################################
 
import-module ActiveDirectory #Se importa el modulo de Active Directory
 
#Se comprueba si existe carpeta temporal donde guardar el output. De lo contrario, se crea.
if (!(Test-Path -path C:\FSO))
{
Write-host "------ Creando directorio temporal en C:\FSO ------"
New-Item -ItemType directory -Path C:\FSO
}
else
{
	Write-Host "------ El dicrectorio C:\FSO ya Existe ------"
	Write-Host "------ Comprobando contenido"
	if ((Test-Path c:\FSO\outcommand.txt) -eq $true)
	{
	Remove-Item c:\FSO\*.txt
	Write-Host ">>>>> Fichero temporal eliminado"
	}
}
	write-host ""
 
"************ Escribiendo informacion de usuatios" >> c:\FSO\outcommand.txt
$total_users = Get-ADUser -Filter * -SearchBase "DC=intercargo,DC=com,DC=ar" | measure | ForEach-Object {$_.Count}	#numero total de usuarios
$total_computers = Get-ADComputer -Filter * -SearchBase "DC=intercargo,DC=com,DC=ar" | measure | ForEach-Object {$_.Count}	#numero total de maquinas
$total_servers = Get-ADComputer -Filter {operatingsystem -like "*server*"} | measure | ForEach-Object {$_.Count}	#numero total de servidores
$total_admin = Get-ADGroupMember -Identity "Admins. del dominio" | measure | ForEach-Object {$_.Count}	#numero total de administradores del dominio
 
"Usuarios totales en AD : " + $total_users >> c:\FSO\outcommand.txt
"Computers totales en AD : " + $total_computers >> c:\FSO\outcommand.txt
"Servers totales en AD : " + $total_servers >> c:\FSO\outcommand.txt
"Admins. del Dominio en AD : " + $total_admin >> c:\FSO\outcommand.txt
 
" " >> c:\FSO\outcommand.txt
" " >> c:\FSO\outcommand.txt
#'Lista de GPOs
$domain = "intercargo.com.ar" #Dominio del que extraer las políticas
 
 "Listando politicas de " + $domain >> c:\FSO\outcommand.txt
 $gpm=New-Object -ComObject gpmgmt.gpm
 $constants = $gpm.GetConstants()
 $gpmDomain = $gpm.GetDomain($domain,$null,$constants.useanydc)
 $gpmSearchCriteria = $gpm.CreateSearchCriteria()
 $gpo=$gpmdomain.SearchGPOs($gpmSearchCriteria)
 if($verbose)
  { 
   write-host $gpo
  }
 ELSE
  {
   foreach($ogpo in $gpo)
    {
     $hash += @{ $ogpo.ID = $ogpo.DisplayName } >> c:\FSO\outcommand.txt
    }
     format-table -inputobject $hash -autosize >> c:\FSO\outcommand.txt
  } 
 exit
 
write-host ">>>>>> Finalizado"