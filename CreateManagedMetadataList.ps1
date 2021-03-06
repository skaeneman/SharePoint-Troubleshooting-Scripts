#########################################################################################
# This script will add a Managed Metadata column to an existing list
# The script will then force all documents to use a certain term in the term store
#########################################################################################

# Url of site that contains the list
$url = "https://portal.test.com/sites/Test"

# The name of the list that will get the Managed Metadata column added to it
$listToUpdate = "testing"

# Central Administration site
$centralAdminSite = "http://centralAdmin.test.com"

# Name of the Managed Metadata store
$managedMetadataStore = "Managed Metadata Service Proxy"

# Name of the Term Group
$termGroupName = "Test Term Group"

# Name of the Term Set
$termSetName = “Test Term Set”

# Name of the term to add to the list 
$termName = "TBD"

# Name of the managed metadta list field that will be created
$newListFieldName = "Test Terms"

# Static name of the managed metadta list field that will be created (DON'T PUT SPACES IN THE NAME)
$staticNewListFieldName = "Test_Terms"

#################### DO NOT EDIT ANYTHING BELOW THIS LINE ###############################


$Web = Get-SPWeb -identity $url 
$myCustomList = $Web.Lists[$listToUpdate] 

#Connects to the Managed Metadata term store
$taxonomySite = Get-SPSite $centralAdminSite
$taxonomySession = Get-SPTaxonomySession -site $taxonomySite
$termStore = $taxonomySession.TermStores[$managedMetadataStore]
write-host “Connection made with term store -" $termStore.Name -ForegroundColor Green

#gets the term from the Managed Metadata term store
$termStoreGroup = $termStore.Groups[$termGroupName]
$termSet = $termStoreGroup.TermSets[$termSetName]
$terms = $termSet.GetAllTerms() 
$term = $terms | ?{$_.Name –eq $termName} 

#sets values for the Managed Metadata list field
Add-Type -Path ‘C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\ISAPI\Microsoft.SharePoint.Taxonomy.dll’
$taxonomyField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$myCustomList.Fields.CreateNewField(“TaxonomyFieldTypeMulti”, $newListFieldName)
$taxonomyField.Required = $true
$taxonomyField.StaticName = $staticNewListFieldName
$taxonomyField.SspId = $termStore.Id
$taxonomyField.TermSetId = $termSet.Id
$addListField = $myCustomList.Fields.Add($taxonomyField) #added $addListField to stop output
$myCustomList.Update()
Write-Host “Added field ” $taxonomyField.Title "to the list" $myCustomList.Title -ForegroundColor Green 

#adds the list field to the default view
$field = $myCustomList.Fields[$newListFieldName];
# Store the view in a variable, because calling list.DefaultView results in the creation of a NEW view object every time,
# if you do that, new columns will NEVER be added succesfully to the view.
$view = $myCustomList.DefaultView
$view.ViewFields.Add($field)
$view.Update()

#updates all docs in the list to use the managed metadata term 
$Site = Get-SPWeb $url 
$List = $Site.Lists[$listToUpdate]
$taxField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$List.Fields[$newListFieldName]

foreach($i in $list.Items)
{
  $taxField.SetFieldValue($i, $term)
  $i.update();
}

#updates the list
$myCustomList.Update() 

Write-Host “Added field ” $field.Title "to the default view" -ForegroundColor Green 


