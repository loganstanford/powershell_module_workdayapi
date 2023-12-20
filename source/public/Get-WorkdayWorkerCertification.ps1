function Get-WorkdayWorkerCertification {

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
        $response = Get-WorkdayWorker -WorkerId $WorkerId -WorkerType $WorkerType -IncludeQualifications -Passthru -Human_ResourcesUri $Human_ResourcesUri -Username:$Username -Password:$Password -IncludeInactive:$IncludeInactive -ErrorAction Stop
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
        Specialty_WID               = $null
        Specialty_ID                = $null
        SubSpecialty_WID            = $null
        SubSpecialty_ID             = $null
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
        Write-Output $o
    }

}