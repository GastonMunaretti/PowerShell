<##########################################################################################################>
# Actualizacion de firmas de uasuarios de modificaciones hechas el dia anterior a la ejecucion del script




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

$Global:SCCMSQLSERVER = "EZ.intercargo.com.ar" 
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
$SQLCommand.CommandText = "Select A.Idusuario,
             B.Legajo,
             B.ApellidoyNombre,
             C.Sede,
             D.NombrePuesto Puesto,
             E.DescripcionGerencia Gerencia,
             F.DescripcionArea DescripcionArea,
			 Case When F.idArea = -2 Then '' Else F.DescripcionArea End Area,
             
             G.DescripcionDepartamento Departamento,
             H.DescripcionSector Sector,
             I.DescripcionSubSector SubSector

From   (      Select idUsuario
                    From   MOD_HistoricoUsuarioSedes
                    Where  idUsuario = 585 And
                                  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    Union all
                    Select idUsuario
                    From   MOD_HistoricoUsuarioPuestos
                    Where  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    Union all
                    Select idUsuario
                    From   MOD_HistoricoUsuarioGerencias
                    Where  idUsuario = 585 And
                                  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    Union  all
                    Select idUsuario
                    From   MOD_HistoricoUsuarioAreas
                    Where  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    Union  all
                    Select IdUsuario
                    From   MOD_HistoricoUsuarioDepartamentos
                    Where  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    Union  all
                    Select IdUsuario
                    From   MOD_HistoricoUsuarioSectores
                    Where  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null
                    union all
                    Select IdUsuario
                    From   MOD_HistoricoUsuarioSubSectores
                    Where  FechaInicio Between dbo.trunc(GETDATE()) - 1 And
                                  GETDATE() And
                                  FechaFin Is Null) A 
             Join MOD_Usuarios B On
                    A.idUsuario = B.idUsuario
             Join MOD_Sedes C On
                    B.idSedeActual = C.idSede
             Join MOD_Puestos D On
                    B.idPuestoActual = D.idPuesto
             Join MOD_Gerencias E On
                    B.IdGerenciaActual = E.IdGerencia
             Join MOD_Areas F On
                    B.IdAreaActual = F.idArea
             Join MOD_Departamentos G On
                    B.idDepartamentoActual = G.idDepartamento
             Join MOD_Sectores H On
                    B.IdSectorActual = H.IdSector
             Join MOD_SubSectores I On
                    B.IdSubSectorActual = I.idSubSector

Group By A.Idusuario,
             B.Legajo,
             B.ApellidoyNombre,
             C.Sede,
             D.NombrePuesto,
             E.DescripcionGerencia,
             F.DescripcionArea,
             F.idArea,
             G.DescripcionDepartamento,
             H.DescripcionSector,
             I.DescripcionSubSector

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

$fileCreateUser="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogModifUserCambioDePuesto.txt"
$fileCreateUserError="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogModifUserErrorCambioDePuesto.txt"




foreach ($data in $SQLDataset.tables[0]) 
{ 
    

    # PREPARACION DE DATOS
    
    $Legajo = $data.Legajo
    $ApellyNom = $data.ApellidoyNombre

    $location = $data.Sede
        
    $puesto = $data.Puesto
    $puesto = [Regex]::Replace($puesto.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})
    
    $area = $data.Area
    $area = [Regex]::Replace($area.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})
    
    $gerencia = $data.Gerencia
    $gerencia = [Regex]::Replace($gerencia.ToLower(), '\b(\w)', {param($m) $m.Value.ToUpper()})
    
     
   
      
    
    # SE VERIFICA SI EXISTE EL LEGAJO EN AD
    if ($(Get-AdUser -Filter {employeeID -eq $Legajo })) 
    {
        
        
        
          Write-Host "======================================="
          Write-Host "Legajo:             $Legajo"
          Write-Host "Apellido y Nombre:  $ApellyNom "
          Write-Host "Sede:               $location "
          Write-Host "Puesto:             $puesto "
          Write-Host "Area:               $Area "
          Write-Host "Gerencia:           $Gerencia "
            
          Write-Host "======================================="
          
          
          Try{
            
                   # Se actualizan los datos del uasuario creado, en los atributos auxiliares
                   $User = Get-ADUser -Filter {EmployeeiD -eq $Legajo}  -Properties l,company,department, title
               
                
                   $User.l = $location.ToString()

                   $User.Company = $gerencia.ToString()
               
                   $User.department = $area.ToString()

                   $User.title = $puesto.ToString()
                   

                   # Actualizacion de datos
                   Set-ADUser -Instance $User 


                   "Los datos del usuario se modoficaron con exito! " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring()+" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileCreateUser -Append
                   
                   Write-Host "========================================================="
                   Write-Host "= Los datos del usuario se modificaron correctamente!   ="
                   Write-Host "========================================================="
                   Write-Host "======================================="
                   Write-Host
                   Write-Host
		   




            }
            Catch
            {
                 $ErrorMessage = $_.Exception.Message
                 
                 "ERROR EN LA MODIFICACION DE USUARIO  " + $ErrorMessage +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring() +" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")| out-file $fileCreateUserError -Append
                 
                 Write-Host "================================================================"
                 Write-Host "= ERROR EN LA MODOFICACION DE USUARIO. Ver registro de errores ="
                 Write-Host "================================================================"
                 Write-Host
                 Write-Host

            
            }
            
    
         
    } 
    else 
    {
                
         
    }




}