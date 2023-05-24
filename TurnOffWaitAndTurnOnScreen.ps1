# Will turn off your screen, Sleeps $seconds and turn it on again.
# Author: Søren Døssing

$seconds = 10


# Turn off screen
try {
    (Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)
}
catch {
    Write-Host "Failed to turn off screen."
    break
}

# Sleep
Start-Sleep -Seconds $seconds

# Turn on screen
try {
    (Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,-1)
}
catch {
    Write-Host "Failed to turn on screen."
    break
}

Write-Host "Done turning off and on"