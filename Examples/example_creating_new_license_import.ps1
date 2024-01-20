Import-Module "C:\Repos\SnowSoftware Repos\slm-module-SLMHelper\Modules\SLMHelper\SLMHelper.psd1" -Force   

$newlicense = New-SLMLicenseObject -ApplicationName "Photoshop" -ManufacturerName "Adobe" -Metric "Installations" -AssignmentType "Installation" -LegalOrganisation "ROOT" -PurchaseDate "20220304"

$ImportObjects = New-SLMImportObjects -SLMObjects $newlicense -InformationAction Continue

New-SLMImport -ImportObjects $ImportObjects -LicenseDirectoryPath '.\TestImportFiles' -Encoding 'UTF8' -Label "Test" -IncludeInvalid