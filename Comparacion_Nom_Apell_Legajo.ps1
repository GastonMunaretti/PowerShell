$Global:SCCMSQLSERVER = "ezesql.intercargo.com.ar" 
$Global:DBNAME = "ModeloDeNegocio" 
Try 
{ 
$SQLConnection = New-Object System.Data.SQLClient.SQLConnection 
$SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;" 
$SQLConnection.Open() 
[System.Windows.Forms.MessageBox]::Show("connect SQL Server:")
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
             B.CodigoSede,
             C.DescripcionGerencia,
             D.DescripcionArea,
             E.DescripcionDepartamento,
             F.DescripcionSector,
             G.DescripcionSubsector,
             H.NombrePuesto,
             I.DescripcionUnidadOrganigrama,
             A.AntiguedadReconocida

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
              A.EsContratado = 0" 
$SQLCommand.Connection = $SQLConnection 
 
$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
$SqlAdapter.SelectCommand = $SQLCommand                  
$SQLDataset = New-Object System.Data.DataSet 
$SqlAdapter.fill($SQLDataset) | out-null 
$SUM = 0 
$tablevalue = @() 



foreach ($data in $SQLDataset.tables[0]) 
{ 


    #$NOM_AP= $data.Nombre +' '+$data.Apellido
    #$NOM_AP=  $data.Apellido
    $NOM = "*" + $data.Nombre + "*"
    $APE = "*" + $data.Apellido + "*"

    
    
    $User = Get-ADUser -Filter {surname -like $APE -and name -like  $NOM} -Properties EmployeeID, Pager, DisplayName

    if($User.length -eq 0)
    {
                  #Write-Output $nombre
              Write-Output $data.ApellidoyNombre
              Write-Output $data.Legajo
              Write-Output $data.Usuario
              "no hay registros en AD"
             
              
    }

   #if ( $User.EmployeeID -eq $NULL )
   #{
   # $User.DisplayName
   # $User.EmployeeID
   # $User.Pager
   #  $data.legajo
   #}
   #foreach( $use in $User )
   #{
   #$nombre  = $use.DisplayName
   #$empid = $use.EmployeeID
   #$pag = $use.Pager
   #   if ( $nombre.Length -gt 0)
   #   { 
   #        if ($empid -eq $NULL)
   #        {
   #           Write-Output $nombre
   #           Write-Output $data.Legajo
              
              

    #      }  
    #  }
  #}
}