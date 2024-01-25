Import-Module ".\SLMHelper.psd1" -Force   

$newlicense = New-SLMLicenseObject -ApplicationName "Adobe Photoshop 7" -ManufacturerName "Adobe" -Metric "Installations" -AssignmentType "User" -LegalOrganisation "ROOT" -PurchaseDate "2022-03-04" -Quantity 5

$ImportObjects = New-SLMImportObjects -SLMObjects $newlicense -InformationAction Continue

New-SLMImport -ImportObjects $ImportObjects -LicenseDirectoryPath '.\TestImportFiles' -Encoding 'UTF8' -Label "Test" -IncludeInvalid -InformationAction Continue