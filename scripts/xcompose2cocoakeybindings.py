#!/usr/bin/env python3
"""Convert a .XCompose file to a Cocoa keybindings dict file."""

import argparse
from collections import OrderedDict
from dataclasses import dataclass
from io import StringIO
from os.path import expanduser, isfile
import re
import sys
from typing import Dict, Generator, List, Optional, TextIO


KEY_MAP = {
    'multi_key': '§',
    'bracketleft': '[',
    'bracketright': ']',
    'parenleft': '(',
    'parenright': ')',
    'period': '.',
    'minus': '-',
    'plus': '+',
    'dollar': '\\$',  # $ is used for Shift and needs to be escaped
    '$': '\\$',  # $ is used for Shift and needs to be escaped
    'at': '\\@',  # @ is used for Command and needs to be escaped
    '@': '\\@',  # @ is used for Command and needs to be escaped
    'exclam': '!',
    'less': '<',
    'greater': '>',
    'slash': '/',
    'backslash': '\\\\',
    'question': '?',
    'space': '\\U0020',
    'equal': '=',
    'asciitilde': '\\~',  # ~ is used for Option and needs to be escaped
    '~': '\\~',  # ~ is used for Option and needs to be escaped
    'numbersign': '\\#',  # # is used for numpad keys and needs to be escaped
    '#': '\\#',  # # is used for numpad keys and needs to be escaped
    'asterisk': '*',
    'colon': ':',
    'semicolon': ';',
    'percent': '%',
    'underscore': '_',
    'asciicircum': '\\^',  # ^ is used for Control and needs to be escaped
    '^': '\\^',  # ^ is used for Control and needs to be escaped
    'comma': ',',
    'apostrophe': "'",
    'quotedbl': '\\"',
    'bar': '|',
    'grave': '`',
    'ampersand': '&',
    'braceright': '}',
    'braceleft': '{',
    'up': '\\UF700',
    'down': '\\UF701',
    'left': '\\UF702',
    'right': '\\UF703'
}
# VALUE_MAP = {
#     "�": '\\UE007F'
# }
KEY_REGEX = re.compile(r'<(?P<key>[A-Za-z0-9_]+)>')
SYMBOL_REGEX = re.compile(r'"(?P<symbol>.+)"')
COMMENT_REGEX = re.compile(r'# (?P<comment>.+)$')
INDENT_SPACES = 4


@dataclass(frozen=True)
class Entry:
    """XCompose entry data."""

    symbol: str
    comment: Optional[str]
    line: int
    keys: List[str]


class OverlappingEntries(Exception):
    """Raised when two .XCompose entries have overlapping keys."""

    def __init__(self, first: Entry, second: Entry):
        """Initialize the exception."""
        self.first = first
        self.second = second


def parse_xcompose_line(line, line_number) -> Optional[Entry]:
    """Parse a line of a .XCompose file and return an Entry."""
    if line.startswith('#') or \
            line.startswith('include') or \
            line.isspace():
        return None

    keys: List[str] = re.findall(KEY_REGEX, line)
    if len(keys) == 0:
        print(f'Found no key in {line}', file=sys.stderr)
        return None

    symbols: List[str] = re.findall(SYMBOL_REGEX, line)
    if len(symbols) > 1:
        print(f'Found multiple symbols in {line}: {symbols}',
              file=sys.stderr)
        return None
    if len(symbols) == 0:
        print(f'Found no symbol in {line}', file=sys.stderr)
        return None

    symbol = symbols[0]

    comments: List[str] = re.findall(COMMENT_REGEX, line)
    if len(comments) > 1:
        print(f'Found multiple comments in {line}: {comments}',
              file=sys.stderr)
        return None
    comment = comments[0] if len(comments) > 0 else None

    return Entry(symbol, comment, line_number, keys)


def parse_xcompose(fp) -> Dict:
    """Parse a .XCompose file and return a nested key / value dictionnary."""
    entries: Dict = OrderedDict()

    for n, line in enumerate(fp):  # type: int, str
        try:
            entry = parse_xcompose_line(line, n + 1)

            if not entry:
                continue

            last = entries

            for i, key in enumerate(entry.keys):
                if isinstance(last, Entry):
                    raise OverlappingEntries(last, entry)
                if i == len(entry.keys) - 1:
                    break
                if key not in last:
                    last[key] = OrderedDict()
                last = last[key]

            last[key] = entry
        except OverlappingEntries as e:
            print(f'Found overlapping entries: {e.first} and {e.second}',
                  file=sys.stderr)

    return entries


def write_entries(entries: Dict, out: TextIO, indent_level: int)\
        -> Generator[Dict, None, None]:
    """Write the Cocoa keybinding dict."""
    for key, value in entries.items():
        for xcompose_key, keybinding in KEY_MAP.items():
            if key.lower() == xcompose_key.lower():
                key = keybinding
                break
        for _ in range(indent_level):
            print(' ' * INDENT_SPACES, file=out, end='')
        if isinstance(value, dict):
            print(f'"{key}" = {{', file=out)
            for d in write_entries(value, out, indent_level + 1):
                yield d
            for _ in range(indent_level):
                print(' ' * INDENT_SPACES, file=out, end='')
            print('};', file=out)
        elif isinstance(value, Entry):
            print(f'"{key}" = ("insertText:", "{value.symbol}");',
                  file=out, end='')
            if value.comment:
                print(f' /* {value.comment} */', file=out, end='')
            print('', file=out)


def main() -> None:
    """Program entrypoint."""
    parser = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('file',
                        nargs='?',
                        default=expanduser('~/.XCompose'),
                        help='Compose file path')
    args = parser.parse_args()

    if not isfile(args.file):
        print(f'{args.file} does not exist', file=sys.stderr)
        sys.exit(1)

    with open(args.file) as fp:
        entries = parse_xcompose(fp)

    out = StringIO()
    print('{', file=out)
    print(f'{" " * INDENT_SPACES}'
          f'/* The Compose Key: {KEY_MAP["multi_key"]}'
          ' - use Karabiner to bind to Right-Option',
          file=out)
    print(f'{" " * INDENT_SPACES}'
          '   Reference:',
          file=out)
    print(f'{" " * INDENT_SPACES}'
          '     https://github.com/gnarf/osx-compose-key',
          file=out)
    print(f'{" " * INDENT_SPACES}'
          '     https://gist.github.com/gnarf/0d29c05b189a51894399',
          file=out)
    print(f'{" " * INDENT_SPACES}'
          '*/',
          file=out)

    # Go through the generator, we only care about the side effects
    list(write_entries(entries, out, 1))

    print('}', file=out)

    print(out.getvalue(), end='')


if __name__ == '__main__':
    main()
