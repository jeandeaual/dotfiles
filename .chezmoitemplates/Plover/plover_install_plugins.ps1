$PloverConsole = 'plover_console.exe'

if (-not (Get-Command $PloverConsole -ErrorAction SilentlyContinue)) {
    $PloverConsole = ([IO.Path]::Combine(
        (Get-ChildItem -Directory -Path "${env:ProgramFiles}\Open Steno Project" -ErrorAction Stop | Where-Object { $_.Name -like 'Plover*' } | Select-Object -First 1).FullName,
        'plover_console.exe'
    ))

    Get-Command $PloverConsole
}

@(
    'plugins-manager',
    'system-switcher',
    'layout-display',
    'python-dictionary',
    'grandjean'
) | ForEach-Object {
    & $PloverConsole -s plover_plugins install "plover-$_"
}
