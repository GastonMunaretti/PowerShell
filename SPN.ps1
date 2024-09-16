
setspn -A MSSQLSvc/araxtstsql.intercargo.con.ar:1433 INTERCARGO\prueba2
setspn -A MSSQLSvc/araxtstsql.intercargo.con.ar INTERCARGO\prueba2
setspn -A MSSQLSvc/araxtstsql.intercargo.con.ar:MSSQLSERVER INTERCARGO\prueba2
setspn -A MSSQLSvc/araxtstsql INTERCARGO\prueba2




setspn -A MSSQLSvc/ezesql.intercargo.con.ar:1433 INTERCARGO\prueba2



SETSPN -L INTERCARGO\Prueba

SETSPN -L sqldataax


SETSPN -L sqldataax



setspn -D MSSQLSvc/sqldataax.intercargo.con.ar:1433 INTERCARGO\Prueba

setspn -D MSSQLSvc/ezesql.intercargo.con.ar:1433 INTERCARGO\Prueba



############################################################

SetSPN -L INTERCARGO\PRUEBA2

setspn -s host/prueba2 araxtstsql

setspn -s host/prueba2.intercargo.com.ar araxtstsql



##############################################################
### Pruebas


setspn -L PRUEBA2


setspn -L araxtstsql




setspn -A intercargo\prueba2


Sqlcmd -E –Snp:araxtstsql