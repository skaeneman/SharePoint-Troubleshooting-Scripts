
# 4/14/2014
# This PowerShell script will find sites older than the date sepcified in the variable $dateToCheck

################################################ MODIFY VARIABLES BELOW #########################################################
#Enter the web application
$webApp = Get-SpWebApplication 'http://'

#Enter the cutoff date (e.g. if todays date is 4/15/2014 enter 4/15/2013 to get a list of sites not modified in 1 year or more).
$dateToCheck = '4/29/2014'

#Enter path for csv file output.
$filePath = 'D:\LastModifiedWebOutput\'

#Enter file name for the CSV file
$fileName = 'lastmodified_sites.csv'

######################################### DO NOT MODIFY ANYTHING BELOW THIS LINE #################################################

Add-PSSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue

$CSVoutput = $webApp | select -ExpandProperty Sites | select -ExpandProperty AllWebs | select -ExpandProperty Webs `
| select Url, Name, LastItemModifiedDate | where {($_.LastItemModifiedDate -le $dateToCheck)} 

$path = $filePath + $fileName
  
if ($CSVoutput -ne $null)
{
    $CSVoutput | Export-Csv $path -NoTypeInformation    
}
else
{
      $emptyInfo = "No sites were found that are older than:  $dateToCheck"
      $emptyInfo | Out-File $path   
}
