#!/bin/sh

set -eu

plover='plover'

if [ -x '/Applications/Plover.app/Contents/MacOS/Plover' ]; then
    plover='/Applications/Plover.app/Contents/MacOS/Plover'
fi

if [ ! "$(command -v "${plover}")" ]; then
    echo "plover not found" 1>&2
    exit 1
fi

for plugin in 'plugins-manager' 'system-switcher' 'layout-display' 'python-dictionary' 'grandjean'; do
    "${plover}" -s plover_plugins install "plover-${plugin}"
done
