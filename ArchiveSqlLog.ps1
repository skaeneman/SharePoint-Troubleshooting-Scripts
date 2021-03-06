
#######################################################################################################
# This PowerShell script will move the ERRORLOG.6 file and recycle the SQL Log to generate a new one
########################################################################################################

Add-PSSnapin SqlServerCmdletSnapin100 -EA 0
Add-PSSnapin SqlServerProviderSnapin100 -EA 0

$date = (((get-date)).ToString("yyyyMMddhhss"))
$path = "D:\Program Files\Microsoft SQL Server\MSSQL10_50.SPSQL\MSSQL\Log\ERRORLOG.6"
$destination = "\\192.168.1.1\D$\test\test2\"+$date+"_ERRORLOG.6"
$sqlServerInstance = "S01A-SPSQL02\SPSQL"

#######################################################################################################
# Checks of the file exists and moves it to another server if it does
#######################################################################################################

try{
    #checks if file exsits in $path, stops script if it doesn't
    if (!(Test-Path -path $path))		
    {			
        Write-Host "ERRORLOG was not found:" $path;break
    }
    else {    
        #moves the file if it exists in $path to $destination
        Write-Host "Moving file to" $destination
        Move-Item -path $path -destination $destination
    }
}
catch [System.Exception] 
{
  Write-Host "Error occured: " $_
}

#######################################################################################################
# Checks if file was moved to the new location and generates a new SQL Error log
# Can add the SQL agent log as well with this "sp_cycle_agent_errorlog"
#######################################################################################################

try{
    #checks if file was actually moved over to $destination and creates new SQL ERRORLOG
    if (Test-Path -path $destination)
    {		
       Write-Host "Creating new SQL Error Log" 	
       Invoke-Sqlcmd -ServerInstance $sqlServerInstance -Query "sp_cycle_errorlog"
    }
    else {    
        write-host $destination "doesn't exist"
    }
}
catch [System.Exception] 
{
  Write-Host "Error occured: " $_
}





