#!/bin/bash

set -euo pipefail

readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readonly TARGETS=(
    "${HOME}/.vim"
    "${HOME}/.config/nvim"
)
readonly FILES=(
    "${DIR}/_vimrc"
    "${DIR}/plugins.toml"
    "${DIR}/plugins_lazy.toml"
)
readonly FOLDERS=(
    "${DIR}/after"
    "${DIR}/colors"
    "${DIR}/ftdetect"
    "${DIR}/keymap"
    "${DIR}/local"
    "${DIR}/spell"
    "${DIR}/syntax"
)
readonly TO_DELETE=(
    "${HOME}/.vimrc"
    "${HOME}/.gvimrc"
    "${HOME}/.exrc"
)

# Check if the files and folders to symlink exist
for file in "${FILES[@]}"; do
    if [[ ! -f "${file}" ]]; then
        echo "${file} not found" 1>&2
        exit 1
    fi
done

for folder in "${FOLDERS[@]}"; do
    if [[ ! -d "${folder}" ]]; then
        echo "${folder} not found" 1>&2
        exit 1
    fi
done

# Create the target directories if they don't exist
for target in "${TARGETS[@]}"; do
    if [[ ! -d "${target}" ]]; then
        echo "Creating ${target}..."
        mkdir -p "${target}"
    fi
done

for file in "${FILES[@]}"; do
    for target in "${TARGETS[@]}"; do
        if [[ $file == *"vimrc"* ]]; then
            if [[ $target == *"nvim"* ]]; then
                targetfile="${target}/init.vim"
            else
                targetfile="${target}/vimrc"
            fi
        else
            targetfile="${target}/${file##*/}"
        fi

        # Cleanup
        if [[ -L "${targetfile}" ]]; then
            if [[ -f "${targetfile}" ]]; then
                # symlink pointing to an existing file
                echo "${targetfile} is already set"
                continue
            else
                # symlink pointing to a non-existing file
                echo "Deleting symlink ${targetfile}..."
                rm -fv "${targetfile}"
            fi
        elif [[ -f "${targetfile}" ]]; then
            echo "Deleting file ${targetfile}..."
            rm -fv "${targetfile}"
        elif [[ -d "${targetfile}" ]]; then
            echo "Deleting folder ${targetfile}..."
            rm -rfv "${targetfile}"
        fi

        # Symlink
        ln -sv "${file}" "${targetfile}"
    done
done

for folder in "${FOLDERS[@]}"; do
    for target in "${TARGETS[@]}"; do
        targetfolder="${target}/${folder##*/}"

        # Cleanup
        if [[ -L "${targetfolder}" ]]; then
            if [[ -d "${targetfolder}" ]]; then
                # symlink pointing to an existing folder
                echo "${targetfolder} is already set"
                continue
            else
                # symlink pointing to a non-existing folder
                echo "Deleting symlink ${targetfolder}..."
                rm -fv "${targetfolder}"
            fi
        elif [[ -f "${targetfolder}" ]]; then
            echo "Deleting file ${targetfolder}..."
            rm -fv "${targetfolder}"
        elif [[ -d "${targetfolder}" ]]; then
            echo "Deleting folder ${targetfolder}..."
            rm -rfv "${targetfolder}"
        fi

        # Symlink
        ln -sv "${folder}" "${targetfolder}"
    done
done

for to_delete in "${TO_DELETE[@]}"; do
    if [[ -f "${to_delete}" ]]; then
        rm -fv "${to_delete}"
    fi
done
