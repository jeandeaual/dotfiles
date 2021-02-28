function Test-Symlink([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

if (-not (Test-Path Env:UserProfile)) {
        Write-Error "The %USERPROFILE% environment variable is not set"
        Exit
}

if (-not (Test-Path Env:LocalAppData)) {
        Write-Error "The %LOCALAPPDATA% environment variable is not set"
        Exit
}

Set-Variable dir -Option Constant -Value (Get-Item -Path ".\" -Verbose).FullName

Set-Variable targets -Option Constant -Value @(
    "$Env:UserProfile\vimfiles"
    "$Env:LocalAppData\nvim"
)

Set-Variable files -Option Constant -Value @(
    "$dir\_vimrc"
    "$dir\plugins.toml"
    "$dir\plugins_lazy.toml"
)

Set-Variable folders -Option Constant -Value @(
    "$dir\after"
    "$dir\colors"
    "$dir\ftdetect"
    "$dir\keymap"
    "$dir\local"
    "$dir\spell"
    "$dir\syntax"
)
Set-Variable toDelete -Option Constant -Value @(
    "$Env:UserProfile\_vimrc"
    "$Env:UserProfile\_gvimrc"
    "$Env:UserProfile\_exrc"
)

# Check if the files and folders to symlink exist
foreach ($file in $files) {
    if (!(Test-Path -Path $file)) {
        Write-Error "$file doesn't exist"
        Exit
    }
}

foreach ($folder in $folders) {
    if (!(Test-Path -Path $folder)) {
        Write-Error "$folder doesn't exist"
        Exit
    }
}

# Create the target directories if they don't exist
foreach ($target in $targets) {
    if (!(Test-Path -Path $target)) {
        Write-Output "Creating directory $target"
        New-Item -ItemType directory -Path $target | Out-Null
    }
}

# To create a symbolic link under Windows 10 (Powershell 5.0):
#
# New-Item -Path C:\LinkFileOrDir -ItemType SymbolicLink -Value D:\RealFileOrDir
#
# Otherwise, we need to use the "mklink" utility, which is only available
# through cmd.exe:
#
# cmd /c mklink C:\LinkFile D:\RealFile
# cmd /c mklink /d C:\LinkDir D:\RealDir

foreach ($file in $files) {
    foreach ($target in $targets) {
        if ($file -Like '*vimrc*') {
            if ($target -Like '*nvim*') {
                $targetFile = $target + "\init.vim"
            } else {
                $targetFile = $target + "\vimrc"
            }
        } else {
            $targetFile = $target + "\" + (Split-Path $file -Leaf)
        }

        # Check if the file already exists
        if (Test-Path -Path $targetFile) {
            if (Test-Symlink($targetFile)) {
                Write-Output "$targetFile already exists and is a symlink"
                continue
            } else {
                Remove-Item -Path $targetFile -Recurse
            }
        }

        # if ($PSVersionTable.PSVersion.Major -ge 5) {
        #     # This apparently requires admin privileges
        #     New-Item -Path $targetFile -ItemType SymbolicLink -Value $file
        # } else {
        #     cmd /c mklink $targetFile $file
        # }
        cmd /c mklink $targetFile $file
    }
}

foreach ($folder in $folders) {
    foreach ($target in $targets) {
        $targetFolder = $target + "\" + (Split-Path $folder -Leaf)

        # Check if the file already exists
        if (Test-Path -Path $targetFolder) {
            if (Test-Symlink($targetFolder)) {
                Write-Output "$targetFolder already exists and is a symlink"
                continue
            } else {
                Remove-Item -Path $targetFolder -Recurse
            }
        }

        # if ($PSVersionTable.PSVersion.Major -ge 5) {
        #     # This apparently requires admin privileges
        #     New-Item -Path $targetFolder -ItemType SymbolicLink -Value $folder
        # } else {
        #     cmd /c mklink /d $targetFolder $folder
        # }
        cmd /c mklink /d $targetFolder $folder
    }
}

foreach ($file in $toDelete) {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file
    }
}
