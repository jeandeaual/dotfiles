#!/usr/bin/env python3
"""Convert a .XCompose file to a Cocoa keybindings dict file."""

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from io import StringIO
from pathlib import Path
from re import compile as re_compile, Pattern
from sys import exit, stderr
from typing import Any, Final, Optional, TextIO, Union
from collections.abc import Sequence, Iterator


# Exit codes
EXIT_SUCCESS: Final[int] = 0
EXIT_FILE_NOT_FOUND: Final[int] = 1
EXIT_FILE_FORMAT_ERROR: Final[int] = 2

KEY_MAP: Final[dict[str, str]] = {
    "multi_key": "§",
    "bracketleft": "[",
    "bracketright": "]",
    "parenleft": "(",
    "parenright": ")",
    "period": ".",
    "minus": "-",
    "plus": "+",
    "dollar": r"\\$",  # Used for Shift and needs to be escaped
    "$": r"\\$",  # Used for Shift and needs to be escaped
    "at": r"\\@",  # Used for Command and needs to be escaped
    "@": r"\\@",  # Used for Command and needs to be escaped
    "exclam": "!",
    "less": "<",
    "greater": ">",
    "slash": "/",
    "backslash": r"\134",
    "question": "?",
    "space": " ",
    "equal": "=",
    "asciitilde": r"\\~",  # Used for Option and needs to be escaped
    "~": r"\\~",  # Used for Option and needs to be escaped
    "numbersign": r"\\#",  # # For numpad keys and needs to be escaped
    "#": r"\\#",  # # For numpad keys and needs to be escaped
    "asterisk": "*",
    "colon": ":",
    "semicolon": ";",
    "percent": "%",
    "underscore": "_",
    "asciicircum": r"\\^",  # Used for Control and needs to be escaped
    "^": r"\\^",  # Used for Control and needs to be escaped
    "comma": ",",
    "apostrophe": "'",
    "quotedbl": r"\"",
    "bar": "|",
    "grave": "`",
    "ampersand": "&",
    "braceright": "}",
    "braceleft": "{",
    "up": r"\UF700",
    "down": r"\UF701",
    "left": r"\UF702",
    "right": r"\UF703",
    "delete": r"\UF728",
    "backspace": r"\177",
    "home": r"\UF729",
    "end": r"\UF72B",
    "prior": r"\UF72C",
    "next": r"\UF72D",
    "escape": r"\033",
    "tab": r"\011",
    "iso_left_tab": r"\031",
    "return": r"\015",
    "enter": r"\012",
}
KEY_REGEX: Final[Pattern[str]] = re_compile(r"<(?P<key>[A-Za-z0-9_]+)>")
SYMBOL_REGEX: Final[Pattern[str]] = re_compile(r'"(?P<symbol>.+)"')
COMMENT_REGEX: Final[Pattern[str]] = re_compile(r"# (?P<comment>.+)$")
INDENT_SPACES: Final[int] = 4


@dataclass(frozen=True)
class Entry:
    """XCompose entry data."""

    symbol: str
    comment: Optional[str]
    line: int
    keys: list[str]


EntryDict = dict[str, Any]


class OverlappingEntries(Exception):
    """Raised when two .XCompose entries have overlapping keys."""

    def __init__(self, short: Entry, entries: Union[Entry, Sequence[Entry]]):
        """Initialize the exception."""
        self.short = short
        self.entries = entries


def parse_xcompose_line(line, line_number) -> Optional[Entry]:
    """Parse a line of a .XCompose file and return an Entry."""
    if line.startswith("#") or line.startswith("include") or line.isspace():
        return None

    keys: list[str] = KEY_REGEX.findall(line)
    if len(keys) == 0:
        print(f"Found no key in {line}", file=stderr)
        return None

    symbols: list[str] = SYMBOL_REGEX.findall(line)
    if len(symbols) > 1:
        print(f"Found multiple symbols in {line}: {symbols}", file=stderr)
        return None
    if len(symbols) == 0:
        print(f"Found no symbol in {line}", file=stderr)
        return None

    symbol = symbols[0]

    comments: list[str] = COMMENT_REGEX.findall(line)
    if len(comments) > 1:
        print(f"Found multiple comments in {line}: {comments}", file=stderr)
        return None
    comment = comments[0] if len(comments) > 0 else None

    return Entry(symbol, comment, line_number, keys)


def get_entries(entries: EntryDict) -> Iterator[Entry]:
    """Iterate over all ``Entry`` in an ``EntryDict``."""
    for value in entries.values():
        if isinstance(value, dict):
            yield from get_entries(value)
        elif isinstance(value, Entry):
            yield value


def parse_xcompose(fp) -> tuple[EntryDict, int]:
    """Parse a .XCompose file and return a nested key / value dictionnary."""
    entries: EntryDict = {}
    exit_code: int = EXIT_SUCCESS

    line_number: int
    line: str
    for line_number, line in enumerate(fp, start=1):
        try:
            entry = parse_xcompose_line(line, line_number)

            if not entry:
                continue

            if entry.keys[0].lower() != "multi_key":
                print(
                    f"Entry doesn't start with the compose key: {entry}",
                    file=stderr,
                )
                exit_code = EXIT_FILE_FORMAT_ERROR
                continue

            last = entries

            for i, key in enumerate(entry.keys):
                if isinstance(last, Entry):
                    raise OverlappingEntries(last, entry)
                if i == len(entry.keys) - 1:
                    break
                if key not in last:
                    last[key] = {}
                last = last[key]

            if key in last:
                raise OverlappingEntries(entry, list(get_entries(last[key])))

            last[key] = entry
        except OverlappingEntries as e:
            print(
                f"The following entries can't be accessed due to {e.short}: "
                f"{e.entries}",
                file=stderr,
            )
            exit_code = EXIT_FILE_FORMAT_ERROR

    return entries, exit_code


def write_entries(
    entries: EntryDict, out: TextIO, indent_level: int
) -> Iterator[dict]:
    """Write the Cocoa keybinding dict."""
    key: str
    value: Union[EntryDict, Entry]
    for key, value in entries.items():
        for xcompose_key, keybinding in KEY_MAP.items():
            if key.lower() == xcompose_key.lower():
                key = keybinding
                break
        for _ in range(indent_level):
            print(" " * INDENT_SPACES, file=out, end="")
        if isinstance(value, dict):
            print(f'"{key}" = {{', file=out)
            yield from write_entries(value, out, indent_level + 1)
            for _ in range(indent_level):
                print(" " * INDENT_SPACES, file=out, end="")
            print("};", file=out)
        elif isinstance(value, Entry):
            print(
                f'"{key}" = ("insertText:", "{value.symbol}");',
                file=out,
                end="",
            )
            if value.comment:
                print(f" /* {value.comment} */", file=out, end="")
            print("", file=out)


def main() -> None:
    """Program entrypoint."""
    parser = ArgumentParser(
        description=__doc__.strip(),
        formatter_class=ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "file",
        nargs="?",
        type=Path,
        default=Path.home() / ".XCompose",
        help="Compose file path",
    )
    args = parser.parse_args()

    if not args.file.expanduser().is_file():
        print(f"{args.file.resolve()} does not exist", file=stderr)
        exit(EXIT_FILE_NOT_FOUND)

    with open(args.file, encoding="utf8") as fp:
        entries, exit_code = parse_xcompose(fp)

    out = StringIO()
    print("{", file=out)
    print(
        f'{" " * INDENT_SPACES}'
        f'/* The Compose Key: {KEY_MAP["multi_key"]}'
        " - use Karabiner to bind to Right-Option",
        file=out,
    )
    print(f'{" " * INDENT_SPACES}' "   Reference:", file=out)
    print(
        f'{" " * INDENT_SPACES}'
        "     https://github.com/gnarf/osx-compose-key",
        file=out,
    )
    print(
        f'{" " * INDENT_SPACES}'
        "     https://gist.github.com/gnarf/0d29c05b189a51894399",
        file=out,
    )
    print(f'{" " * INDENT_SPACES}' "*/", file=out)

    # Go through the generator, we only care about the side effects
    list(write_entries(entries, out, 1))

    print("}", file=out)

    print(out.getvalue(), end="")

    exit(exit_code)


if __name__ == "__main__":
    main()
