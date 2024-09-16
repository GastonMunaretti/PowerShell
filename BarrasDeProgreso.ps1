#Barras de progreso


for($i = 1; $i -le 10; $i++){
    Write-Progress -Activity "Search in progress" -Status "$i% Complete" -PercentComplete $i;
    for ($j = 1; $j -le 100; $j++){
        Write-Progress -Id 1 -Activity "Search in progress" -Status "$j% Complete" -PercentComplete $j;
        Start-Sleep -Milliseconds 50
    }


}