function Sync-ActiveDirectory {
    <#
        .SYNOPSIS
            Creates Active Directory groups, OUs, and users from a CSV file.
        .PARAMETER CsvFilePath
            The file path to the CSV file containing employee records.
    #>
    [OutputType('null')]
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SQLDatabaseServer,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SQLDatabaseName,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SQLDatabaseTable,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SQLUsername,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SQLPassword
    )
 
    $ErrorActionPreference = 'Stop'
 
    ## Find the employees
    Write-Verbose -Message 'Finding employees...'
    $employees = Invoke-Sqlcmd -ServerInstance $SQLDatabaseServer -Database $SQLDatabaseName -Username $SQLUserName -Password $SQLPassword -Query "SELECT * FROM $SQLDatabaseTable"
 
    ## Create the users
    Write-Verbose -Message 'Syncing users....'
    foreach ($employee in $employees) {
 
        ## Check for and create the user
        $proposedUsername = '{0}{1}' -f $employee.FirstName.Substring(0, 1), $employee.LastName
        if (Get-AdUser -Filter "Name -eq '$proposedUsername'") {
            Write-Verbose -Message "The AD user [$proposedUsername] already exists."
        } else {
            $newUserParams = @{
                Name        = $proposedUsername
                Path        = "OU=$($employee.Loc),DC=techsnips,DC=local"
                Enabled     = $true
                GivenName   = $employee.FirstName
                Department  = $employee.Department
                Surname     = $employee.LastName
                EmployeeID  = $employee.EmployeeID
                OfficePhone = $employee.Phone
            }
            New-AdUser @newUserParams
        }
    }
}