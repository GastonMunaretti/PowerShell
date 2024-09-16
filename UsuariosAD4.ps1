


$datos = get-aduser -filter *  -properties pager,userPrincipalName | Where-Object {$_.Pager -ne $null} #| select userPrincipalName, Pager



            
$bar = foreach ($data in $datos) 
{ 

Write-host($data.userPrincipalName.Split("@")[0] , $data.pager) -ForegroundColor Cyan  
   

  
} 

$bar|select userPrincipalName, Pager  | Export-Csv -path \\servidorbk\Importacion_Automatica\Sistemas\Us_AD.csv -NoTypeInformation -Force



#@{N='Pager';E={if($_.pager){$_.pager}else{''}}} #|Export-Csv -path \\servidorbk\Importacion_Automatica\Sistemas\UsuariosAD.csv -NoTypeInformation

#get-aduser -filter *  -properties pager,userPrincipalName | Where-Object {$_.Pager -ne $null} | select Pager, userPrincipalName | Export-Csv -path \\servidorbk\Importacion_Automatica\Sistemas\Us_AD.csv -NoTypeInformation -Force

