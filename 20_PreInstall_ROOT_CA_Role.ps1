#####################################################################
# 20_PreInstall_ROOT_CA_Role.ps1
#
#
# Prepare Computer for CA Installation.
#
# Søren Døssing
#####################################################################
<#
.SYNOPSIS
Install a Root Certificate Authority by script.

.DESCRIPTION
Install a Root Certificate Authority by script.
Takes the ADsettings.csv and CAsettings.csv file to configure names of server and certificate.

.EXAMPLE
PS C:\> 20_PreInstall_ROOT_CA_Role.ps1.ps1
#>

#Domain Settings
$Parameters = Import-csv -Delimiter ";" -Path "C:\CA-Silent\CArootsettings.csv"
$ipRegex = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
foreach ($setting in $Parameters)
{
    $newComputerName = $setting.ComputerName
    $DomainName = $setting.DomainName
    $DefaultUserName = $setting.DefaultUserName
    $DefaultPassword= $setting.DefaultPassword
    $NtpServer = Select-String -InputObject $setting.NtpServer -Pattern $ipRegex -AllMatches | Foreach-Object { $_.Matches } | Foreach-Object { $_.Value }
}

# First configure NTP settings, if required Modify -Value
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "NtpServer" -Value $NtpServer
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" -Name "Enabled" -Value 1

# Rename Computer before installing CA
$computerName = $env:COMPUTERNAME   # The current computer name
Rename-Computer -ComputerName $computerName -NewName $newComputerName

# ENABLE Auto login, login user and login password
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername" -Value $DefaultUserName
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $DefaultPassword
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $DomainName

#Setting NEXT PowerShell Script in Install.cmd
$Install_cmd = "C:\CA-Silent\Install_Root_CA.cmd"
$searchString = "20_PreInstall_ROOT_CA_Role.ps1"
$replaceString = "21_Install_ROOT_CA_Role.ps1"
(Get-Content $Install_cmd) | Foreach-Object {
    $_ -replace $searchString, $replaceString
} | Set-Content $Install_cmd

# Ensure that we continue after a reboot
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "CA-Silent" -Value "C:\CA-Silent\Install_Root_CA.cmd" -Force

Start-Sleep -Seconds 60
Restart-Computer -Force

#####################################################################
# FINISH
#####################################################################