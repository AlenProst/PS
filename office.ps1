####################################################
####################################################
####### Install Office #############################


[string]$configXML = @'
<Configuration>
  <Add OfficeClientEdition="64" Channel="Monthly">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
    </Product>
  </Add>
    <Updates Enabled="FALSE" Channel="Monthly" />
    <Display Level="None" AcceptEULA="TRUE" />
    <Property Name="AUTOACTIVATE" Value="0" />
    <Logging Level="Standard" Path="**workingFolder**" />
</Configuration>
'@

$configXML | out-file "$($env:USERPROFILE)\Desktop\configXML.xml"

function Get-ODTUri {

    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $url = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117"
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to ODT: $url with error $_."
        Break
    }
    finally {
        $ODTUri = $response.links | Where-Object {$_.outerHTML -like "*click here to download manually*"}
        Write-Output $ODTUri.href
    }
}

Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

$Vendor = "Microsoft"
$Product = "Office 365 x32"
$PackageName = "setup"
$InstallerType = "exe"
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"
$Unattendedxml = 'configXML.xml'
$UnattendedArgs = "/configure $Unattendedxml"
$UnattendedArgs2 = "/download $Unattendedxml"
$URL = $(Get-ODTUri)
$ProgressPreference = 'SilentlyContinue'

Start-Transcript $LogPS

Write-Verbose "Downloading latest version of Office 365 Deployment Tool (ODT)." -Verbose
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile .\officedeploymenttool.exe
Write-Verbose "Read version number from downloaded file" -Verbose
$Version = (Get-Command .\officedeploymenttool.exe).FileVersionInfo.FileVersion

Write-Verbose "If downloaded ODT file is newer, create new sub-directory." -Verbose
if( -Not (Test-Path -Path $Version ) ) {
    New-Item -ItemType directory -Path $Version
    Copy-item ".\$Unattendedxml" -Destination $Version -Force
    .\officedeploymenttool.exe /quiet /extract:.\$Version
    start-sleep -s 5
    Write-Verbose "New folder created $Version" -Verbose
}
else {
    Write-Verbose "Version identical. Skipping folder creation." -Verbose
}

Set-Location $Version

Write-Verbose "Downloading $Vendor $Product via ODT $Version" -Verbose
if (!(Test-Path -Path .\Office\Data\v32.cab)) {
    (Start-Process "setup.exe" -ArgumentList $unattendedArgs2 -Wait -Passthru).ExitCode
}
else {
    Write-Verbose "File exists. Skipping Download." -Verbose
}

Write-Verbose "Starting Installation of $Vendor $Product via ODT $Version" -Verbose
(Start-Process "$PackageName.$InstallerType" $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Customization" -Verbose

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript

#############################################################
##############################################################
#############################################################
