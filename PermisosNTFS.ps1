


# Consulta los permisos en la carpeta NTFS indicada y los devuelve en un archivo
Get-Childitem -path "C:\proyectos" -recurse | Where-Object {$_.PSIsContainer} | Get-ACL| Select-Object Path -ExpandProperty Access | Export-CSV "C:\proyectos\ntfs_permisos_folder.csv" -NoTypeInformation | Out-GridView

# Consulta los permisos en la carpeta NTFS indicada y los devuelve en una ventana
Get-Childitem -path "C:\proyectos" -recurse | Where-Object {$_.PSIsContainer} | Get-ACL| Select-Object Path -ExpandProperty Access | Out-GridView