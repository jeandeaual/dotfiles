<#
    .SYNOPSIS
    Install chezmoi (and optionally starship) and apply the dotfiles.

    .EXAMPLE
    .\install.ps1 -All -BinDir C:\bin -WithoutStarship
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]
    $All,
    [Parameter(Mandatory = $false)]
    [string]
    $BinDir = "~\.local\bin",
    [Parameter(Mandatory = $false)]
    [switch]
    $WithoutStarship
)

$ChezmoiBin = "chezmoi.exe"

# Install chezmoi
if (-not (Get-Command $ChezmoiBin -ErrorAction SilentlyContinue)) {
    $ChezmoiBin = [IO.Path]::Combine($BinDir, "chezmoi.exe")

    "`$params = `"-BinDir $BinDir`"", (Invoke-WebRequest -Uri "https://git.io/chezmoi.ps1").Content | powershell -c -
}

# Install Starship
if ((-not $WithoutStarship) -and (-not (Get-Command "starship.exe" -ErrorAction SilentlyContinue))) {
    if (-not (Test-Path -PathType Container $BinDir)) {
        New-Item -ItemType Directory -Force -Path $BinDir
    }

    $ZipFile = [IO.Path]::Combine($env:Temp, "starship.zip")

    $LatestReleaseReq = Invoke-WebRequest -Uri "https://github.com/starship/starship/releases/latest" -Method Head
    if ($LatestReleaseReq.BaseResponse.ResponseUri -ne $null) {
        # PowerShell 5
        $RedirectUri = $LatestReleaseReq.BaseResponse.ResponseUri.AbsoluteUri
    } elseif ($LatestReleaseReq.BaseResponse.RequestMessage.RequestUri -ne $null) {
        # PowerShell core
        $RedirectUri = $LatestReleaseReq.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    } else {
        Write-Error "Couldn't retrieve the latest Starship release URL" -ErrorAction Stop
    }

    $DownloadUri = ($RedirectUri -Replace "\/tag\/", "/download/") + "/starship-x86_64-pc-windows-msvc.zip"

    Invoke-WebRequest -Uri $DownloadUri -OutFile $ZipFile

	Expand-Archive -LiteralPath $ZipFile -DestinationPath $BinDir

    Remove-Item -Path $ZipFile -Force
}

if ($All) {
    $Exclude = ""
} else {
    $Exclude = "--exclude=encrypted"
}

& $ChezmoiBin init --apply --source="$PSScriptRoot" $Exclude
