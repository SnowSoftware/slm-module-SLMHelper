<###################################
    Get-SLMApiEndpoint 
####################################>
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
<###################################
    Get-SLMComputers
####################################>
Function Get-SLMComputers {

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

        [ValidateSet("json", "xml", "html")]
        [string]
        $format = "json",

        [int]
        $ResultLimit,
        
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
        $filter
    )

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

    #Check if we got a filterArray
    if ($filterArray.Count -gt 0) {
        $filter = $filterArray -join " and "
    }

    #Build splatting object
    $params = @{
        SLMUri            = $SLMUri 
        SLMCustomerId     = $SLMCustomerId 
        SLMApiCredentials = $SLMApiCredentials 
        SLMEndpointPath   = 'computers' 
        format            = $format
        CleanupBody       = $true
    }

    if ($filter) {
        $params.Add('filter', $filter)
    }

    $result = Get-SLMApiEndpoint @params

    return $result



}