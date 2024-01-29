# Import-Module ".\SLMHelper.psd1" -Force   

$newlicense = New-SLMLicenseObject -ApplicationName "Adobe Photoshop 7" -ManufacturerName "Adobe" -Metric "Installations" -AssignmentType "User" -LegalOrganisation "ROOT" -PurchaseDate "2022-03-04" -Quantity 5

if (-not $creds) {
    $creds = Get-Credential
}

$SLMApiEndpointConfiguration = New-SLMApiEndpointConfiguration -SLMUri "https://demo.snowsoftware.com" -SLMCustomerId 1 -SLMApiCredentials $creds -SLMEndpointPath 'users'  -CleanupBody -OnlyFirstPage

$license = Get-SLMLicenseDetails -SLMApiEndpointConfiguration $SLMApiEndpointConfiguration -Id 1 -ReturnAsSLMObject

$ImportObjects = New-SLMImportObjects -SLMObjects $license -InformationAction Continue

New-SLMImport -ImportObjects $ImportObjects -LicenseDirectoryPath '.\TestImportFiles' -Encoding 'UTF8' -Label "Test" -IncludeInvalid -InformationAction Continue