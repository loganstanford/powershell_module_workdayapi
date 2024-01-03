function Set-WorkdayWorkerCertification {
    <#
    .SYNOPSIS
        Creates or updates a Worker's certification in Workday.
    
    .DESCRIPTION
        Creates or updates a Worker's certification in Workday.
    
    .PARAMETER WorkerId
        The Worker's Id at Workday.
        Type: RoleObject.RoleObjectID
    
    .PARAMETER WorkerType
        The type of ID that the WorkerId represents. Valid values
        are 'WID', 'Contingent_Worker_ID' and 'Employee_ID'.

    .PARAMETER CountryWID
        The WID of the Country in which the Certification is used.
        Type: CountryObject.CountryObjectID.WID
    
    .PARAMETER CertificationName
        The name of the Certification. 
        Type: Certification_Achievement_Data.Certification_Name 
    
    .PARAMETER Issuer
        The authority issuing the certification. 
        Type: Certification_Achievement_Data.Issuer 
    
    .PARAMETER CertificationNumber
        The Certification Number for the Certification.
        Type: Certification_Achievement_Data.Certification_Number 
    
    .PARAMETER IssuedDate
        The date the certification was issued. 
        Type: Certification_Achievement_Data.Issued_Date 
    
    .PARAMETER ExpirationDate
        The date of expiration of the certification. 
        Type: Certification_Achievement_Data.Expiration_Date 
    
    .PARAMETER SpecialtyWID
        The WID of the Specialty to associate with the Certification.
        Type: Specialty_ParentObject.Specialty_ParentObjectID.WID
    
    .PARAMETER SubspecialtyWID
        The WID of the Subspecialty to associate with the Certification.
        Type: Specialty_ChildObject.Specialty_ChildObjectID.WID
    
    .PARAMETER ExistingCertification
        A Certification object from Get-WorkdayWorkerCertification. Use
        when updating a Certification to autofill the parameter values
        that you do not want to update.
    
    .PARAMETER TalentUri
        Talent Endpoint Uri for the request. If not provided, the value
        stored with Set-WorkdayEndpoint -Endpoint Talent is used.
    
    .PARAMETER Username
        Username used to authenticate with Workday. If empty, the value stored
        using Set-WorkdayCredential will be used.
    
    .PARAMETER Password
        Password used to authenticate with Workday. If empty, the value stored
        using Set-WorkdayCredential will be used.
    
    .EXAMPLE
        $ExistingCertification = Get-WorkdayWorkerCertification -WorkerId $WorkerId | Select-Object -First 1
        Set-WorkdayWorkerCertification -WorkerId $WorkerId -ExistingCertification $ExistingCertification -ExpirationDate '2023-12-31'
    
        Updates an existing certification's expiration date to 2023-12-31
    
    .EXAMPLE
        $Certification = @{
            WorkerId =
        }
    #>
        [CmdletBinding()]
        param (
            
            [ValidatePattern ('^[a-fA-F0-9\-]{1,32}$')]
            [string]$WorkerId,
    
            [ValidateSet('WID', 'Contingent_Worker_ID', 'Employee_ID')]
            [string]$WorkerType = 'Employee_ID',
    
            [string]$CertificationReferenceWID,
            [string]$CertificationName,
            [string]$CertificationNumber,
            [string]$Issuer,
            [string]$CountryWID,

            [string]$IssuedDate,
    
            [string]$ExpirationDate,
    
            [string]$SpecialtyWID,
    
            [string]$SubspecialtyWID,
            
            $Documents,
    
            $ExistingCertification,

            [switch]$KeepDocuments,
    
            [string]$TalentUri,
    
            [string]$Username,
    
            [string]$Password
    
        )
    
        if ([string]::IsNullOrWhiteSpace($TalentUri)) { $TalentUri = $WorkdayConfiguration.Endpoints['Talent'] }
        
        if ($ExistingCertification) {

            if ($KeepDocuments) {
                
                foreach ($document in $ExistingCertification.Documents) {
                    $documentXML = @"
<bsvc:Worker_Document_Data>
    <bsvc:File_Name>$($document.File_Name)</bsvc:File_Name>
    <bsvc:Comment>$($document.Comment)</bsvc:Comment>
    <bsvc:File>$($document.File)</bsvc:File>
    <bsvc:Document_Category_Reference bsvc:Descriptor="">
        <bsvc:ID bsvc:type="WID">$($document.Document_Category_Reference)</bsvc:ID>
    </bsvc:Document_Category_Reference>
    <bsvc:Content_Type>$($document.Content_Type)</bsvc:Content_Type>
</bsvc:Worker_Document_Data>
"@
                    $documentsXML += $documentXML
    
                }
            }

            $request = [xml]@"
<bsvc:Manage_Certifications_Request xmlns:bsvc="urn:com.workday/bsvc" bsvc:version="v41.0">
    <bsvc:Business_Process_Parameters>
        <bsvc:Auto_Complete>true</bsvc:Auto_Complete>
        <bsvc:Run_Now>true</bsvc:Run_Now>
    </bsvc:Business_Process_Parameters>
    <bsvc:Manage_Certifications_Data>
        <bsvc:Role_Reference bsvc:Descriptor="">
            <bsvc:ID bsvc:type="Employee_ID"></bsvc:ID>
        </bsvc:Role_Reference>
        <bsvc:Certification>
            <bsvc:Certification_Reference bsvc:Descriptor="">
                <bsvc:ID bsvc:type="WID"></bsvc:ID>
            </bsvc:Certification_Reference>
            <bsvc:Certification_Data>
                <bsvc:Certification_ID></bsvc:Certification_ID>
                <bsvc:Certification_Reference bsvc:Descriptor="">
                    <bsvc:ID bsvc:type="WID"></bsvc:ID>
                </bsvc:Certification_Reference>
                <bsvc:Country_Reference bsvc:Descriptor="">
                    <bsvc:ID bsvc:type="WID"></bsvc:ID>
                </bsvc:Country_Reference>
                <bsvc:Certification_Name></bsvc:Certification_Name>
                <bsvc:Issuer></bsvc:Issuer>
                <bsvc:Certification_Number></bsvc:Certification_Number>
                <bsvc:Issued_Date></bsvc:Issued_Date>
                <bsvc:Expiration_Date></bsvc:Expiration_Date>
                <bsvc:Specialty_Achievement_Data>
                    <bsvc:Specialty_Reference bsvc:Descriptor="">
                        <bsvc:ID bsvc:type="WID"></bsvc:ID>
                    </bsvc:Specialty_Reference>
                    <bsvc:Subspecialty_Reference bsvc:Descriptor="">
                        <bsvc:ID bsvc:type="WID"></bsvc:ID>
                    </bsvc:Subspecialty_Reference>
                </bsvc:Specialty_Achievement_Data>
                $($documentsXML)
            </bsvc:Certification_Data>
        </bsvc:Certification>
    </bsvc:Manage_Certifications_Data>
</bsvc:Manage_Certifications_Request>
"@

        $CertificationNode = $request.Manage_Certifications_Request.Manage_Certifications_Data.Certification
        $SpecialtyNode = $CertificationNode.Certification_Data.Specialty_Achievement_Data
    
        $CertificationNode.Certification_Reference.ID.InnerText = $CertificationWID ? $CertificationWID : $ExistingCertification.Certification_WID
        $CertificationNode.Certification_Data.Certification_ID  = $CertificationID  ? $CertificationID  : $ExistingCertification.Certification_ID
        
        } else {
            $request = [xml]@'
<bsvc:Manage_Certifications_Request xmlns:bsvc="urn:com.workday/bsvc" bsvc:version="v41.0">
    <bsvc:Business_Process_Parameters>
        <bsvc:Auto_Complete>true</bsvc:Auto_Complete>
        <bsvc:Run_Now>true</bsvc:Run_Now>
    </bsvc:Business_Process_Parameters>
    <bsvc:Manage_Certifications_Data>
        <bsvc:Role_Reference bsvc:Descriptor="">
            <bsvc:ID bsvc:type="Employee_ID"></bsvc:ID>
        </bsvc:Role_Reference>
        <bsvc:Certification>
            <bsvc:Certification_Data>
                <bsvc:Certification_Reference bsvc:Descriptor="">
                    <bsvc:ID bsvc:type="WID"></bsvc:ID>
                </bsvc:Certification_Reference>
                <bsvc:Country_Reference bsvc:Descriptor="">
                    <bsvc:ID bsvc:type="WID"></bsvc:ID>
                </bsvc:Country_Reference>
                <bsvc:Certification_Number></bsvc:Certification_Number>
                <bsvc:Issued_Date></bsvc:Issued_Date>
                <bsvc:Expiration_Date></bsvc:Expiration_Date>
                <bsvc:Specialty_Achievement_Data>
                    <bsvc:Specialty_Reference bsvc:Descriptor="">
                        <bsvc:ID bsvc:type="WID"></bsvc:ID>
                    </bsvc:Specialty_Reference>
                    <bsvc:Subspecialty_Reference bsvc:Descriptor="">
                        <bsvc:ID bsvc:type="WID"></bsvc:ID>
                    </bsvc:Subspecialty_Reference>
                </bsvc:Specialty_Achievement_Data>
            </bsvc:Certification_Data>
        </bsvc:Certification>
    </bsvc:Manage_Certifications_Data>
</bsvc:Manage_Certifications_Request>
'@
        }
    
        $request.Manage_Certifications_Request.Manage_Certifications_Data.Role_Reference.ID.InnerText = $WorkerId
        if ($WorkerType -eq 'Contingent_Worker_ID') {
            $request.Manage_Certifications_Request.Manage_Certifications_Data.Role_Reference.ID.type = 'Contingent_Worker_ID'
        } elseif ($WorkerType -eq 'WID') {
            $request.Manage_Certifications_Request.Manage_Certifications_Data.Role_Reference.ID.type = 'WID'
        }
    
        if (!$ExistingCertification) {
            $ExistingCertification = @{
                Certification_ID            = $null
                Certification_WID           = $null
                Certification_Reference_WID = $null
                Certification_Name          = $null
                Certification_Number        = $null
                Issuer                      = $null
                Issued_Date                 = $null
                Expiration_Date             = $null
                Country_WID                 = $null
                Specialty_WID               = $null
                SubSpecialty_WID            = $null
            }
        }

        $CertificationNode = $request.Manage_Certifications_Request.Manage_Certifications_Data.Certification.Certification_Data
        $SpecialtyNode = $CertificationNode.Specialty_Achievement_Data
    
        $CertificationNode.Certification_Reference.ID.InnerText = $CertificationReferenceWID    ? $CertificationReferenceWID    : $ExistingCertification.Certification_Reference_WID
        $CertificationNode.Country_Reference.ID.InnerText       = $CountryWID                   ? $CountryWID                   : $ExistingCertification.Country_WID
        #$CertificationNode.Certification_Name                   = $CertificationName            ? $CertificationName            : $ExistingCertification.Certification_Name
        #$CertificationNode.Issuer                               = $Issuer                       ? $Issuer                       : $ExistingCertification.Issuer
        $CertificationNode.Certification_Number                 = $CertificationNumber          ? $CertificationNumber          : $ExistingCertification.Certification_Number
        $CertificationNode.Issued_Date                          = $IssuedDate                   ? $IssuedDate                   : $ExistingCertification.Issued_Date
        $CertificationNode.Expiration_Date                      = $ExpirationDate               ? $ExpirationDate               : $ExistingCertification.Expiration_Date
        $SpecialtyNode.Specialty_Reference.ID.InnerText         = $SpecialtyWID                 ? $SpecialtyWID                 : $ExistingCertification.Specialty_WID 
        $SpecialtyNode.Subspecialty_Reference.ID.InnerText      = $SubspecialtyWID              ? $SubspecialtyWID              : $ExistingCertification.Subspecialty_WID
    
        Invoke-WorkdayRequest -Request $request -Uri $TalentUri -Username:$Username -Password:$Password | Write-Output
    
    }