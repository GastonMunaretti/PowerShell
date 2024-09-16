

# EL SIGUIENTE SCRIPT REALIZA LA CONSULTA DE USUARIOS EN LA BASE DE DATOS, LUEGO CREA LOS USUARIOS EN AD
# EN EL CASO DE QUE NO EXISTA. 


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

$Global:SCCMSQLSERVER = "EZE.intercargo.com.ar" 
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
$SQLCommand.CommandText = "Select        A.Usuario,
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
             B.Sede

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
             
              
                    
Where         A.Activo = 1 And
              A.EsContratado = 0 And
              --A.Apellido = 'quiroga' --AND
              A.Usuario IS NULL
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

$fileCreateUser="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogCreateUser.txt"
$fileCreateUserError="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogCreateUserError.txt"




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

    # SE VERIFICA SI EXISTE EL LEGAJO EN AD
    if ($(Get-AdUser -Filter {employeeID -eq $Legajo })) 
    {
           Write-Host "El Usuario EXISTE en Active Directory! ********" $data.Legajo.ToString() $data.ApellidoyNombre.Tostring() -ForegroundColor:Yellow

           "El Usuario EXISTE en Active Directory!.legajo repetido  " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring() +" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")| out-file $fileCreateUserError -Append
    
    
         
    } 
    else 
    {
                 
            
            DO
            {
                If ($(Get-ADUser -Filter {SamAccountName -eq $logonname})) 
                {
                    
                        Write-Host "==================================================="
                        Write-Host "WARNING: Logon " $logonname.toUpper() "Ya existe!!" -ForegroundColor:Yellow
                    
                        if($i -lt $fname.Length)
                        {
                            $i++
                            $logonname = $fname.substring(0,$i) + $lname
                            
                            Write-Host
                            Write-Host "Cambiando Logon a " $logonname.toUpper() -ForegroundColor:Yellow
                            Write-Host "==================================================="
                            Write-Host
                            
                            $taken = $true
                            sleep 5
                        }
                        else
                        {
                            Write-Host "========================================================================================================"
                            Write-Host "= ERROR EN EL ALTA DE USUARIO.No se puede generar un usuario de manera univoca.Ver registro de errores ="
                            Write-Host "========================================================================================================"
                            #No se puede generar un usuario de manera univoca
                            $NoExistLogon = $true
                            $taken = $false
                            
                     
                        }

                } 
                else 
                {
                    
                    $taken = $false
                }

            } Until ($taken -eq $false)
            
            if($NoExistLogon -eq $true)
            {
               "El Usuario EXISTE en Active Directory!.No se puede definir logon " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring() +" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileCreateUserError -Append
            
            }
            else
            {
            
            
            
            
            

            $logonname = $logonname.toLower()
            
            
            
            
            Write-Host "======================================="
            Write-Host "Nombre:         $firstname"
            Write-Host "Apellido:       $lastname"
            Write-Host "Legajo:         $Legajo"
            Write-Host "Display name:   $fullname"
            Write-Host "Logon name:     $logonname"
            Write-Host "OU:             $OU"
            Write-Host "Sede:           $location "
            Write-Host "Puesto:         $puesto "
            Write-Host "Departamento:   $departamento "
            Write-Host "Domain:         $domain"
            Write-Host "======================================="
            Write-Host "======================================="
            
            
            #"El Usuario no EXISTIA! Se creó en AD " + $logonname.ToString() +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring()+" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileCreateUser -Append
            
                    
                    
                    
                    
            $newUserParams = @{
                            SamAccountName = $logonname
                            UserPrincipalName = $logonname + “@intercargo.com.ar” 
                            Name        = $fullname
                            DisplayName = $fullname
                            Path        = $OU
                            Enabled     = $true
                            GivenName   = $firstname
                            Department  = $departamento
                            Surname     = $lastname
                            EmployeeID  = $Legajo
                            AccountPassword = $Pass
                            Company = 'Intercargo S.A.C.'
                            Title = $puesto
                            
                            }

            Try{
            
                   New-AdUser @newUserParams
                                   
                   #set-aduser $logonname.ToString()  -Pages $Legajo.ToString()

                   "El Usuario no EXISTIA! Se creó en AD " + $logonname.ToString() +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring()+" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileCreateUser -Append
                   $Mensaje = "El Usuario no EXISTIA! Se creó en AD " + $logonname.ToString() +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring()+" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")
                   
                   Write-Host "======================================="
                   Write-Host "= El Usuario se dio de alta!          ="
                   Write-Host "======================================="
                   Write-Host
                   Write-Host
		   
                   

                   # Se actualizan los datos del uasuario creado, en los atributos auxiliares
                   $User = Get-ADUser -Filter {EmployeeiD -Like $Legajo} -Properties title,department
                   $User.Pager = $Legajo.ToString()
                   $User.l = $location.ToString()
                   #$User.thumbnailPhoto = $Foto

                   Set-ADUser -Instance $User 




                   $EmailPropio = "noreply@intercargo.com.ar";
                   $EmailDestino = "tecnologia@intercargo.com.ar";
                   $Asunto = "Alta de usuario en Active Directory"
                   $ServidorSMTP = "correo.intercargo.com.ar"
                   $ClienteSMTP = New-Object Net.Mail.SmtpClient($ServidorSMTP, 25)
                   $ClienteSMTP.EnableSsl = $true
                   $ClienteSMTP.Credentials = New-Object System.Net.NetworkCredential("noreply@intercargo.com.ar", "peperoni");
                   $ClienteSMTP.Send($EmailPropio, $EmailDestino, $Asunto, $Mensaje)

            }
            Catch
            {
                 $ErrorMessage = $_.Exception.Message
                 
                 "ERROR EN EL ALTA DE USUARIO  " + $ErrorMessage +" " + $data.Legajo.ToString() +" "+ $data.ApellidoyNombre.Tostring() +" " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")| out-file $fileCreateUserError -Append
                 
                 Write-Host "========================================================"
                 Write-Host "= ERROR EN EL ALTA DE USUARIO. Ver registro de errores ="
                 Write-Host "========================================================"
                 Write-Host
                 Write-Host

            
            }
            
            
            
            
            }


    
    }

}