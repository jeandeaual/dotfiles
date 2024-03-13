#!/bin/sh

set -eu

apply_all=false
install_starship=true
bin_dir="${HOME}/.local/bin"

usage() {
    echo "Usage: $(basename "$0") [-a] [-b|--bin-dir BIN_DIR] [--without-starship] [-h|--help]"
}

while test $# -gt 0; do
    case "$1" in
        -a|--all)
            apply_all=true
            shift
            ;;
        -b|--bin-dir)
            shift
            if [ $# -lt 1 ]; then
                echo "bin_dir not provided" >&2
                usage >&2
                exit 1
            fi
            bin_dir=$1
            shift
            ;;
        --without-starship)
            install_starship=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

chezmoi_bin=chezmoi

# Install chezmoi
if [ ! "$(command -v "${chezmoi_bin}")" ]; then
    readonly chezmoi_install_script="https://get.chezmoi.io"
    chezmoi_bin="${bin_dir}/chezmoi"

    if [ "$(command -v curl)" ]; then
        sh -c "$(curl -fsSL "${chezmoi_install_script}")" -- -b "${bin_dir}"
    elif [ "$(command -v wget)" ]; then
        sh -c "$(wget -qO- "${chezmoi_install_script}")" -- -b "${bin_dir}"
    else
        echo "You must have curl or wget installed to install chezmoi" >&2
        exit 1
    fi
fi

# Install Starship
if [ "${install_starship}" = true ] && [ ! "$(command -v starship)" ]; then
    readonly starship_install_script="https://starship.rs/install.sh"

    if [ ! -d "${bin_dir}" ]; then
        mkdir -p "${bin_dir}"
    fi

    if [ "$(command -v curl)" ]; then
        sh -c "$(curl -fsSL "${starship_install_script}")" -- -b "${bin_dir}" -f
    elif [ "$(command -v wget)" ]; then
        sh -c "$(wget -qO- "${starship_install_script}")" -- -b "${bin_dir}" -f
    else
        echo "You must have curl or wget installed to install Starship" >&2
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
