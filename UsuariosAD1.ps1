get-aduser -filter * -properties pager|
     select samaccountname, GivenName, Surname, Enabled,
            @{N='Pager';E={if($_.pager){$_.pager}else{''}}}|ft 
