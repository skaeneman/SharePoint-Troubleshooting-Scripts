################################################################################################
#This script will loop through a web application and output documents added after a certain day.
################################################################################################

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
Start-SPAssignment -Global | Out-Null

# Prompts for XML location and reads user input
$xmlFileLocation = Read-Host "Enter full path of XML file (ex. C:\ConfigFile.XML)"
if(!(Test-Path -Path $xmlFileLocation))
  {
   Write-Host -ForegroundColor Red $xmlFileLocation "does not exist! Stopping Script";break
  }
  else {Write-Host -ForegroundColor Cyan "Loading XML file from:" $xmlFileLocation}
	   
#loads xml file object
[xml]$configFile = (Get-Content $xmlFileLocation)

#creates an array out of all the variables in the XML file and stores in $documentArray
$documentArray = @($configFile.DocumentCount) | where {$configFile.DocumentCount.WebApplication.Name -ne $null}

#maps XML input with variables
$webApplication = $documentArray.WebApplication.Name
$Outputfile = $documentArray.OutputFilePath.Name
#Docs after the date listed will be counted. Can search like "1/21/2015 10:44:51 PM" or "1/21/2015"
$createdDate = $documentArray.SearchAfterDate.Name
$fileTypesToSearch = $documentArray.FileExtensionsToSearch.Extension
	
#creates the CSV file 
$csvOutputHeader = "List URL; Document Name; Created Date"
$csvOutputHeader | Out-File $Outputfile -Encoding ASCII

	try
	{
		$webApp = Get-SPWebApplication $webApplication
		foreach ($site in $webApp.Sites)
		{
			foreach($web in $site.AllWebs)
			{
				$webUrl = $web.Url
				
				foreach ($list in $web.Lists)
				{
					#makes sure it's a documant library and also not hidden 
					if (($list.BaseType -eq "DocumentLibrary") -and ($list.Hidden -eq $false))
					{
						$listPath = $list.RootFolder
						$listUrl = $webUrl +"/"+ $listPath					
						$listCount = $list.Items.Count
						$listLastModified = $list.LastItemModifiedDate
						$listCreatedDate = $list.Created
						$listTitle = $list.Title
						 
						foreach($item in $list.Items)
						{
							$whenItemCreated = $item["Created"]
							$itemName = $item.Name
							
							#checks to see if list item is older than user input date
							if($whenItemCreated -ge $createdDate)
							{
								#Loops through the array of file type extensions 
								foreach($extension in $fileTypesToSearch)
								{
									$extensionName = $extension.name
									#checks if documents in list have the extensions in the array
									if($itemName -like "*$extensionName")
									{
										$addToCsvOutput = $listUrl +"; "+ $itemName +"; "+ $whenItemCreated
										$addToCsvOutput | Out-File $Outputfile -Append -Encoding ASCII
										Write-Host $addToCsvOutput
									}
								}#$extension							
							}#$whenItemCreated
						}#$item	
						#write-host $listCount, $listTitle
					}#if					
				}#foreach $list
			}#foreach $web
		}#site
	}#try

	catch [System.Exception]
	{
		$($_.Exception.Message)
	}

Stop-SPAssignment -Global | Out-Null