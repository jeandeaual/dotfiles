{{ template "PowerShell/admin.ps1" }}

function Install-Font {
    <#
        .SYNOPSIS
        Install a font

        .DESCRIPTION
        This function will attempt to install the font by copying it to C:\Windows\Fonts (if run as admin) or
        %LOCALAPPDATA%\Microsoft\Windows\Fonts and then adding it in the registry.

        .EXAMPLE
        Install-Font -FontFile $file
    #>
    param (
        # Path of the font to install
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            if (-not ($_ | Test-Path) ){
                throw "$_ does not exist"
            }
            return $true
        })]
        [System.IO.FileInfo]
        $FontFile
    )

    # Handle relative paths
    if (-not (Test-Path $FontFile.FullName)) {
        $FontFile = [System.IO.FileInfo]([IO.Path]::Combine($PWD.Path, $FontFile))
    }

    # Get the font name from the file's extended attributes
    $ShellObject = New-Object -ComObject Shell.Application
    $Folder = $ShellObject.namespace($FontFile.DirectoryName)
    $Item = $Folder.Items().Item($FontFile.Name)
    $FontName = $Folder.GetDetailsOf($Item, 21)
    switch ($FontFile.Extension) {
        ".ttf" { $FontName = "$FontName (TrueType)" }
        ".otf" { $FontName = "$FontName (OpenType)" }
    }
    if (Test-Administrator) {
        $FontPath = "C:\Windows\Fonts"
        $RegistryPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        $DestPath = [IO.Path]::Combine($FontPath, $FontFile.Name)
        $RegistryEntryData = $FontFile.Name
    } else {
        $FontPath = [IO.Path]::Combine($env:LOCALAPPDATA, "Microsoft", "Windows", "Fonts")
        $RegistryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        $DestPath = [IO.Path]::Combine($FontPath, $FontFile.Name)
        $RegistryEntryData = $DestPath
    }

    if ($FontFile.FullName -ne $DestPath) {
        Write-Host "Copying $($FontFile.FullName) to ${FontPath}... " -NoNewline
        Copy-Item -Path $FontFile.FullName -Destination $DestPath

        # Check if the font is copied over
        If ((Test-Path (Join-Path -Path $FontPath -ChildPath $FontFile.Name))) {
            Write-Host "Success" -Foreground Yellow
        } else {
            Write-Host "Failed" -ForegroundColor Red
            exit 1
        }
    }

    # Check if the font registry entry exists
    If ($null -ne (Get-ItemProperty -Name $FontName -Path $RegistryPath -ErrorAction SilentlyContinue)) {
        # Check if the entry matches the font file name
        If ((Get-ItemPropertyValue -Name $FontName -Path $RegistryPath) -eq $RegistryEntryData) {
            Write-Host "${FontName} is already in the registry"
        } else {
            Remove-ItemProperty -Name $FontName -Path $RegistryPath -Force -ErrorAction Stop
            Write-Host "Adding ${FontName} to the registry (${RegistryPath})... " -NoNewline
            New-ItemProperty -Name $FontName -Path $RegistryPath -PropertyType string -Value $RegistryEntryData -Force -ErrorAction SilentlyContinue | Out-Null
            If ((Get-ItemPropertyValue -Name $FontName -Path $RegistryPath) -eq $RegistryEntryData) {
                Write-Host "Success" -ForegroundColor Yellow
            } else {
                Write-Host "Failed" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Adding ${FontName} to the registry (${RegistryPath})... " -NoNewline
        New-ItemProperty -Name $FontName -Path $RegistryPath -PropertyType string -Value $RegistryEntryData -Force -ErrorAction SilentlyContinue | Out-Null
        If ((Get-ItemPropertyValue -Name $FontName -Path $RegistryPath) -eq $RegistryEntryData) {
            Write-Host "Success" -ForegroundColor Yellow
        } else {
            Write-Host "Failed" -ForegroundColor Red
            exit 1
        }
    }
}
