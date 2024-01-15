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
    [String]$QuarantineDate
    [String]$QuarantineDeleteDate
    [String]$UpdatedDate
    [String]$UpdatedBy
    [hashtable]$CustomFields
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
    [String]$LastScanDate
    [String]$UpdatedBy
    [String]$UpdatedDate
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
class SLMComputerImportObject {
    [String]$ComputerName
    [String]$BiosSerialNumber	
    [SLMOrganisationObject]$Organisation	
    [String]$PurchaseValue	
    [String]$PurchaseDate	
    [String]$PurchaseCurrency	
    [String]$InvoiceReference	
    [String]$Notes	
    [String]$SecurityCode	
    [String]$Vendor	
    [ValidateSet('YES', 'NO')][String]$DisableAutoEditing	
    [String]$HostComputerName	
    [String]$PVUPerCore
    [hashtable]$CustomFields
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
    [String]$CreatedDate
    [String]$UpdatedBy
    [String]$UpdatedDat
    [String]$Description
    [String]$AgreementPeriod
    [String]$CustomField
    [String]$RestrictedToRole
}
Class SLMLicenseObject {
}
Class SLMApplicationObject {
    [Guid]$Id      #Guid	The id of the application.
    [String]$Name        #String	The name of the application.
    [Guid]$ManufacturerId      #Guid	The id of the application's manufacturer.
    [String]$ManufacturerName        #String	The name of the application's manufacturer.
    [String]$ManufacturerWebsite         #String	The URL of the manufacturer's website.
    [String]$LanguageName        #String	The name of the application's language.
    [DateTime]$ReleaseDate         #DateTime-Nullable	The application's release date.
    [DateTime]$CreatedDate         #DateTime	The date and time at which the application was created.
    [String]$CreatedBy       #String	The name of the user that created the application.
    [DateTime]$UpdatedDate         #DateTime	The date/time at which the application was last updated.
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
    [Boolean]$AlertOnOverlicensing        #Boolean-Nullable	Alert when application is overlicensed (show in overlicensed collection).
    [Boolean]$AlertOnUnderlicensing       #Boolean-Nullable	Alert when application is underlicensed (show in underlicensed collection).
    [Boolean]$AlertWhenNotUsed        #Boolean-Nullable	Alert when application is not used.
    [SLMCustomFieldsObject]$CustomValues        #Array-of-CustomFieldValue	An array of custom values for the application.
    [Boolean]$SecondaryUseAllowed         #Boolean-Nullable	Allow secondary use.
    [Boolean]$MultipleVersionsAllowed         #Boolean-Nullable	Allow multiple versions.
    [Boolean]$MultipleEditionsAllowed         #Boolean-Nullable	Allow multiple editions.
}
Class SLMCustomFieldsObject {
    #https://demo.snowsoftware.com/api/customers/1/sim/customfields/definitions

}
Class SLMCustomFieldDefinitionObject {
    [String]$type
    [Int32]$CustomFieldId
    [Int32]$CategoryId
    [String]$Name
    [String]$Description
    [Int32]$ValueDataTypeId
    [bool]$IsMandatory
    [String]$DefaultValue
    [String]$MultipleChoice
    [String]$CreatedDate
    [String]$UpdatedDate
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
        $global:SLMApiEndpointConfiguration = $splat
    }

    return $splat
}
#endregion

#region Read and Validate objects from SLM 
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
        [String]$LastScanDate,
        [String]$UpdatedBy,
        [String]$UpdatedDate,
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
        Write-Verbose "Will return SLMComputerObjects"
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
        [String]$QuarantineDate,
        [String]$QuarantineDeleteDate,
        [String]$UpdatedDate,
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
        Write-Verbose "Will return ReturnSLMUserObjects"
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
Function Get-SLMOrganisation {
    param(
        $OrgChecksum,
        $Organisation
    )
}
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
        [String]$CreatedDate,
        [String]$UpdatedDate
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
        Write-Verbose "Will return SLMCustomFieldDefinitionObjects"
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
Function New-SLMApplicationObject {
    param(
        [Guid]$Id,
        [String]$Name,
        [Guid]$ManufacturerId,
        [String]$ManufacturerName,
        [String]$ManufacturerWebsite,
        [String]$LanguageName,
        [DateTime]$ReleaseDate,
        [DateTime]$CreatedDate,
        [String]$CreatedBy,
        [DateTime]$UpdatedDate,
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
        [SLMCustomFieldsObject]$CustomValues,
        [Boolean]$SecondaryUseAllowed,
        [Boolean]$MultipleVersionsAllowed,
        [Boolean]$MultipleEditionsAllowed
    )

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
        $ReturnSLMApplicationObjects
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
        Write-Verbose "Will return SLMApplicationObjects"
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

#region SLM Import Functions
Function Export-SLMImportCSV {
    param(
        $ImportObjects
    )
}
Function New-SLMComputerImportObject {
    param(

    )
}
#endregion
