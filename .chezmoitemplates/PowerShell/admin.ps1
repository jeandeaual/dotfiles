function Test-Administrator {
    <#
        .SYNOPSIS
        Check if the user is an administrator
    #>
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
