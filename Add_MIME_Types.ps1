﻿#This PowerShell script will add the MIME types in the array variable to a web application
#The Browser File Handeling will remain in strict mode

$webAppUrl =  "http://yourwebapp.domain.com"
#add additional MIME types to the $mimeTypeArray variable
$mimeTypeArray = @("application/pdf","text/html", "text/htm")
$webApp = Get-SPWebApplication $webAppUrl

foreach ($i in $mimeTypeArray)
{
    If ($webApp.AllowedInlineDownloadedMimeTypes -notcontains $i)
    {
           Write-Host "Adding MIME Type $i..."
           $webApp.AllowedInlineDownloadedMimeTypes.Add($i)
           $webApp.Update()
           Write-Host "Done."           
    } Else {
       Write-Host "MIME $i is already added."
    }
}#ends foreach

 
