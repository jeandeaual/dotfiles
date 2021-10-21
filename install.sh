#!/bin/sh

set -e

apply_all=false
install_starship=true

while test $# -gt 0; do
    case "$1" in
        -a|--all)
            apply_all=true
            shift
            ;;
        --without-starship)
            install_starship=false
            shift
            ;;
        *)
            break
            ;;
    esac
done

chezmoi_bin=chezmoi

if [ ! "$(command -v "${chezmoi_bin}")" ]; then
    readonly chezmoi_install_script="https://git.io/chezmoi"
    readonly starship_install_script="https://starship.rs/install.sh"
    readonly bin_dir="${HOME}/.local/bin"
    readonly chezmoi_bin="${bin_dir}/chezmoi"

    if [ "$(command -v curl)" ]; then
        sh -c "$(curl -fsSL "${chezmoi_install_script}")" -- -b "${bin_dir}"
        if [ "${install_starship}" = true ] && [ ! "$(command -v starship)" ]; then
            sh -c "$(curl -fsSL "${starship_install_script}")" -- -b "${bin_dir}" -f
        fi
    elif [ "$(command -v wget)" ]; then
        sh -c "$(wget -qO- "${chezmoi_install_script}")" -- -b "${bin_dir}"
        if [ "${install_starship}" = true ] && [ ! "$(command -v starship)" ]; then
            sh -c "$(wget -qO- "${starship_install_script}")" -- -b "${bin_dir}" -f
        fi
    else
        echo "To install chezmoi, you must have curl or wget installed" >&2
        exit 1
    fi
fi

# POSIX way to get the script directory
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

if [ "${apply_all}" = true ]; then
    exclude=''
else
    exclude='--exclude=encrypted'
fi

# exec: replace current process with chezmoi init
exec "${chezmoi_bin}" init --apply --source="${script_dir}" "${exclude}"
