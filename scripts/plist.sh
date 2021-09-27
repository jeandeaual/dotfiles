#!/bin/sh
# Helper script to modify PList files with chezmoi.
# See the modify_*.plist scripts for usage information.

set -e

_macos_major_version="$(sw_vers -productVersion | cut -d'.' -f 1)"
_tmpfile="$(mktemp)"
# shellcheck disable=SC2064
trap "cat $_tmpfile; rm $_tmpfile" EXIT

pl() {
    if [ $# -ne 3 ]; then
        echo "usage: pl key -type value"
        return 1
    fi
    # Test before setting because plutil _will_ mutate the file
    if [ "$_macos_major_version" -ge 12 ]; then
        _current="$(plutil -extract "$(printf '%s' "$1" | tr ':' '.')" raw "$_tmpfile" 2>/dev/null || :)"
    else
        _current="$(/usr/libexec/PlistBuddy -c "Print :$1" "$_tmpfile" 2>/dev/null || :)"
    fi
    if [ "$_current" != "$3" ]; then
        plutil -replace "$(printf '%s' "$1" | tr ':' '.')" "$2" "$3" "$_tmpfile"
    fi
}

cat <&0 >"$_tmpfile"

if [ ! -s "$_tmpfile" ]; then
    # plutil will error if it encounters an empty file
    if [ "$_macos_major_version" -ge 12 ]; then
        plutil -create binary1 "$_tmpfile"
    else
        echo '{}' | plutil -convert binary1 -o "$_tmpfile" -
    fi
fi
