###############################################################################################
# This PowerShell script will read from an XML file and create multiple databases.
# if the script errors you may need to manually remove the DB from the web app before running again
###############################################################################################

###############################################################################################
# loads PowerShell Snapin Microsoft.SharePoint.PowerShell
###############################################################################################

Write-Host -ForegroundColor Yellow "Enabling SharePoint PowerShell cmdlets..."
If ((Get-PsSnapin |?{$_.Name -eq "Microsoft.SharePoint.PowerShell"})-eq $null)
{
	Add-PsSnapin Microsoft.SharePoint.PowerShell | Out-Null
}
Start-SPAssignment -Global | Out-Null

###############################################################################################
# Creates Function
###############################################################################################

Function CreateDatabases{

###############################################################################################
# Prompts for XML location and reads user input
###############################################################################################

$xmlFileLocation = Read-Host "Enter full path of XML file (ex. C:\ConfigFile.XML)"
if(!(Test-Path -Path $xmlFileLocation))
  {
   Write-Host -ForegroundColor Red $xmlFileLocation "does not exist! Stopping Script";break
  }
  else {Write-Host -ForegroundColor Yellow "Loading XML file from:" $xmlFileLocation}
	   
#loads xml file object
[xml]$configFile = (Get-Content $xmlFileLocation)

###############################################################################################
# Creates new databases that are listed in the XML file. Note "`" used for line breaks
###############################################################################################
$databaseArray = @($configFile.ContentDatabases.Database)| `
where {$_.DatabaseName -ne $null -and $_.DatabaseServer -ne $null}

foreach($database in $databaseArray)
{	

try{
	#checks if a database by that name already exists in any web app, if not it creates it
	Write-Host -ForegroundColor Yellow "Checking if" $database.DatabaseName "already exists in the farm..."
	$databaseExists = Get-SPContentDatabase | where {$_.Name -eq  $database.DatabaseName} 
	if ($databaseExists -eq $null)
	{
		Write-Host ""
		Write-Host -ForegroundColor Yellow "Creating Database" $database.DatabaseName
		
		$newDatabase = New-SPContentDatabase $database.DatabaseName `
		-DatabaseServer $database.DatabaseServer `
		-WebApplication $database.WebApplication `
		-WarningSiteCount $database.WarningSiteCount `
		-MaxSiteCount $database.MaxSiteCount  
		 
		 Start-Sleep 15 
		 Write-Host ""
    }
  	   else {Write-Host -ForegroundColor "Red" "A database with the same name" $database.DatabaseName  "already exists, STOPPING SCRIPT...";break}

}#ends try

catch [system.Exception]
{
	$ErrorMessage = $_.Exception.Message
	Write-Host -ForegroundColor Red "Could not create database. $ErrorMessage"
}

try{	 
	#checks to see if database was actually created
	$getDatabase = Get-SPContentDatabase | where {$_.Name -eq  $database.DatabaseName}
	
	if ($getDatabase -ne $null)
	{
		Write-Host ""
		Write-Host -ForegroundColor Yellow "Created Database:" $database.DatabaseName 
		Write-Host -ForegroundColor Yellow "Database Server:" $database.DatabaseServer
		Write-Host -ForegroundColor Yellow "Web Application:" $database.WebApplication
		Write-Host -ForegroundColor Yellow "Warning Site Count:" $database.WarningSiteCount
		Write-Host -ForegroundColor Yellow "Max Site Count:" $database.MaxSiteCount 
	}
	else{Write-Host -ForegroundColor Red "Could not verify if" $database.DatabaseName "was created."}
	
#  }#endsif
#  	   else {Write-Host -ForegroundColor "Red" "A database with the same name" $database.DatabaseName  "already exists, STOPPING SCRIPT...";break}
}#ends try
catch [system.Exception]
{
	$ErrorMessage = $_.Exception.Message
	Write-Host -ForegroundColor Red "Could not verify if" $database.DatabaseName "was created. $ErrorMessage"
}

 }#ends foreach

Stop-SPAssignment -Global | Out-Null

}#ends CreateDatabases function

#calls function
CreateDatabases
