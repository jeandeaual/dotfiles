function Read-FileFromStdin {
    <#
        .SYNOPSIS
        Read a file from stdin

        .EXAMPLE
        $file = Read-FileFromStdin
    #>
    $lines = @()

    while ($line = ([System.Console]::In).ReadLine()) {
        $lines += $line
    }

    if (-not $lines) {
        return $null
    }

    $lines -join [System.Environment]::NewLine
}
