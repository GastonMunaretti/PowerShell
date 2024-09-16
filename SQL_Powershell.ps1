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



$tablevalue.Rows[0]
$tablevalue.Rows[0].Apellido
$tablevalue.Rows[0].Legajo
$tablevalue.Rows[2].Usuario
$tablevalue.Rows[2].Nombre









#foreach ($data in $SQLDataset.tables[0]) 
#{ 
#$tablevalue = $data 

#$tablevalue[3]
#$SUM++
#$SUM 
#}  

$tablevalue = $SQLDataset.tables[0]

$tablevalue[3]
$tablevalue[4]

$User = Get-ADUser -Filter {EmployeeiD -Like "00000"} -Properties title,department
$User.title = $tablevalue[3]
$User.department = $tablevalue[4]
Set-ADUser -Instance $User 


$SQLConnection.close()
