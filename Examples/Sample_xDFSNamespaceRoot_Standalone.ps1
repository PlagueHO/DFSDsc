Configuration DFSNamespace_Standalone_Public
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential] $Credential
    )

    Import-DscResource -ModuleName 'xDFS'

    Node $NodeName
    {
        # Install the Prerequisite features first
        # Requires Windows Server 2012 R2 Full install
        WindowsFeature RSATDFSMgmtConInstall 
        { 
            Ensure = "Present" 
            Name = "RSAT-DFS-Mgmt-Con" 
        }

        WindowsFeature DFS
        {
            Name = 'FS-DFS-Namespace'
            Ensure = 'Present'
        }

       # Configure the namespace
        xDFSNamespaceRoot DFSNamespaceRoot_Standalone_Public
        {
            Path                 = '\\fileserver1\public'
            TargetPath           = '\\fileserver1\public'
            Ensure               = 'present'
            Type                 = 'Standalone'
            Description          = 'Standalone DFS namespace for storing public files'
            PsDscRunAsCredential = $Credential
        } # End of DFSNamespaceRoot Resource

       # Configure the namespace folder
        xDFSNamespaceFolder DFSNamespaceFolder_Standalone_PublicBrochures
        {
            Path                 = '\\fileserver1\public\brochures'
            TargetPath           = '\\fileserver2\brochures'
            Ensure               = 'present'
            Description          = 'Standalone DFS namespace for storing public brochure files'
            PsDscRunAsCredential = $Credential
        } # End of DFSNamespaceFolder Resource
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "FILESERVER1"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
        }
    )
}
DFSNamespace_Standalone_Public `
    -configurationData $ConfigData `
    -Credential (Get-Credential -Message "Domain Credentials")
Start-DscConfiguration `
    -Wait `
    -Force `
    -Verbose `
    -ComputerName "FILESERVER1" `
    -Path $PSScriptRoot\DFSNamespace_Standalone_Public `
    -Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
