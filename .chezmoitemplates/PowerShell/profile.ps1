function Add-Path {
    <#
        .SYNOPSIS
        An example function to display how help should be written.

        .EXAMPLE
        Add-Path "C:\bin"

        This will add the path "C:\bin" to the PATH environment variable.
    #>
    param (
        # The path to add to the PATH environment variable
        [Parameter(Mandatory = $true,
                   ValueFromPipeline)]
        [System.IO.DirectoryInfo]
        $Path
    )

    process {
        $FullPath = $Path.FullName

        if (Test-Path -Path $FullPath) {
{{- if eq .chezmoi.os "windows" }}
            if ($env:Path -notlike "*${FullPath}*") {
                $env:Path += ";${FullPath}"
            }
{{- else }}
            if ($env:PATH -notlike "*${FullPath}*") {
                $env:PATH += ":${FullPath}"
            }
{{- end }}
        }
    }
}

{{ if eq .chezmoi.os "windows" -}}
{{ template "PowerShell/fonts.ps1" . }}

foreach ($path in @("C:\bin", "${env:ProgramFiles}\CMake", "${env:ProgramFiles}\nodejs")) {
    Add-Path $path
}
# Add the Python folder to the path if it's not already there
try { Get-ChildItem -Directory -Path "${env:LocalAppData}\Programs\Python" -ErrorAction Stop | Where-Object {$_.Name -like 'Python*'} | Add-Path } catch {}
# Add the Ruby folder to the path if it's not already there
try { Get-ChildItem -Directory -Path "C:\" -ErrorAction Stop | Where-Object {$_.Name -like 'Ruby*-x64'} | Add-Path } catch {}
# Add the Vim folder to the path if it's not already there
try { Get-ChildItem -Directory -Path "${env:ProgramFiles}\Vim" -ErrorAction Stop | Where-Object {$_.Name -like 'vim*'} | Add-Path } catch {}
{{ else -}}
{{ template "PowerShell/admin.ps1" . }}
{{- end }}

# Aliases & functions
#------------------------------------------------------------------------------

if (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Alias vi vim
}

if (Get-Command go -ErrorAction SilentlyContinue) {
    function gor {
        go build -ldflags='-s -w' $args
    }
}

if (Get-Command flac -ErrorAction SilentlyContinue) {
    function flacreencode {
        Get-ChildItem -Path . -Filter *.flac -Recurse | ForEach-Object {
            flac --verify --best --decode-through-errors --preserve-modtime -e -p -f $_
        }
    }
}

{{ template "PowerShell/stdin.ps1" . }}

# Function to relaunch as Admin:
function Relaunch-Admin { Start-Process -Verb RunAs (Get-Process -Id $PID).Path }

# Alias for the function:
Set-Alias pwshadmin Relaunch-Admin

Set-Alias which Get-Command

function ll { Get-ChildItem -Force $args }

# Start PowerShell without displaying the copyright banner
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    function private:pwsh { & pwsh -NoLogo $args }
}

{{- if eq .chezmoi.os "windows" }}
function private:powershell { & powershell -NoLogo $args }
{{- end }}

# Custom functions
#------------------------------------------------------------------------------

function mkcd {
    if (-not (Test-Path -Path $args[0])) {
        mkdir $args[0] > $null
    }
    Set-Location $args[0] -PassThru
}

if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    function chezmoicd {
        Set-Location $(chezmoi source-path)
    }
}

Function Req {
    <#
        .SYNOPSIS
            An example function to display how help should be written.

        .EXAMPLE
            Req -Params @{'Method'='GET'; 'Uri'='https://example.com/example.jpg'; 'OutFile'='example.jpg'}

            This will add the path "C:\bin" to the PATH environment variable.
    #>
    Param(
        [Parameter(Mandatory=$True)]
        [hashtable]$Params,
        [int]$Retries = 3,
        [int]$SecondsDelay = 5
    )

    if (-not $Params.ContainsKey('Method')) {
        $Params['Method'] = 'GET'
    }
    $method = $Params['Method']
    $url = $Params['Uri']

    $cmd = { Write-Host "$method $url...`n" -NoNewline; Invoke-WebRequest @Params }

    $retryCount = 0
    $completed = $false
    $response = $null

    while (-not $completed) {
        try {
            $response = Invoke-Command $cmd -ArgumentList $Params
            if ($response.StatusCode -ne 200) {
                throw "Expecting reponse code 200, was: $($response.StatusCode)"
            }
            $completed = $true
        } catch {
            # New-Item -ItemType Directory -Force -Path C:\logs\
            # "$(Get-Date -Format G): Request to $url failed. $_" | Out-File -FilePath 'C:\logs\myscript.log' -Encoding utf8 -Append
            if ($retrycount -ge $Retries) {
                Write-Warning "Request to $url failed the maximum number of $retryCount times.`n"
                throw
            } else {
                Write-Warning "Request to $url failed. Retrying in $SecondsDelay seconds.`n"
                Start-Sleep $SecondsDelay
                $retrycount++
            }
        }
    }

    Write-Host "OK ($($response.StatusCode))"

    return $response
}

# Python
function activate {
{{- if eq .chezmoi.os "windows" }}
    .\venv\Scripts\Activate.ps1
{{- else }}
    .\venv\bin\Activate.ps1
{{- end }}
}

# Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
} else {
    function global:prompt {
        $userChar = '$'
        # https://fishshell.com/docs/current/cmds/fish_is_root_user.html
        if (Test-Admin) {
            $userChar = '#'
        }
{{- if eq .chezmoi.os "windows" }}
        $username = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name.Split('\')[1]
{{- else }}
        $username = $(whoami)
{{- end }}
        $path = switch -Wildcard ($executionContext.SessionState.Path.CurrentLocation.Path) {
            "$HOME" { "~" }
            "$HOME{{ if eq .chezmoi.os "windows" }}\{{ else }}/{{ end }}*" { $executionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, "~") }
            default { $executionContext.SessionState.Path.CurrentLocation.Path }
        }

        Write-Host $username -NoNewLine -ForegroundColor Green
        Write-Host '@' -NoNewLine -ForegroundColor White
        Write-Host ([System.Net.Dns]::GetHostName()) -NoNewLine -ForegroundColor Blue
        Write-Host ' ' -NoNewline
        Write-Host $path -NoNewLine -ForegroundColor Yellow
        Write-Host " $userChar" -NoNewLine

        return ' '
    }
}
