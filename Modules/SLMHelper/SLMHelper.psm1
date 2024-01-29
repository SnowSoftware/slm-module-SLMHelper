#Requires -Modules ImportExcel

#region Enums
enum SLMObjectTypes {
    SLMOrganisationObject
    SLMUserObject
    SLMComputerObject
    SLMAgreementObject
    SLMLicenseObject
    SLMApplicationObject
}
#endregion

#region Tools
function ConvertTo-CustomFieldValueObject {
    #Example:
    #[SLMCustomFieldValueObject[]]$PSBoundParameters.CustomValues = ConvertTo-CustomFieldValueObject -CustomValues $CustomValues -TargeType SLMCustomFieldValueObject
    param(
        $CustomValues,

        [ValidateSet('Object', 'SLMCustomFieldValueObject')]
        $TargeType
    )

    if ($null -eq $CustomValues) { return }

    if ($CustomValues.GetType() -eq [SLMCustomFieldValueObject] `
            -and $TargeType -eq 'SLMCustomFieldValueObject') {
        return $CustomValues
    }

    if ($CustomValues.GetType() -ne [SLMCustomFieldValueObject] `
            -and $TargeType -eq 'SLMCustomFieldValueObject') {

        [SLMCustomFieldValueObject[]]$NewCustomValues = @()
        foreach ($CustomValue in $CustomValues) {
            $returnObject = New-SLMCustomFieldValueObject -type $CustomValue.'$type' -Name $CustomValue.Name -DataType $CustomValue.DataType -Value $CustomValue.Value
            $NewCustomValues += $returnObject
        }


        return $NewCustomValues
    }

    if ($CustomValues.GetType() -eq [Object[]] `
            -and $TargeType -eq 'Object') {
        return $CustomValues
    }

    if ($CustomValues.GetType() -ne [Object[]] `
            -and $TargeType -eq 'Object') {
        return [Object]$CustomValues
    }

}
#endregion

#region Classes
class SLMOrganisationObject {
    [String]$Organisation
    [Int32]$OrgChecksum
    [bool]$Validated
}
class SLMUserObject {
    [Int32]$Id
    [Int32]$CustomerId
    [String]$Username
    [String]$FullName
    [String]$Organization
    [Int32]$OrgChecksum
    [String]$LastLogon
    [Int32]$LastUsedComputerId
    [String]$LastUsedComputerName
    [String]$AutoEditing
    [String]$Email
    [String]$Location
    [String]$MobilePhoneNumber
    [String]$PhoneNumber
    [String]$RoomNumber
    [ValidateSet('Active', 'Quarantined')][String]$StatusCode
    [String]$QuarantineManagement
    [nullable[datetime]]$QuarantineDate
    [nullable[datetime]]$QuarantineDeleteDate
    [nullable[datetime]]$UpdatedDate
    [String]$UpdatedBy
    [SLMCustomFieldValueObject[]]$CustomFields
}
class SLMComputerObject {

    [String]$type
    [Int32]$Id
    [String]$Name
    [String]$Organization
    [Int32]$OrgChecksum
    [String]$Manufacturer
    [String]$Model
    [String]$OperatingSystem
    [String]$OperatingSystemServicePack
    [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsVirtual
    [String]$Status
    [String]$IpAddresses
    [nullable[datetime]]$LastScanDate
    [String]$UpdatedBy
    [nullable[datetime]]$UpdatedDate
    [String]$Domain
    [Int32]$TotalDiskSpace
    [Int32]$PhysicalMemory
    [String]$ProcessorType
    [Int32]$ProcessorCount
    [Int32]$CoreCount
    [String]$BiosSerialNumber
    [String]$Hardware
    [String]$HypervisorName
    [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsPortable
    [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsServer
    [Int32]$MostFrequentUserId
    [Int32]$MostRecentUserId
    [SLMCustomFieldValueObject[]]$CustomFields
    [bool]$Validated

    [bool] Validate() {

        if (-not $global:SLMApiEndpointConfiguration) {
            Write-Error "Global SLMApiEndpointConfiguration not set, please set using New-SLMApiEndpointConfiguration."
            return $null
        }

        $filter = @()

        $filter += "(Id eq $($this.Id))"
        if ($this.Name) { $filter += "(Name eq '$($this.Name)')" }
        if ($this.BiosSerialNumber) { $filter += "(BiosSerialNumber eq '$($this.BiosSerialNumber)')" }
        $filter = $filter -join " and "

        $result = Get-SLMComputers -SLMApiEndpointConfiguration $global:SLMApiEndpointConfiguration -filter $filter

        if ($result.Count -le 0) {
            $this.Validated = $false
            return $false
        }

        if ($result.Count -gt 1) {
            Write-Warning "More than one computer object found."
        }    

        if ($result.Count -gt 0) {
            $this.Validated = $true
            return $true
        }

    

        return $null
        
    }
}
class SLMAgreementObject {
    [String]$Id
    [String]$MasterId
    [String]$Name
    [String]$Contractor
    [String]$ContractorWebsite
    [String]$ContractorPhone
    [String]$AgreementType
    [String]$AgreementNumber
    [String]$ActivePeriodFrom
    [String]$ActivePeriodTo
    [String]$Organization
    [String]$IsSubscription
    [String]$AutomaticLicenseUpgrades
    [String]$RenewalDaysBeforeExpiration
    [String]$SelectableAfterExpiration
    [String]$RestrictedOrganizationAccess
    [String]$AlertOnExpiration
    [String]$AlertWarningDaysBeforeExpiration
    [String]$AlertCriticalDaysBeforeExpiration
    [String]$RestrictedRoleAccess
    [String]$AutoAttachComputers
    [String]$AutoAttachComputersFromOrganizations
    [String]$ContractorContact
    [String]$ContractorContactPhone
    [String]$ContractorContactEmail
    [String]$LocalContact
    [String]$LocalContactDepartment
    [String]$LocalContactPhone
    [String]$LocalContactEmail
    [String]$CreatedBy
    [nullable[datetime]]$CreatedDate
    [String]$UpdatedBy
    [nullable[datetime]]$UpdatedDate
    [String]$Description
    [String]$AgreementPeriod
    [String]$CustomFields
    [String]$RestrictedToRole
}
Class SLMLicenseObject {

    #SLM API fields + shared
    [Int32]$Id
    [String]$ApplicationName
    [String]$ManufacturerName
    [String]$Metric
    [ValidateSet('Organisation', 'Computer/datacenter', 'User', 'Site')]
    [String]$AssignmentType
    [nullable[datetime]]$UpdatedDate
    [String]$UpdatedBy
    [nullable[Boolean]]$AutomaticDowngrade # Is this equal to Downgrade rights in import?
    [nullable[Boolean]]$UpgradeRights
    [String]$InvoiceReference
    [nullable[datetime]]$PurchaseDate
    [nullable[decimal]]$PurchasePrice
    [String]$PurchaseCurrency
    [Int32]$Quantity
    [String]$Vendor
    [String]$ExternalId
    [String]$InstallationMedia
    [String]$LicenseProofLocation
    [String]$LicenseKeys
    [String]$Notes
    [nullable[Boolean]]$IsIncomplete
    [SLMCustomFieldValueObject[]]$CustomFields
    [object[]]$Allocations

    #SLM License Import Template only
    [string]$SKU
    [string]$LegalOrganisation
    [nullable[Boolean]]$IsUpgrade 
    [Int32]$UpgradeFromLicenseID
    [String]$BaseLicenseQuantityToUpgrade
    [String]$SubscriptionValidFrom
    [String]$SubscriptionValidTo
    [nullable[Boolean]]$IsSubscription
    [String]$CrossEditionRights
    [String]$DowngradeRights # Is this equal to AutomaticDowngrade rights in API?
    [nullable[Boolean]]$AutoAllocate
    [nullable[Boolean]]$MaintenanceIncludesUpgradeRights
    [nullable[Boolean]]$MaintenanceAccordingToAgreement
    [String]$MaintenanceAndSupportValidFrom
    [String]$MaintenanceAndSupportValidTo
    [String]$AgreementNumber
    [String]$ProductDescription

}
Class SLMApplicationObject {
    [Guid]$Id      #Guid	The id of the application.
    [String]$Name        #String	The name of the application.
    [Guid]$ManufacturerId      #Guid	The id of the application's manufacturer.
    [String]$ManufacturerName        #String	The name of the application's manufacturer.
    [String]$ManufacturerWebsite         #String	The URL of the manufacturer's website.
    [String]$LanguageName        #String	The name of the application's language.
    [nullable[datetime]]$ReleaseDate         #DateTime-Nullable	The application's release date.
    [nullable[datetime]]$CreatedDate         #DateTime	The date and time at which the application was created.
    [String]$CreatedBy       #String	The name of the user that created the application.
    [nullable[datetime]]$UpdatedDate         #DateTime	The date/time at which the application was last updated.
    [String]$UpdatedBy       #String	The name of the user that updated the application.
    [String]$Description         #String	Custom description of the application.
    [String]$SystemOwnerName         #String	Name of the system owner of the application.
    [String]$SystemOwnerPhone        #String	Phone number of the system owner of the application.
    [String]$SystemOwnerEmail        #String	Email address of the system owner of the application.
    [String]$Media       #String	Storage location for the installation media.
    [Boolean]$IsOperatingSystem       #Boolean	True if this is an operating system, false if not.
    [String]$OperatingSystemType         #OperatingSystemType	The name of the operating system that this application runs on.
    [String[]]$ApplicationTypes        #Array-of-String	A list of application types that this application falls under.
    [String[]]$UpgradeOptions      #Array-of-String	A list of names of applications that this application can be upgraded to.
    [String[]]$DowngradeOptions        #Array-of-String	A list of names of applications that this application can be downgraded to.
    [Int32]$TotalCoverage       #Int32	The total coverage of licenses
    [Boolean]$LicenseRequired         #Boolean	Does this application require a commercial licence?
    [Int32]$LicenseRequirement      #Int32	The actual number of licenses required to be compliant on a specific application.
    [Int32]$LicenseCount        #Int32	Total number of available licenses.
    [Int32]$InstallationCount       #Int32	Number of installations.
    [Int32]$BundleInstallationCount         #Int32	Number of bundle installations.
    [Int32]$UnusedInstallationCount         #Int32	Number of unused installations.
    [decimal]$UsageFactor         #Decimal-Nullable	A value indicating how many percent of the installations are used. A value of 0 means 0%, while a value of 1 means 100%.
    [Int32]$UserCount       #Int32	Total number of users.
    [Decimal]$Risk        #Decimal	Calculated value based on over licensing or under licensing of the application. This creates a positive (over investment) or negative (possible debt) value. The calculated value is based on license purchase cost. If no license purchase cost is registered the calculation will use the application cost setting.
    [Decimal]$RiskUnused      #Decimal-Nullable	A risk value to show the possible over investment made (unused software).
    [Int32]$Compliance      #Int32	Licensing compliance for this application. A negative value indicates too few licences, while a positive value indicates that the application is overlicensed. A value of 0 (zero) indicates that the application is compliant.
    [String]$Allocation      #Array-of-OrgComplianceSummary	Licensing compliance information per organization.
    [String]$LicenseKeys         #String	License keys added to the application.
    [String]$Metric      #String	The metric name used to calculate license for the application.
    [Decimal]$ApplicationCostTotal        #Decimal	Calculated total value based on the application cost setting.
    [Decimal]$ApplicationCostPerLicense       #Decimal	The license cost for the application
    [Decimal]$AverageCostPerLicense       #Decimal	Calculated average value based on all license purchases registered for this application.
    [Decimal]$LicenseCostTotal        #Decimal	Calculated total value based on all license purchases registered for this application.
    [String]$LicenseCostCurrency         #String	The currency used for the license cost.
    [Decimal]$UserLicenseCost         #Decimal-Nullable	The per-user license cost for the application.
    [Nullable[Boolean]]$AlertOnOverlicensing        #Boolean-Nullable	Alert when application is overlicensed (show in overlicensed collection).
    [Nullable[Boolean]]$AlertOnUnderlicensing       #Boolean-Nullable	Alert when application is underlicensed (show in underlicensed collection).
    [Nullable[Boolean]]$AlertWhenNotUsed        #Boolean-Nullable	Alert when application is not used.
    [SLMCustomFieldValueObject[]]$CustomValues        #Array-of-CustomFieldValue	An array of custom values for the application.
    [Nullable[Boolean]]$SecondaryUseAllowed         #Boolean-Nullable	Allow secondary use.
    [Nullable[Boolean]]$MultipleVersionsAllowed         #Boolean-Nullable	Allow multiple versions.
    [Nullable[Boolean]]$MultipleEditionsAllowed         #Boolean-Nullable	Allow multiple editions.
}
Class SLMCustomFieldValueObject {
    #https://demo.snowsoftware.com/api/customers/1/sim/customfields/applications
    #https://demo.snowsoftware.com/api/customers/1/applications/{applicationId}
    [String]$type
    [String]$Name
    [Int32]$CustomFieldId
    [String]$DataType
    [String]$ElementId
    [String]$Value
    [nullable[datetime]]$UpdatedDate
}
Class SLMCustomFieldDefinitionObject {
    #https://demo.snowsoftware.com/api/customers/1/sim/customfields/definitions
    [String]$type
    [Int32]$CustomFieldId
    [Int32]$CategoryId
    [String]$Name
    [String]$Description
    [Int32]$ValueDataTypeId
    [bool]$IsMandatory
    [String]$DefaultValue
    [String]$MultipleChoice
    [nullable[datetime]]$CreatedDate
    [nullable[datetime]]$UpdatedDate
}
class SLMImportObject {
    $SLMObject
    [SLMObjectTypes]$SLMObjectType
    [nullable[boolean]]$DisableAutoEditing
    [boolean]$Valid = $false


    [bool] Validate() {

        $isValid = $true

        if (-not $global:SLMApiEndpointConfiguration) {
            Write-Error "Global SLMApiEndpointConfiguration not set, please set using New-SLMApiEndpointConfiguration."
            return $null
        }

        switch ($this.SLMObjectType) {
            'SLMLicenseObject' {

                if ( -not [string]::IsNullOrEmpty($this.SLMObject.ApplicationName)) {
                    $SLMApplication = Get-SLMApplications -SLMApiEndpointConfiguration $global:SLMApiEndpointConfiguration -Name $this.SLMObject.ApplicationName -ReturnSLMApplicationObjects
                    if ($SLMApplication.Count -le 0) {
                        Write-Information "ApplicationName [$($this.SLMObject.ApplicationName)] does not exist in SLM API (inventoried data), could still exist in global catalog." 
                    }
                }

                if (
                    ( [string]::IsNullOrEmpty($this.SLMObject.ApplicationName) `
                        -and [string]::IsNullOrEmpty($this.SLMObject.SKU) ) `
                        -or [string]::IsNullOrEmpty($this.SLMObject.LegalOrganisation) `
                        -or [string]::IsNullOrEmpty($this.SLMObject.PurchaseDate) `
                        -or [string]::IsNullOrEmpty($this.SLMObject.AssignmentType) `
                        -or ($this.SLMObject.Quantity -le 0) `
                ) {
                    Write-Information "SLMLicenseObject does not have all required fields (ApplicationName or SKU, LegalOrganisation, PurchaseDate, AssignmentType, Quantity > 0)" 
                    $isValid = $false
                }
                $this.Valid = $isValid
                return $isValid
            }
            Default {
                Write-Warning "Object is not an SLMObject, skipping."
                Write-Debug "Object: $this.SLMObject"
                $isValid = $false
                $this.Valid = $isValid
                return $false
            }
        }

        $isValid = $false
        $this.Valid = $isValid
        return $false
    }




}
#endregion

#region API Functions
Function Get-SLMApiEndpoint {
    <#
    .PARAMETER  SLMUri
    Uri of the SLM instance to use. 
    Example: https://slm.company.local

    .PARAMETER  SLMCustomerId
    Id of the customer in Snow License Manager.
    Example: 1

    .PARAMETER  SLMApiCredentials
    Credentials for account to access Snow License Manager API.
    Example [PSCredential]-object

    .PARAMETER  SLMEndpointPath
    Path of URI to the API endpoint you want to request
    Example: computers                                  (for https://slm.company.local/api/customers/1/computers/)
    Example: customers/1/users/9492                     (for https://slm.company.local/api/customers/1/users/9492/)

    .PARAMETER  top
    The top ammount of objects to return per page.
    Example: 5                                          (for https://slm.company.local/api/customers/1/computers/?$top=5)

    .PARAMETER  OnlyFirstPage
    Switch parameter to only retrieve the first page of results.

    .PARAMETER  filter
    String to filter the result retrieved.
    Example: UpdatedBy eq 'LicenseManagerImportTool'    (for https://slm.company.localapi/customers/1/computers/?$filter=UpdatedBy eq 'LicenseManagerImportTool')

    .PARAMETER  format
    Setting for the format retrieved
    Example: xml                                        (for https://demo.snowsoftware.com/api/customers/1/computers/?$format=xml)

    .PARAMETER  CleanupBody
    Switch that activates cleanup of the body response from the API.
    #>

    param(
        [Parameter(Mandatory)]
        [string]
        $SLMUri,

        [Parameter(Mandatory)]
        [ValidateRange(1, 30000)]
        [int]        
        $SLMCustomerId,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $SLMApiCredentials,

        [Parameter(Mandatory)]
        [string]
        $SLMEndpointPath,

        [int]
        $top = 1000,

        [switch]
        $OnlyFirstPage,

        [string]
        $filter,

        [ValidateSet("json", "xml", "html")]
        [string]
        $format = "json",

        [switch]
        $CleanupBody
    )

    #Setup and run intial request
    $SLMResult = @()
    $uri = "$SLMUri/API/customers/$SLMCustomerId/$SLMEndpointPath/?" + '$format=' + $format + '&$top=' + [string]$top
    if (![string]::IsNullOrEmpty($filter)) { $uri = $uri + '&$filter=' + $filter }
    $SLMResponse = Invoke-RestMethod -Uri $uri -Method Get -Credential $SLMApiCredentials -UseBasicParsing
    if ($CleanupBody) {
        if ([string]::IsNullOrEmpty($SLMResponse.Body.Body)) {
            $SLMResult += $SLMResponse.Body
        }
        else {
            $SLMResult += $SLMResponse.Body.Body
        }
    }
    else {
        $SLMResult += $SLMResponse
    }

    #iterate
    $uri = $SLMResponse.Links | Where-Object { $_.Rel -eq 'Next' } | Select-Object -ExpandProperty HREF
    if ($OnlyFirstPage) { $uri = $null }
    while (![string]::IsNullOrEmpty($uri)) { 
        $SLMResponse = Invoke-RestMethod -Uri $uri -Method Get -Credential $SLMApiCredentials -UseBasicParsing
        if ([string]::IsNullOrEmpty($SLMResponse.Body.Body)) {
            $SLMResult += $SLMResponse.Body
        }
        else {
            $SLMResult += $SLMResponse.Body.Body
        }
        $uri = $SLMResponse.Links | Where-Object { $_.Rel -eq 'Next' } | Select-Object -ExpandProperty HREF
    }

    return $SLMResult

}
Function New-SLMApiEndpointConfiguration {
    param(
        [Parameter(Mandatory)]
        [string]
        $SLMUri,

        [Parameter(Mandatory)]
        [ValidateRange(1, 30000)]
        [int]        
        $SLMCustomerId,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $SLMApiCredentials,

        [string]
        $SLMEndpointPath,

        [int]
        $top = 1000,

        [switch]
        $OnlyFirstPage,

        [string]
        $filter,

        [ValidateSet("json", "xml", "html")]
        [string]
        $format = "json",

        [switch]
        $CleanupBody,

        [switch]
        $DontSetGlobal
    )
    
    $splat = @{
        SLMUri            = $SLMUri
        SLMCustomerId     = $SLMCustomerId
        SLMApiCredentials = $SLMApiCredentials
        SLMEndpointPath   = $SLMEndpointPath
        top               = $top
        OnlyFirstPage     = $OnlyFirstPage
        filter            = $filter
        format            = $format
        CleanupBody       = $CleanupBody
    }
    
    if ($filter) { Write-Warning "Filter is set, but should not be used in configuration." }
    if ($OnlyFirstPage) { Write-Warning "OnlyFirstPage is set, will only retrieve first page of results." }

    if (-not $DontSetGlobal) {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'existModuleName',
            Justification = 'variable is used in another scope')]
        $global:SLMApiEndpointConfiguration = $splat
    }

    return $splat
}
#endregion

#region Computer functions
Function New-SLMComputerObject {
    param(
        [String]$type,
        [Int32]$Id,
        [String]$Name,
        [String]$Organization,
        [Int32]$OrgChecksum,
        [String]$Manufacturer,
        [String]$Model,
        [String]$OperatingSystem,
        [String]$OperatingSystemServicePack,
        [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsVirtual,
        [String]$Status,
        [String]$IpAddresses,
        [nullable[datetime]]$LastScanDate,
        [String]$UpdatedBy,
        [nullable[datetime]]$UpdatedDate,
        [String]$Domain,
        [Int32]$TotalDiskSpace,
        [Int32]$PhysicalMemory,
        [String]$ProcessorType,
        [Int32]$ProcessorCount,
        [Int32]$CoreCount,
        [String]$BiosSerialNumber,
        [String]$Hardware,
        [String]$HypervisorName,
        [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsPortable,
        [ValidateSet('YES', 'NO', 'false', 'true')][String]$IsServer,
        [Int32]$MostFrequentUserId,
        [Int32]$MostRecentUserId
    )

    $SLMComputer = New-Object -TypeName SLMComputerObject -Property $PSBoundParameters

    return $SLMComputer

}
Function Get-SLMComputers {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [int]
        $Id,

        [string]
        $Name,

        [string]
        $Organization,

        [ValidateSet("Yes", "yes", "YES", "No", "no", "NO")]
        [string]
        $IsVirtual,

        [ValidateSet('Active', 'Quarantined', 'Inactive')]
        [string]
        $Status,

        [string]
        $BiosSerialNumber,

        [ValidateSet("Yes", "yes", "YES", "No", "no", "NO")]
        [string]
        $IsPortable,

        [ValidateSet("Yes", "yes", "YES", "No", "no", "NO")]
        [string]
        $IsServer,

        [int]
        $MostFrequentUserId,

        [int]
        $MostRecentUserId,

        [string]
        $filter,

        [switch]
        $ReturnSLMComputerObjects
    )

    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()
    

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($Id) {
            $filterArray += "(Id eq $Id)"
        }

        if ($Name) {
            $filterArray += "(Name eq '$Name')"
        }

        if ($Organization) {
            $filterArray += "(Organization eq '$Organization')"
        }

        if ($IsVirtual) {
            if ($IsVirtual.ToLower() -eq 'yes') {
                $filterArray += "(IsVirtual eq true)"
            }
            if ($IsVirtual.ToLower() -eq 'no') {
                $filterArray += "(IsVirtual eq false)"
            }
        }

        if ($Status) {
            $filterArray += "(Status eq '$Status')"
        }

        if ($BiosSerialNumber) {
            $filterArray += "(BiosSerialNumber eq '$BiosSerialNumber')"
        }

        if ($IsPortable) {
            if ($IsPortable.ToLower() -eq 'yes') {
                $filterArray += "(IsPortable eq true)"
            }
            if ($IsPortable.ToLower() -eq 'no') {
                $filterArray += "(IsPortable eq false)"
            }
        }

        if ($IsServer) {
            if ($IsServer.ToLower() -eq 'yes') {
                $filterArray += "(IsServer eq true)"
            }
            if ($IsServer.ToLower() -eq 'no') {
                $filterArray += "(IsServer eq false)"
            }
        }

        if ($MostFrequentUserId) {
            $filterArray += "(MostFrequentUserId eq $MostFrequentUserId)"
        }

        if ($MostRecentUserId) {
            $filterArray += "(MostRecentUserId eq $MostRecentUserId)"
        }

    
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'computers'
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnSLMComputerObjects) {
        Write-Information "Will return SLMComputerObjects"
        $SlmComputerObjects = @()
        foreach ($resultComputer in $result) {
            $table = @{}
            $resultComputer.psobject.properties.name | ForEach-Object { $table.Add($_, $resultComputer.$_) }
            $SlmComputerObjects += New-SLMComputerObject @table #-Id $resultComputer.Id -Name $result
        }
        
        return $SlmComputerObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result

}
#endregion
#region User functions
Function New-SLMUserObject {
    param(
        [Int32]$Id,
        [Int32]$CustomerId,
        [String]$Username,
        [String]$FullName,
        [String]$Organization,
        [Int32]$OrgChecksum,
        [String]$LastLogon,
        [Int32]$LastUsedComputerId,
        [String]$LastUsedComputerName,
        [String]$AutoEditing,
        [String]$Email,
        [String]$Location,
        [String]$MobilePhoneNumber,
        [String]$PhoneNumber,
        [String]$RoomNumber,
        [ValidateSet('Active', 'Quarantined')][String]$StatusCode,
        [String]$QuarantineManagement,
        [nullable[datetime]]$QuarantineDate,
        [nullable[datetime]]$QuarantineDeleteDate,
        [nullable[datetime]]$UpdatedDate,
        [String]$UpdatedBy,
        [hashtable]$CustomFields
    )

    $SLMUser = New-Object -TypeName SLMUserObject -Property $PSBoundParameters

    return $SLMUser

}
Function Get-SLMUsers {
    
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [int]
        $Id,

        [string]
        $Username,

        [string]
        $Organization,

        [string]
        $Email,

        [ValidateSet('Active', 'Quarantined')]
        [string]
        $StatusCode,

        [string]
        $filter,

        [switch]
        $ReturnSLMUserObjects
    )
    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()
    

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($Id) {
            $filterArray += "(Id eq $Id)"
        }

        if ($Username) {
            $filterArray += "(Username eq '$Username')"
        }

        if ($Organization) {
            $filterArray += "(Organization eq '$Organization')"
        }
        if ($Email) {
            $filterArray += "(Email eq '$Email')"
        }
        
        if ($StatusCode) {
            if ($StatusCode -eq 'Active') {
                $filterArray += "(StatusCode eq 'Active')"
            }
            if ($StatusCode -eq 'Quarantined') {
                $filterArray += "(StatusCode eq 'Quarantined')"
            }
        }  
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'users'
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnSLMUserObjects) {
        Write-Information "Will return ReturnSLMUserObjects"
        $SlmUserObjects = @()
        foreach ($resultUser in $result) {
            $table = @{}
            $resultUser.psobject.properties.name | ForEach-Object { $table.Add($_, $resultUser.$_) }
            $SlmUserObjects += New-SLMUserObject @table #-Id $resultUser.Id -Name $result
        }
        
        return $SlmUserObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result
}
#endregion
#region Organisation functions
Function New-SLMOrganisationObject {

}
Function Get-SLMOrganisations {
    param(
        $OrgChecksum,
        $Organisation
    )
}
#endregion
#region Custom Field and values functions
Function New-SLMCustomFieldDefinitionObject {
    param(
        [String]$type,
        [Int32]$CustomFieldId,
        [Int32]$CategoryId,
        [String]$Name,
        [String]$Description,
        [Int32]$ValueDataTypeId,
        [bool]$IsMandatory,
        [String]$DefaultValue,
        [String]$MultipleChoice,
        [nullable[datetime]]$CreatedDate,
        [nullable[datetime]]$UpdatedDate
    )

    $SLMCustomFieldDefinitionObject = New-Object -TypeName SLMCustomFieldDefinitionObject -Property $PSBoundParameters

    return $SLMCustomFieldDefinitionObject

}
Function Get-SLMCustomFieldDefinitions {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [int]
        $CustomFieldId,

        [int]
        $CategoryId,

        [string]
        $Name,

        [int]
        $ValueDataTypeId,

        [bool]
        $IsMandatory,

        # 1 User
        # 2 Computer/Mobile device
        # 3 License
        # 4 Agreement
        # 5 Application
        [Validateset('User', 'Computer', 'License', 'Agreement', 'Application')]
        [String]
        $ObjectType,

        [string]
        $filter,

        [switch]
        $ReturnSLMCustomFieldDefinitionObjects
    )
    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($CustomFieldId) {
            $filterArray += "(CustomFieldId eq $CustomFieldId)"
        }

        if ($CategoryId) {
            $filterArray += "(CategoryId eq $CategoryId)"
        }

        # 1 User
        # 2 Computer/Mobile device
        # 3 License
        # 4 Agreement
        # 5 Application
        switch ($ObjectType) {
            'User' { $filterArray += "(CategoryId eq 1)" }
            'Computer' { $filterArray += "(CategoryId eq 2)" }
            'License' { $filterArray += "(CategoryId eq 3)" }
            'Agreement' { $filterArray += "(CategoryId eq 4)" }
            'Application' { $filterArray += "(CategoryId eq 5)" }
            Default {}
        }
        

        if ($ValueDataTypeId) {
            $filterArray += "(ValueDataTypeId eq $ValueDataTypeId)"
        }

        if ($Name) {
            $filterArray += "(Name eq '$Name')"
        }

        if ($IsMandatory) {
            $filterArray += "(IsMandatory eq '$IsMandatory')"
        }
    
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'sim/customfields/definitions'
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnSLMCustomFieldDefinitionObjects) {
        Write-Information "Will return SLMCustomFieldDefinitionObjects"
        $SLMCustomFieldDefinitionObjects = @()
        foreach ($resultCustomFieldDefinition in $result) {
            $table = @{}
            $resultCustomFieldDefinition.psobject.properties.name | ForEach-Object { $table.Add($_, $resultCustomFieldDefinition.$_) }
            $SLMCustomFieldDefinitionObjects += New-SLMCustomFieldDefinitionObject @table
        }
        
        return $SLMCustomFieldDefinitionObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result
}
Function New-SLMCustomFieldValueObject {
    param(
        [String]$type,
        [String]$Name,
        [Int32]$CustomFieldId,
        [String]$DataType,
        [String]$ElementId,
        [String]$Value,
        [nullable[datetime]]$UpdatedDate
    )

    $SLMCustomFieldValueObject = New-Object -TypeName SLMCustomFieldValueObject -Property $PSBoundParameters

    return $SLMCustomFieldValueObject


}
Function Get-SLMCustomFieldValues {
    param(
        
        [Int32]
        $CustomFieldId,

        [String]
        $ElementId,

        [String]
        $Value,

        [nullable[datetime]]
        $UpdatedDate

    )

}
#endregion
#region Application functions
Function New-SLMApplicationObject {
    param(
        [Guid]$Id,
        [String]$Name,
        [Guid]$ManufacturerId,
        [String]$ManufacturerName,
        [String]$ManufacturerWebsite,
        [String]$LanguageName,
        [nullable[datetime]]$ReleaseDate,
        [nullable[datetime]]$CreatedDate,
        [String]$CreatedBy,
        [nullable[datetime]]$UpdatedDate,
        [String]$UpdatedBy,
        [String]$Description,
        [String]$SystemOwnerName,
        [String]$SystemOwnerPhone,
        [String]$SystemOwnerEmail,
        [String]$Media,
        [Boolean]$IsOperatingSystem,
        [String]$OperatingSystemType,
        [String[]]$ApplicationTypes,
        [String[]]$UpgradeOptions,
        [String[]]$DowngradeOptions,
        [Int32]$TotalCoverage,
        [Boolean]$LicenseRequired,
        [Int32]$LicenseRequirement,
        [Int32]$LicenseCount,
        [Int32]$InstallationCount,
        [Int32]$BundleInstallationCount,
        [Int32]$UnusedInstallationCount,
        [decimal]$UsageFactor,
        [Int32]$UserCount,
        [Decimal]$Risk,
        [Decimal]$RiskUnused,
        [Int32]$Compliance,
        [String]$Allocation,
        [String]$LicenseKeys,
        [String]$Metric,
        [Decimal]$ApplicationCostTotal,
        [Decimal]$ApplicationCostPerLicense,
        [Decimal]$AverageCostPerLicense,
        [Decimal]$LicenseCostTotal,
        [String]$LicenseCostCurrency,
        [Decimal]$UserLicenseCost,
        [Boolean]$AlertOnOverlicensing,
        [Boolean]$AlertOnUnderlicensing,
        [Boolean]$AlertWhenNotUsed,
        $CustomValues,
        [Boolean]$SecondaryUseAllowed,
        [Nullable[Boolean]]$MultipleVersionsAllowed,
        [Nullable[Boolean]]$MultipleEditionsAllowed
    )

    
    [SLMCustomFieldValueObject[]]$PSBoundParameters.CustomValues = ConvertTo-CustomFieldValueObject -CustomValues $CustomValues -TargeType SLMCustomFieldValueObject
    $SLMApplication = New-Object -TypeName SLMApplicationObject -Property $PSBoundParameters

    return $SLMApplication

}
Function Get-SLMApplications {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [guid]
        $Id,

        [string]
        $Name,

        [string]
        $filter,

        [switch]
        $ReturnSLMApplicationObjects,

        [switch]
        $IncludeApplicationDetails #TODO include details for all applications
    )

    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()
    

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($Id) {
            $filterArray += "(Id eq guid'$Id')"
        }

        if ($Name) {
            $filterArray += "(Name eq '$Name')"
        }    
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'applications'
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnSLMApplicationObjects) {
        Write-Information "Will return SLMApplicationObjects"
        $SLMApplicationObjects = @()
        foreach ($resultApplication in $result) {
            $table = @{}
            $resultApplication.psobject.properties.name | ForEach-Object { $table.Add($_, $resultApplication.$_) }
            $SLMApplicationObjects += New-SLMApplicationObject @table
        }
        
        return $SLMApplicationObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result

}
Function Get-SLMApplicationDetails {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [guid]
        $Id,

        [string]
        $Name,

        [string]
        $filter,

        [switch]
        $ReturnSLMApplicationObjects
    
    )

    #Work in progress, function not completed
    Write-Warning "Work in progress"

    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()
    

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($Id) {
            $filterArray += "(Id eq guid'$Id')"
        }

        if ($Name) {
            $filterArray += "(Name eq '$Name')"
        }    
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'applications/' + $Id
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnSLMApplicationObjects) {
        Write-Information "Will return SLMApplicationObjects"
        $SLMApplicationObjects = @()
        foreach ($resultApplication in $result) {
            $table = @{}
            $resultApplication.psobject.properties.name | ForEach-Object { $table.Add($_, $resultApplication.$_) }
            $SLMApplicationObjects += New-SLMApplicationObject @table
        }
        
        return $SLMApplicationObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result

}
#endregion
#region License functions
Function Get-SLMLicenseDetails {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [Int32]
        $Id,

        [switch]
        $ReturnAsSLMObject
    
    )

    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'licenses/' + $Id
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnAsSLMObject) {
        Write-Information "Will return SLMLicenseObject"
        $SLMObjects = @()
        foreach ($resultRow in $result) {
            $table = @{}
            $resultRow.psobject.properties.name | ForEach-Object { $table.Add($_, $resultRow.$_) }
            $SLMObjects += New-SLMLicenseObject @table
        }
        
        return $SLMObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result

}
#Id	ApplicationName	ManufacturerName	Metric	AssignmentType	PurchaseDate	Quantity	IsIncomplete
Function Get-SLMLicenses {
    [CmdletBinding()]
    param(
        [hashtable]
        $SLMApiEndpointConfiguration,
        
        [Int32]
        $Id,

        [string]
        $ApplicationName,

        [string]
        $ManufacturerName,

        # [string]
        # $Metric,

        # [string]
        # $AssignmentType,

        # [string]
        # $PurchaseDate,

        
        # [string]
        # $Quantity,


        # [string]
        # $IsIncomplete,        
        
        # [string]
        # $UpdatedDate,        

        # [string]
        # $UpdatedBy,        

        [string]
        $filter,

        [switch]
        $ReturnAsSLMObject,

        [switch]
        $IncludeDetails #TODO include details for all licenses
    )

    #Remove the reference of the variable to the original parameter.
    $SLMApiEndpointConfiguration = $SLMApiEndpointConfiguration.Clone()
    

    #If filter is empty, build filterArray
    if ([string]::IsNullOrEmpty($filter)) {

        $filterArray = @()

        if ($Id) {
            $filterArray += "(Id eq $Id)"
        }

        if ($ApplicationName) {
            $filterArray += "(ApplicationName eq '$ApplicationName')"
        }
        
        if ($ManufacturerName) {
            $filterArray += "(ManufacturerName eq '$ManufacturerName')"
        }    
    }

    #Inform that if we have a filter, it will override all other parameters
    if ($filter) {
        Write-Information "Filter is set, all other parameters will be ignored."
    }

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $SLMApiEndpointConfiguration.SLMEndpointPath = 'licenses'
    $SLMApiEndpointConfiguration.filter = ''

    if ($filter) {
        $SLMApiEndpointConfiguration.filter = $filter
        Write-Information "Filter will be used: [$filter]"
    }

    $result = Get-SLMApiEndpoint @SLMApiEndpointConfiguration

    if ($ReturnAsSLMObject) {
        Write-Information "Will return SLMLicenseObject"
        $SLMObjects = @()
        foreach ($resultRow in $result) {
            $table = @{}
            $resultRow.psobject.properties.name | ForEach-Object { $table.Add($_, $resultRow.$_) }
            $SLMObjects += New-SLMLicenseObject @table
        }
        
        return $SLMObjects

    }
    Write-Information "Will return data in format: $($SLMApiEndpointConfiguration.format)"
    return $result

}
Function New-SLMLicenseObject {
    param(
        [Int32]$Id,
        [String]$ApplicationName,
        [String]$ManufacturerName,
        [String]$Metric,
        [ValidateSet('Organisation', 'Computer/datacenter', 'User', 'Site')]
        [String]$AssignmentType,
        [nullable[datetime]]$UpdatedDate,
        [String]$UpdatedBy,
        [nullable[Boolean]]$AutomaticDowngrade,
        [nullable[Boolean]]$UpgradeRights,
        [String]$InvoiceReference,
        [nullable[datetime]]$PurchaseDate,
        [nullable[decimal]]$PurchasePrice,
        [String]$PurchaseCurrency,
        [Int32]$Quantity,
        [String]$Vendor,
        [String]$ExternalId,
        [String]$InstallationMedia,
        [String]$LicenseProofLocation,
        [String]$LicenseKeys,
        [String]$Notes,
        [nullable[Boolean]]$IsIncomplete,
        $CustomFields,
        [object[]]$Allocations,
        [String]$LegalOrganisation
    )
    [SLMCustomFieldValueObject[]]$PSBoundParameters.CustomFields = ConvertTo-CustomFieldValueObject -CustomValues $CustomFields -TargeType SLMCustomFieldValueObject
    $SLMObject = New-Object -TypeName SLMLicenseObject -Property $PSBoundParameters

    return $SLMObject

}
Function New-ImportToolLicenseConfigurationXML {
    
}
#endregion

#region SLM Import Functions
Function New-SLMImport {
    [CmdletBinding()]
    param(
        $ImportObjects,
        $LicenseDirectoryPath,
        [switch]$Append,
        $Encoding,
        [switch]$IncludeInvalid,
        [String]$Label
    )

    [String]$Prefix = Get-Date -Format FileDateTime
    if (-not [string]::IsNullOrEmpty($Label)) { $Prefix = $Prefix + '_' + $Label }
    $Prefix = $Prefix + '_'

    $SLMImportObjects = @()

    foreach ($ImportObject in $ImportObjects) {

        if ($ImportObject.SLMObjectType -notin [Enum]::GetNames([slmobjectTypes])) {
            Write-Information "Object is not an SLMObject, skipping. Skipped object: $SLMObject"
            continue
        }

        if ($ImportObject.Validate() -or $IncludeInvalid) {
            $SLMImportObjects += $ImportObject 
        }
    }

    if ($SLMImportObjects.SLMObject.Count -gt 0) {

        $licenses = Where-Object -InputObject $SLMImportObjects -FilterScript { $_.SLMObjectType -eq 'SLMLicenseObject' }
        $licenses.SLMObject | Export-Excel -Path "$LicenseDirectoryPath\$($Prefix)License.xlsx" -Append:$Append

    }

}
Function New-SLMImportObjects {
    [CmdletBinding()]
    param(
        $SLMObjects,
        [nullable[boolean]]$DisableAutoEditing
    )
    $ImportObjects = @()

    foreach ($SLMObject in $SLMObjects) {
        if ($SLMObject.GetType().Name -notin [Enum]::GetNames([slmobjectTypes])) {
            Write-Information "Object is not an SLMObject, skipping. Skipped object: $SLMObject"
            continue
        }
        $ImportTable = @{
            SLMObjectType      = [SLMObjectTypes]"$($SLMObject.GetType().Name)"
            SLMObject          = $SLMObject
            DisableAutoEditing = $DisableAutoEditing
        }

        $ImportObjects += New-Object -TypeName SLMImportObject -Property $ImportTable
    }

    if ($SLMObjects.Count -ne $ImportObjects.Count) {
        Write-Warning "Some objects skipped, $($importobject.Count) ImportObjects created from $($SLMObjects.Count) SLMObjects."
    }

    return $ImportObjects

}
#endregion