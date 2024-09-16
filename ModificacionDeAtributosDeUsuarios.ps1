

# EL SIGUIENTE SCRIPT REALIZA LA CONSULTA DE USUARIO EN LA BASE DE DATOS, LUEGO MODIFICA LOS ATRIBUTOS USUARIOS EN AD


<##########################################################################################################>





############################################################################################################
#                                                                                                          #
#                            IMPORTAR MODULOS DE AD                                                        #  
#                                                                                                          #
############################################################################################################


Import-Module ActiveDirectory


############################################################################################################
#                                                                                                          #
#                            CONEXION CON LA BASE DE DATOS                                                 #  
#                                                                                                          #
############################################################################################################

$Global:SCCMSQLSERVER = "EZESQL.intercargo.com.ar" 
$Global:DBNAME = "ModeloDeNegocio" 
Try 
{ 
$SQLConnection = New-Object System.Data.SQLClient.SQLConnection 
$SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;" 
$SQLConnection.Open() 
#[System.Windows.Forms.MessageBox]::Show("connect SQL Server:")
} 
catch 
{ 
    [System.Windows.Forms.MessageBox]::Show("Failed to connect SQL Server:")  
} 

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand 
$SQLCommand.CommandText = "Select       A.Usuario,
             A.Legajo,
             A.ApellidoyNombre,
             A.Apellido,
             A.Nombre,
             A.Direccion,
             A.Piso,
             A.Depto,
             A.Ciudad,
             A.Provincia,
             A.CodigoPostal,
             A.Telefono,
             A.Genero,
             A.TipoDocumento,
             A.NroDocumento,
             A.CUIL,
             A.Nacionalidad,
             A.Foto,
             B.CodigoSede,
             C.DescripcionGerencia,
             D.DescripcionArea,
             E.DescripcionDepartamento,
             F.DescripcionSector,
             G.DescripcionSubsector,
             H.NombrePuesto,
             I.DescripcionUnidadOrganigrama,
             A.AntiguedadReconocida,
             B.Sede,
             T.CS_LINEA,
			 COUNT(A.Usuario) AS 'CANT_CAT'

From          Mod_Usuarios A
             Join MOD_Sedes B On
                    A.IdSedeActual = B.IdSede
             Join MOD_Gerencias C On
                    A.IdGerenciaActual = C.IdGerencia
             Join MOD_Areas D On
                    A.IdAreaActual = D.IdArea
             Join MOD_Departamentos E On
                    A.IdDepartamentoActual = E.IdDepartamento
             Join MOD_Sectores F On
                    A.IdSectorActual = F.IdSector
             Join MOD_Subsectores G On
                    A.IdSubsectorActual = G.IdSubsector
             Join MOD_Puestos H On
                    A.IdPuestoActual = H.IdPuesto
             Join MOD_UnidadOrganigrama I On
                    A.IdUnidadOrganigramaActual = I.IdUnidadOrganigrama
             Join [OPERACIONES].[dbo].[V_TELEFONOS] T On
					A.Legajo = T.EMP_LEGAJO
 
 

Where        
			  T.MC_MARCA = 'Caterpilar'	AND
			  A.Activo = 1 AND
			  T.CS_LINEA IS NOT NULL
			  
              
              

GROUP BY A.Usuario,
             A.Legajo,
             A.ApellidoyNombre,
             A.Apellido,
             A.Nombre,
             A.Direccion,
             A.Piso,
             A.Depto,
             A.Ciudad,
             A.Provincia,
             A.CodigoPostal,
             A.Telefono,
             A.Genero,
             A.TipoDocumento,
             A.NroDocumento,
             A.CUIL,
             A.Nacionalidad,
             A.Foto,
             B.CodigoSede,
             C.DescripcionGerencia,
             D.DescripcionArea,
             E.DescripcionDepartamento,
             F.DescripcionSector,
             G.DescripcionSubsector,
             H.NombrePuesto,
             I.DescripcionUnidadOrganigrama,
             A.AntiguedadReconocida,
             B.Sede,
             T.CS_LINEA

HAVING (COUNT(A.Usuario)<2)

             " 



$SQLCommand.Connection = $SQLConnection 
 
$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
$SqlAdapter.SelectCommand = $SQLCommand                  
$SQLDataset = New-Object System.Data.DataSet 
$SqlAdapter.fill($SQLDataset) | out-null 


############################################################################################################
#                                                                                                          #
#                     RECORRE LOS LA CONSULTA EN DB Y BUSCA LOS USAUARIOS EN AD                            #  
#                                                                                                          #
############################################################################################################
cls

# DECLARACION DE ARCHIVOS DE SALIDA

$fileCreateUser="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogModifyUser.txt"
$fileCreateUserError="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogModifyUserError.txt"




foreach ($data in $SQLDataset.tables[0]) 
{ 
    

    # PREPARACION DE DATOS
    
    $firstname = $data.Nombre
    $firstname = [Regex]::Replace($firstname.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})
    
    $lastname = $data.Apellido
    $lastname = [Regex]::Replace($lastname.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})
    
    
    $fullname = "$firstname $lastname"

    $Legajo = $data.Legajo

    $location = $data.Sede
    
    $puesto = $data.NombrePuesto
    $puesto = [Regex]::Replace($puesto.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})

    $departamento = $data.DescripcionArea

    $OU = "OU=Usuarios,OU=Restringidos,DC=intercargo,DC=com,DC=ar"

    #$OU = "OU=Usuarios,OU=Aeroparque,DC=intercargo,DC=com,DC=ar"
    
    $domain = 'intercargo.com.ar'

    $fname = $firstname.Replace(' ','')
    $fname = $fname.Replace('ñ','n')

    $lname = $lastname.Replace(' ','')
    $lname = $lname.Replace('ñ','n')

    $Foto = $data.Foto

    $Pass = "12345678" | ConvertTo-SecureString -AsPlainText -Force

    $NoExistLogon = $false

    $i = 1
    $logonname = $fname.substring(0,$i) + $lname

    $Celu = $data.CS_LINEA

    # SE VERIFICA SI EXISTE EL LEGAJO EN AD
    if ($(Get-AdUser -Filter {employeeID -eq $Legajo })) 
    {
           Write-Host "El Usuario EXISTE en Active Directory! ********"$data.CS_LINEA.ToString() $data.Legajo.ToString() $data.ApellidoyNombre.Tostring()  -ForegroundColor:Yellow
                     

           
           
           Try{
            
                                 
                   # Se actualizan los datos del uasuario creado, en los atributos auxiliares
                  
                   $User = Get-ADUser -Filter {EmployeeiD -Like $Legajo} -Properties title,department
                   $User.mobile = $Celu.ToString()
                   $User.Pager = $Legajo.ToString()
                   $User.l = $location.ToString()
                   
                  Set-ADUser -Instance $User 

                                     
                   "Se modificó el atributo mobil "+ " " + $Celu.ToString() + $logonname.ToString() + " " + $data.Legajo.ToString() + " " + $data.ApellidoyNombre.Tostring()+ " " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileCreateUser -Append
                   
                   Write-Host "======================================="
                   Write-Host "= Se modificó el atributo mobile      ="
                   Write-Host "======================================="
                   Write-Host
                   Write-Host

           }
           Catch
           {
                $ErrorMessage = $_.Exception.Message
                 
                "ERROR AL INTENTAR MODIFICAR EL ATRIBUTO " + $ErrorMessage +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring() +" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")| out-file $fileCreateUserError -Append
                 
                Write-Host "========================================================"
                Write-Host "= ERROR NO SE PUDFO MODIFICAR EL ATRIBUTO mobil ="
                Write-Host "========================================================"
                Write-Host
                Write-Host

            
           }
            
            
    
         
    } 
    else 
    {
                 
           
            
            
    }


    
   

}