
$employees = Invoke-Sqlcmd -ServerInstance '<SQL Server name>' -Database 'TSTestingDB' -Username '<SQL UserName>' -Password '<SQL Password>' -Query 'SELECT * FROM Employees'



foreach ($employee in $employees) {
    ## Come up with the username I'd like to create based on company policy
    $proposedUsername = '{0}{1}' -f $employee.'FirstName'.Substring(0, 1), $employee.'LastName'
    ## Check to see if the proposed username exists
    if (Get-AdUser -Filter "Name -eq '$proposedUsername'") {
        Write-Verbose -Message "The AD user [$proposedUsername] already exists."
    } else {
        ## If it does not exist, pass all of the information we have to New-AdUser
        ## This creates the user using the username we came up with above and all of the
        ## field values from the CSV file.
        $newUserParams = @{
            Name        = $proposedUsername
            Path        = "OU=$($employee.Loc),DC=yourdomain,DC=local"
            Department  = $employee.Department
            Enabled     = $true
            GivenName   = $employee.FirstName
            Surname     = $employee.LastName
            EmployeeID  = $employee.EmployeeID
            OfficePhone = $emplooyee.Phoney
        }
        New-AdUser @newUserParams
    }
}