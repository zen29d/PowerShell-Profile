Import-Module PSReadLine

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History

# Run terminal as admin
# Install-Module PowerShellGet -Force
# Log out and start terminal as admin
# Update-Module PowerShellGet -Force
# Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
# Set-PSReadLineOption -PredictionSource History

function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_){
            Write-Verbose "Running $_"
            $measure = Measure-Command {. $_}
            "$($measure.TotalSeconds) for $_"
        }
    }    
}

function Admin {Start-Process PowerShell -Verb RunAs}
function Task {(get-scheduledtask).where({$_.state -eq 'running'})}
function Uptime {Get-CimInstance Win32_operatingsystem -ComputerName $env:computername | Select-Object PSComputername,LastBootUpTime,@{Name="Uptime";Expression = {(Get-Date) - $_.LastBootUptime}}}
function IP {Get-NetIPAddress -AddressFamily IPv4 | where-object IPAddress -notmatch "^(169)|(127)" | Sort-Object IPAddress | select InterfaceAlias, IPaddress}
function Download {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$URL
    )
    $temp = Select-String ".*\/(\w+.\w+)" -InputObject $URL
    $FileName = $temp.Matches.groups[1].value
    certutil -urlcache -f $URL $FileName
}
