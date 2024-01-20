# SLMHelper PowerShell Module

## Description
Module to help with common basics SLM tasks, queries and automations.

## Use cases

* Reading license information from SLM API
* Creating import files for SLM to update Computers
* and more...

## Functions

* Get-SLMApiEndpoint
* Get-SLMComputers

## Installation

Add the "SLMHelper"-folder to your modules folder, or import directly.

## Examples

How to read SLM Application details for 0001378A-704F-4583-BCB8-2D24E1E720E3

``` powershell
Import-Module "C:\Repos\SnowSoftware Repos\slm-module-SLMHelper\Modules\SLMHelper\SLMHelper.psm1"

if (-not $creds) {
    $creds = Get-Credential
}

$SLMApiEndpointConfiguration = New-SLMApiEndpointConfiguration -SLMUri "https://demo.snowsoftware.com" -SLMCustomerId 1 -SLMApiCredentials $creds -SLMEndpointPath 'users' -CleanupBody -OnlyFirstPage
$SLMapp = Get-SLMApplicationDetails -SLMApiEndpointConfiguration $SLMApiEndpointConfiguration -Id '0001378A-704F-4583-BCB8-2D24E1E720E3' -ReturnSLMApplicationObjects
```

## Repository
This module is maintained in the GitHub Repository found [here](https://github.com/SnowSoftware/slm-module-SLMHelper).  
Please use GitHub issue tracker if you have any issues with the module. 
