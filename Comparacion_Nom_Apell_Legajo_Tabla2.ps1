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
$Contador = 0


foreach ($data in $SQLDataset.tables[0]) 
{ 


    #$NOM_AP= $data.Nombre +' '+$data.Apellido
    #$NOM_AP=  $data.Apellido
    #$NOM = "*" + $data.Nombre + "*"
    #$APE = "*" + $data.Apellido + "*"

    $NOM = $data.Nombre
    $APE = $data.Apellido

    #Write-Host $NOM
    #Write-Host $APE
    
    $User = 0
   

   ForEach-Object {Get-ADUser -Filter * -Properties Pager,samAccountName } | where {($_.surname -eq $APE) -and ($_.name -eq  $NOM)} | select samAccountName
   
   
   
   #Get-ADUser -Filter {(surname -eq $APE) -and (name -eq  $NOM) } | select EmployeeID, Pager, DisplayName | Format-Table

    #($User.length -eq 0) -and 
    
    
    #if($data.Usuario.Length -eq 1) 
    #{
                  #Write-Output $nombre
              #Write-Output $data.ApellidoyNombre
              #Write-Output $data.Legajo
              #Write-Output $data.Usuario
              #"no hay registros en AD"
      
      
     #$Contador++
             
        #Write-Host ($Contador, $data.Legajo,$data.Usuario, $data.ApellidoyNombre ,    "no hay registros en AD") -Separator "`t" 
        #Get-ADUser -Filter {(surname -eq $APE) -and (name -eq  $NOM) } | Format-Table EmployeeID, Pager, DisplayName
    #}

  
}