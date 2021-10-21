function Set-Shortcut {
    <#
        .SYNOPSIS
        Create a new Windows shortcut (.lnk file)

        .EXAMPLE
        New-Shortcut -Source 'C:\Program Files\PuTTY\pageant.exe' -Destination pageant.lnk -StartIn 'C:\Program Files\PuTTY\'
    #>
    param (
        # Source path
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            if (-not (Test-Path -Path $_) ){
                throw "$_ does not exist"
            }
            return $true
        })]
        [string]
        $Source,
        # Destination path
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            if (-not ($_.EndsWith('.lnk') -or $_.EndsWith('.url'))) {
                throw "The destination path must end with .lnk or .url"
            }
            return $true
        })]
        [string]
        $Destination,
        # Shortcut arguments
        [Parameter()]
        [string]
        $Arguments,
        # Working directory of the shortcut
        [Parameter()]
        [ValidateScript({
            if (-not (Test-Path -Path $_ -PathType Container) ){
                throw "$_ does not exist or is not a directory"
            }
            return $true
        })]
        [string]
        $StartIn,
        # Shortcut key
        [Parameter()]
        [string]
        $Hotkey,
        # Window style
        [Parameter()]
        [ValidateSet('Normal', 'Minimized', 'Maximized')]
        [string]
        $WindowStyle,
        # Shortcut comment
        [Parameter()]
        [string]
        $Comment
    )

    $WshShell = New-Object -ComObject WScript.Shell
    $WshShell.CurrentDirectory = $PWD.Path

    $Shortcut = $WshShell.CreateShortcut($Destination)
    $Shortcut.TargetPath = $Source
    if ($Arguments) {
        $Shortcut.Arguments = $Arguments
    }
    if ($StartIn) {
        $Shortcut.WorkingDirectory = $StartIn
    }
    if ($Hotkey) {
        $Shortcut.Hotkey = $Hotkey
    }
    switch ($WindowStyle) {
        'Normal' { $Shortcut.WindowStyle = 4 }
        'Minimized' { $Shortcut.WindowStyle = 7 }
        'Maximized' { $Shortcut.WindowStyle = 3 }
    }
    if ($Comment) {
        $Shortcut.Description = $Comment
    }

    $Shortcut.Save()
}
