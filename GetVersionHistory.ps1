
# This PowerShell script will get the version history of list items in a single list on SharePoint 2010.

################################ MODIFY VARIABLES BELOW #####################################################
$mySiteCollection = 'http://yourSite.domain.com/subsite'
$myListName = 'YourListGoesHere'
################################ DO NOT MODIFY ANYTHING BELOW THIS LINE #####################################

Start-SPAssignment -Global

Add-PSSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue

try{
        #gets the list in the SharePoint web
        $siteCollection = Get-SPWeb $mySiteCollection
        $list = $siteCollection.Lists[$myListName]
                
        #checks if version history is enabled on the list
        if ($list.EnableVersioning -eq $true)
        {
            #gets all the list items in the list
            $listItems = $list.Items
            foreach($item in $listItems)
            {                       
                #gets all versions
                $versions = $item.Versions
                
                #gets version count per list item
                $versionCount = $item.Versions.Count
                $itemName = $item.Title                
                
                foreach($version in $versions)
                {
                    #gets user who updated the verion history (user must have a correct display name)
                    $userName = $version.CreatedBy.User.DisplayName
                    
                    #gets the version number of the list item
                    $versionNumber = $version.VersionLabel
                    
                    #outputs list item name and versions for that item
                    Write-Host "List Item:" $itemName ", Version Number:" $versionNumber ", Author: $userName"

                }      
    
            }

        }#closes if
        
        #if version history is not enabled on the list the script will exit
        else
        {
            Write-Output "the list '$list' does not have version history enabled"
            exit
        }

   }#closes try

catch [Exception]
      {
        Write-Host $_.Exception.message
      }

Stop-SPAssignment -Global