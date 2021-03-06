###############################################################################################
# This PowerShell script will read from an XML file and create multiple site collections
###############################################################################################

Write-Host -ForegroundColor Yellow "Enabling SharePoint PowerShell cmdlets..."
If ((Get-PsSnapin |?{$_.Name -eq "Microsoft.SharePoint.PowerShell"})-eq $null)
{
	Add-PsSnapin Microsoft.SharePoint.PowerShell | Out-Null
}

Start-SPAssignment -Global | Out-Null

function CreateSites {
  [CmdletBinding()]
  param 
  (  
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$SettingsFile
  )
#gets xml file
[xml]$configFile = Get-Content $SettingsFile
Clear-Host

try{	
	#creates an array of site collections from the XML file input               
	$siteCollectionList = @($configFile.SiteCollections.SiteCollection | where {$_.SiteName -ne $null -and $_.SiteUrl -ne $null})
	
	#checks to see if a site collection URL already exists with that same name
	foreach($siteCollection in $siteCollectionList)
	{
	 $exsitingSite = Get-SPSite | Where {$_.Url -eq $siteCollection.SiteUrl}
	 
	 Write-Host -ForegroundColor Yellow "Checking if the site collection" $siteCollection.SiteName "already exists before creating..."
	 if($exsitingSite -eq $null) 
	 {
	    #creates site collection if none exists
	    Write-Host -ForegroundColor "yellow" "Creating the site collection" $siteCollection.SiteUrl
		
	    $siteCol = New-SPSite $siteCollection.SiteUrl `
	    -OwnerAlias $siteCollection.PrimaryOwner `
	    -SecondaryOwnerAlias $siteCollection.SecondaryOwner `
	    -Name $siteCollection.SiteName  `
	    -Template $siteCollection.SiteTemplate `
	    -Description $siteCollection.SiteDescription `
		-ContentDatabase $siteCollection.ContentDatabase `
		-QuotaTemplate $siteCollection.QuotaTemplate
		 Start-Sleep 5 
		 
		 #checks to see if the site collection was actually created
		 # $url = $siteCollection.SiteUrl
		 # $db = $siteCollection.ContentDatabase
	 	 $doesSiteExist = Get-SPWeb -Identity $siteCollection.SiteUrl | Select-Object -Property Exists -ErrorAction SilentlyContinue	
		 if($doesSiteExist -ne $null)
		 {
		 	Write-Host ""
		 	Write-Host -ForegroundColor Yellow "Created Site:" $siteCollection.SiteUrl
			Write-Host -ForegroundColor Yellow "Site Name:" $siteCollection.SiteName
			Write-Host -ForegroundColor Yellow "Primary Owner:" $siteCollection.PrimaryOwner	
			Write-Host -ForegroundColor Yellow "Secondary Owner:" $siteCollection.SecondaryOwner
			Write-Host -ForegroundColor Yellow "Quota Template:" $siteCollection.QuotaTemplate
			Write-Host -ForegroundColor Yellow "Content Database:" $siteCollection.ContentDatabase
		 }
	     else {Write-Host -ForegroundColor "Red" $siteCollection.SiteUrl "was not created, STOPPING SCRIPT...";break}

		 Start-Sleep 5
		 Write-Host ""
		 Write-Host ""
	 }
	   else {Write-Host -ForegroundColor "Red" "A site with the same name" $siteCollection.SiteName "already exists, STOPPING SCRIPT...";break}
	}
}#ends try

catch [system.Exception]
{
	$ErrorMessage = $_.Exception.Message
	Write-Warning "Error: A site was not created. $ErrorMessage" 
}
    
}#ends function

#calls function
CreateSites

Stop-SPAssignment -Global | Out-Null