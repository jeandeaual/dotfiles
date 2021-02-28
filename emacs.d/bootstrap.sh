#!/bin/bash

set -euo pipefail

readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readonly TARGET="${HOME}/.emacs.d"
readonly FILES=(
    "${DIR}/init.el"
)
readonly FOLDERS=(
    "${DIR}/lisp"
)
readonly TO_DELETE=(
    "${HOME}/.emacs"
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

# Create the target directory if it doesn't exist
if [[ ! -d "${TARGET}" ]]; then
    echo "Creating ${TARGET}..."
    mkdir -p "${TARGET}"
fi

for file in "${FILES[@]}"; do
    targetfile="${TARGET}/${file##*/}"

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

for folder in "${FOLDERS[@]}"; do
    targetfolder="${TARGET}/${folder##*/}"

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

for to_delete in "${TO_DELETE[@]}"; do
    if [[ -f "${to_delete}" ]]; then
        rm -fv "${to_delete}"
    fi
done
