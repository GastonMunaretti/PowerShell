<##########################################################################################################>
# Baja de usuarios en Active Directory




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
$SQLCommand.CommandText = "use [ModeloDeNegocio]




Select       A.Usuario,
             A.Legajo,
			 A.FechaBaja
             
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
                    
Where (A.FechaBaja IS NOT NULL)And
	  (A.FechaBaja Between dbo.trunc(GETDATE())- 1  And 	dbo.trunc(GETDATE()))
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

$fileBajaUser="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogBajaUser.txt"
$fileBajaUserError="\\SERVIDORBK\Importacion_Automatica\AltaDeUsuario\LogBajaUserError.txt"




foreach ($data in $SQLDataset.tables[0]) 
{ 
    
          
        $Usuario =  $data.Usuario
        $Legajo = $data.Legajo
        $FechaBaja = ($data.FechaBaja).Date.ToString( "dd-MM-yyyy")

        # Buscar usuario en AD
        $User = Get-ADUser -Filter {SamAccountName -eq $Usuario}  -Properties Enabled, userAccountControl

        
        if ($User -ne $null){

            # Baja de usuario
            Disable-ADAccount -Identity $User

            # Carga el archivo de log y genera el mensaje para enviar por mail
            "La cuenta de usuario fue deshabilitada en Active Directory " + $Usuario.ToString() +" " + $Legajo.ToString() + " " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileBajaUser -Append
            $Mensaje = "La cuenta de usuario fue deshabilitada en Active Directory: " + $Usuario.ToString() +" " + $Legajo.ToString() + " " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm")
            
            Write-Host "======================================="
            write-Host "Usuario:        $Usuario"
            Write-Host "Legajo:         $Legajo"
            Write-Host "Fecha de baja:  $FechaBaja"
            Write-Host "======================================="
            Write-Host "======================================="
            Write-Host ""    
        }
        
        else{
            
            # Si no encuentra el usuario en AD lo reporta como un error
            "ERROR! No se encuentra la cuenta de usuario en Active Directory: " + $Usuario.ToString() +" " + $Legajo.ToString() + " " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileBajaUserError -Append
            $Mensaje = "ERROR! No se encuentra la cuenta de usuario en Active Directory: " + $Usuario.ToString() +" " + $Legajo.ToString() + " " + (Get-Date -Format "dddd dd/MM/yyyy HH:mm") | out-file $fileBajaUserError -Append


        }
        
        # Envia mail informando de la baja
        $EmailPropio = "noreply@intercargo.com.ar";
        $EmailDestino = "tecnologia@intercargo.com.ar";
        $Asunto = "Baja de usuario en Active Directory"
        $ServidorSMTP = "correo.intercargo.com.ar"
        $ClienteSMTP = New-Object Net.Mail.SmtpClient($ServidorSMTP, 25)
        $ClienteSMTP.EnableSsl = $true
        $ClienteSMTP.Credentials = New-Object System.Net.NetworkCredential("noreply@intercargo.com.ar", "peperoni");
        $ClienteSMTP.Send($EmailPropio, $EmailDestino, $Asunto, $Mensaje)

}