function Get-WorkdayWorkerCertification {
<#
.SYNOPSIS
    Gets a worker's certifications as Workday XML.

.DESCRIPTION
    Gets a worker's certifications as Workday XML.

.PARAMETER WorkerId
    The Worker's Id at Workday.

.PARAMETER WorkerType
    The type of ID that the WorkerId represents. Valid values
    are 'WID', 'Contingent_Worker_ID' and 'Employee_ID'.

.PARAMETER Human_ResourcesUri
    Human_Resources Endpoint Uri for the request. If not provided, the value
    stored with Set-WorkdayEndpoint -Endpoint Human_Resources is used.

.PARAMETER Username
    Username used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.PARAMETER Password
    Password used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position=0,
            ParameterSetName='Search')]
		[ValidatePattern ('^[a-fA-F0-9\-]{1,32}$')]
		[string]$WorkerId,
        [Parameter(ParameterSetName="Search")]
		[ValidateSet('WID', 'Contingent_Worker_ID', 'Employee_ID')]
		[string]$WorkerType = 'Employee_ID',
        [Parameter(ParameterSetName="Search")]
		[string]$Human_ResourcesUri,
        [Parameter(ParameterSetName="Search")]
		[string]$Username,
        [Parameter(ParameterSetName="Search")]
		[string]$Password,
        [Parameter(ParameterSetName="NoSearch")]
        [xml]$WorkerXml,
        [Alias("Force")]
        [switch]$IncludeInactive
    )

    if ([string]::IsNullOrWhiteSpace($Human_ResourcesUri)) { $Human_ResourcesUri = $WorkdayConfiguration.Endpoints['Human_Resources'] }

    if ($PsCmdlet.ParameterSetName -eq 'Search') {
        $response = Get-WorkdayWorker -WorkerId $WorkerId -WorkerType $WorkerType -IncludeQualifications -IncludeDocuments -Passthru -Human_ResourcesUri $Human_ResourcesUri -Username:$Username -Password:$Password -IncludeInactive:$IncludeInactive -ErrorAction Stop
        $WorkerXml = $response.Xml
    }

    if ($null -eq $WorkerXml) {
        Write-Warning 'Unable to get Qualification data, Worker not found.'
        return
    }

    $certificationTemplate = [pscustomobject][ordered]@{
        Certification_ID            = $null
        Certification_WID           = $null
        Certification_Reference_ID  = $null
        Certification_Reference_WID = $null
        Certification_Name          = $null
        Certification_Number        = $null
        Issuer                      = $null
        Issued_Date                 = $null
        Expiration_Date             = $null
        Country_WID                 = $null
        Specialty_WID               = $null
        Specialty_ID                = $null
        SubSpecialty_WID            = $null
        SubSpecialty_ID             = $null
        Documents                   = @()
    }

    $documentTemplate = [PSCustomObject]@{
        File_Name                   = $null
        Comment                     = $null
        File                        = $null
        Document_Category_Reference = $null
        Content_Type                = $null
    }

    
    $WorkerXml.GetElementsByTagName('wd:Certification') | ForEach-Object {
        $o = $certificationTemplate.PsObject.Copy()
        $o.Certification_ID = $_.SelectSingleNode('wd:Certification_Reference/wd:ID[@wd:type="Certification_Skill_ID"]', $NM).InnerText
        $o.Certification_WID = $_.SelectSingleNode('wd:Certification_Reference/wd:ID[@wd:type="WID"]', $NM).InnerText
        $o.Certification_Reference_ID = $_.SelectSingleNode('wd:Certification_Data/wd:Certification_Reference/wd:ID[@wd:type="Certification_ID"]', $NM).InnerText
        $o.Certification_Reference_WID = $_.SelectSingleNode('wd:Certification_Data/wd:Certification_Reference/wd:ID[@wd:type="WID"]', $NM).InnerText
        $o.Certification_Name = $_.SelectSingleNode('wd:Certification_Data/wd:Certification_Name', $NM).InnerText
        $o.Issuer = $_.SelectSingleNode('wd:Certification_Data/wd:Issuer', $NM).InnerText
        $o.Certification_Number = $_.SelectSingleNode('wd:Certification_Data/wd:Certification_Number', $NM).InnerText
        $o.Issued_Date = $_.SelectSingleNode('wd:Certification_Data/wd:Issued_Date', $NM).InnerText
        $o.Expiration_Date = $_.SelectSingleNode('wd:Certification_Data/wd:Expiration_Date', $NM).InnerText
        $o.Issued_Date = $_.SelectSingleNode('wd:Certification_Data/wd:Issued_Date', $NM).InnerText
        $o.Specialty_ID = $_.SelectSingleNode('wd:Certification_Data/wd:Specialty_Achievement_Data/wd:Specialty_Reference/wd:ID[@wd:type="Specialty_ID"]', $NM).InnerText
        $o.Specialty_WID = $_.SelectSingleNode('wd:Certification_Data/wd:Specialty_Achievement_Data/wd:Specialty_Reference/wd:ID[@wd:type="WID"]', $NM).InnerText
        $o.SubSpecialty_ID = $_.SelectSingleNode('wd:Certification_Data/wd:Specialty_Achievement_Data/wd:Subspecialty_Reference/wd:ID[@wd:type="Subspecialty_ID"]', $NM).InnerText
        $o.SubSpecialty_WID = $_.SelectSingleNode('wd:Certification_Data/wd:Specialty_Achievement_Data/wd:Subspecialty_Reference/wd:ID[@wd:type="WID"]', $NM).InnerText
        $o.Country_WID = $WorkerXml.Get_Workers_Response.Response_Data.Worker.Worker_Data.Qualification_Data.Certification.Certification_Data.Country_Reference.Id[0].'#text'
        
        foreach ($document in $_.SelectNodes('wd:Certification_Data/wd:Worker_Document_Data', $NM)) {
            $d = $documentTemplate.PsObject.Copy()
            $d.File_Name                    = $document.File_Name
            $d.Comment                      = $document.Comment
            $d.File                         = $document.File
            $d.Document_Category_Reference  = $document.SelectSingleNode('wd:Document_Category_Reference/wd:ID[@wd:type="WID"]', $NM).InnerText
            $d.Content_Type                 = $document.Content_Type
            $o.Documents += $d
        }
        
        Write-Output $o
    }

}

Get-WorkdayWorkerCertification -WorkerId 2000585