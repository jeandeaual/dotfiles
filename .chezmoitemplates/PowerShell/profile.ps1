{{ if eq .chezmoi.os "windows" -}}
{{ template "PowerShell/fonts.ps1" }}
{{- end }}

# Aliases
#------------------------------------------------------------------------------

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

# Custom functions
#------------------------------------------------------------------------------

function mkcd {
    if (!(Test-Path -Path $args[0])) {
        mkdir $args[0] > $null
    }
    Set-Location $args[0] -PassThru
}

if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    function chezmoicd {
        Set-Location $(chezmoi source-path)
    }
}
