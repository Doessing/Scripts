# Need to check a local user and set a password expiration notification?
# Change [string]$Username = 'LocalUserToCheck' to match your local user which will be checked.

#LocalUser to Check PasswordExpires
[string]$Username = 'LocalUserToCheck'
#Range in Days before warning
[int]$Range = 14
#Show info messages?
[bool]$Infomessages = $false

#Check if $Username exists
try {
    $UserObj = Get-LocalUser -Name $Username | Select-Object * -ErrorAction Stop
}
catch {
    Write-Host "Username: '$Username' does not exist."
    break
}

#Check if $Username Is Enabled
if (!($UserObj.Enabled)) {
    Write-Host "Username: '$Username' is not Enabled."
    break
}

#Get LocalUser PasswordExpires
$Expiration = $($UserObj).PasswordExpires

#If PasswordExpires = $null then end script
If ($Expiration) {

    #Create BalloonTip
    Add-Type -AssemblyName System.Windows.Forms
    $BalloonTip = New-Object system.windows.forms.notifyicon
    $BalloonTip.visible = $true
    #Balloon Icon
    $BalloonTip.icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\changepk.exe") 

    #Create a Timespan from Todays date to Expiration date
    $Timespan = $(New-TimeSpan -Start $(get-date) -End $Expiration).Days

    #If days are less then $Range give warning
    if ($Timespan -lt $Range -and $Timespan -gt -1 ) {
        #Password will expire in $Timespan Days! Time to change password!
        $BalloonTip.ShowBalloonTip(20000, "Password Expiry Warning!", "$Username Password Expiries in $Timespan Days!", [system.windows.forms.tooltipicon]::Warning)
    }
    #Else just give information
    elseif ($Timespan -gt $Range -and $Timespan -gt -1 -and $Infomessages -eq $true) {
        #Password will expire in $Timespan Days.
        $BalloonTip.ShowBalloonTip(5000, "Password Expiry Information", "$Username Password Expiries in $Timespan Days.", [system.windows.forms.tooltipicon]::None)
    }

}
else {
    $Username = $UserObj.FullName
    Write-Host "No PasswordExpires set for Username: '$Username'."
}
