get-aduser -filter *  -properties pager| Where-Object {$_.Pager -ne $null} |
     select samaccountname,
            @{N='Pager';E={if($_.pager){$_.pager}else{''}}} |Export-Csv -path \\servidorbk\utilitarios\tabla.csv -NoTypeInformation