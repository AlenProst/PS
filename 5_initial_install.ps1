########################################
########INITIAL INSTALL ###########
#####################################

#Shortcuts for Powershell

$SourceFilePath = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
$ShortcutPath = "$($env:USERPROFILE)\Desktop\PowerShell.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save()


#SHOW FILE EXTENTIONS SCRIPT:
Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
    Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.

#Activate Hidden Files
$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Value = 1
Set-ItemProperty -Path $Path -Name Hidden -Value $Value
$Shell = New-Object -ComObject Shell.Application
$Shell.Windows() | ForEach-Object { $_.Refresh() }
