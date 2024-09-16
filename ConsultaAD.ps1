Import-Module ActiveDirectory
Get-ADGroup -Filter { groupCategory -eq "security" } | Select name
	
Get-ADUser -Enabled -SizeLimit 0


############################################################################
#                       Numero de cuentas en AD                            #
############################################################################  


(Get-ADUser -filter *).count

############################################################################

(Get-AdUser -filter * |Where {$_.enabled -eq "True"}).count