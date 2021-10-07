function Test-Admin {
    <#
        .SYNOPSIS
        Check if the user is an administrator
    #>

{{- if eq . "windows" }}
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
{{- else }}
    # https://fishshell.com/docs/current/cmds/fish_is_root_user.html
    $(whoami) -in @("root", "toor", "Administrator")
{{- end }}
}
