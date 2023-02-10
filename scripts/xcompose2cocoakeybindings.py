#!/usr/bin/env python3
"""Convert a .XCompose file to a Cocoa keybindings dict file."""

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from collections import defaultdict
from collections.abc import Generator, Sequence
from dataclasses import dataclass
from io import StringIO
from pathlib import Path
from re import Pattern, compile as re_compile
from sys import exit as sys_exit, stderr
from typing import Any, Final, Optional, TextIO, Union


# Exit codes
EXIT_SUCCESS: Final[int] = 0
EXIT_FILE_NOT_FOUND: Final[int] = 1
EXIT_FILE_FORMAT_ERROR: Final[int] = 2

KEY_MAP: Final[dict[str, str]] = {
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
    "escape": r"\033",
    "tab": r"\011",
    "iso_left_tab": r"\031",
    "return": r"\015",
    "enter": r"\012",
    "backspace": r"\177",
    # Defined in NSEvent.h
    "up": r"\UF700",
    "down": r"\UF701",
    "left": r"\UF702",
    "right": r"\UF703",
    "insert": r"\UF727",
    "delete": r"\UF728",
    "home": r"\UF729",
    "end": r"\UF72B",
    "prior": r"\UF72C",
    "next": r"\UF72D",
    "f1": r"\UF704",
    "f2": r"\UF705",
    "f3": r"\UF706",
    "f4": r"\UF707",
    "f5": r"\UF708",
    "f6": r"\UF709",
    "f7": r"\UF70A",
    "f8": r"\UF70B",
    "f9": r"\UF70C",
    "f10": r"\UF70D",
    "f11": r"\UF70E",
    "f12": r"\UF70F",
    "f13": r"\UF710",
    "f14": r"\UF711",
    "f15": r"\UF712",
    "f16": r"\UF713",
    "f17": r"\UF714",
    "f18": r"\UF715",
    "f19": r"\UF716",
    "f20": r"\UF717",
    "f21": r"\UF718",
    "f22": r"\UF719",
    "f23": r"\UF71A",
    "f24": r"\UF71B",
    "f25": r"\UF71C",
    "f26": r"\UF71D",
    "f27": r"\UF71E",
    "f28": r"\UF71F",
    "f29": r"\UF720",
    "f30": r"\UF721",
    "f31": r"\UF722",
    "f32": r"\UF723",
    "f33": r"\UF724",
    "f34": r"\UF725",
    "f35": r"\UF726",
    "scroll_lock": r"\UF72F",
    "pause": r"\UF730",
    "sys_req": r"\UF731",
    "break": r"\UF732",
    "reset": r"\UF733",
    "menu": r"\UF735",
    "print": r"\UF738",
}
KEY_REGEX: Final[Pattern[str]] = re_compile(r"<(?P<key>[A-Za-z0-9_]+)>")
SYMBOL_REGEX: Final[Pattern[str]] = re_compile(r'"(?P<symbol>.+)"')
COMMENT_REGEX: Final[Pattern[str]] = re_compile(r"#\s*(?P<comment>.+)$")
DEFAULT_INDENT_SPACES: Final[int] = 4
DEFAULT_COMPOSE_KEY: Final[str] = "§"


@dataclass(frozen=True)
class Entry:
    """XCompose entry data."""

    symbol: str
    comment: Optional[str]
    line: int
    keys: list[str]


EntryDict = defaultdict[str, Union[Entry, "EntryDict"]]


class OverlappingEntries(Exception):
    """Raised when two .XCompose entries have overlapping keys."""

    def __init__(self, short: Entry, entries: Union[Entry, Sequence[Entry]]):
        """Initialize the exception."""
        self.short = short
        self.entries = entries


def parse_xcompose_line(line: str, line_number: int) -> Optional[Entry]:
    """Parse aline of a .XCompose file and return an Entry."""
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

    comment_match = COMMENT_REGEX.search(line)
    comment = comment_match.group("comment") if comment_match else None

    return Entry(symbol, comment, line_number, keys)


def get_entries(
    entries: Union[EntryDict, Entry]
) -> Generator[Entry, None, None]:
    """Iterate over all ``Entry`` in an ``EntryDict``."""
    if isinstance(entries, Entry):
        yield entries
        return

    for value in entries.values():
        if isinstance(value, dict):
            yield from get_entries(value)
        elif isinstance(value, Entry):
            yield value


def nested_defaultdict() -> defaultdict[str, Any]:
    """Return a defaultdict using defaultdicts for missing keys."""
    return defaultdict(nested_defaultdict)


def parse_xcompose(file: TextIO) -> tuple[EntryDict, int]:
    """Parse a .XCompose file and return a nested key / value dictionnary."""
    entries: EntryDict = nested_defaultdict()
    exit_code: int = EXIT_SUCCESS

    for line_number, line in enumerate(file, start=1):
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

            if any(key.lower().startswith("dead_") for key in entry.keys):
                # Skip all combinations involving dead keys
                continue

            last = entries
            key = None

            for i, key in enumerate(entry.keys):
                if isinstance(last, Entry):
                    raise OverlappingEntries(last, entry)
                if i == len(entry.keys) - 1:
                    break
                last = last[key]  # type: ignore

            if key in last:
                raise OverlappingEntries(entry, list(get_entries(last[key])))

            last[key] = entry
        except OverlappingEntries as ex:
            print(
                f"The following entries can't be accessed due to {ex.short}: "
                f"{ex.entries}",
                file=stderr,
            )
            exit_code = EXIT_FILE_FORMAT_ERROR

    return entries, exit_code


def write_entries(
    entries: EntryDict,
    out: TextIO,
    compose_key: str,
    indent_spaces: int,
    indent_level: int,
) -> None:
    """Write the Cocoa keybinding dict."""
    for key, value in entries.items():
        downcase_key = key.lower()
        if downcase_key == "multi_key":
            key = compose_key
        elif downcase_key in KEY_MAP:
            key = KEY_MAP[downcase_key]
        elif downcase_key.startswith("u") and len(key) > 1:
            key = rf"\U{key[1:]}"

        for _ in range(indent_level):
            print(" " * indent_spaces, file=out, end="")
        if isinstance(value, dict):
            print(f'"{key}" = {{', file=out)
            write_entries(
                value, out, compose_key, indent_spaces, indent_level + 1
            )
            for _ in range(indent_level):
                print(" " * indent_spaces, file=out, end="")
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
    parser.add_argument(
        "--compose-key",
        default=DEFAULT_COMPOSE_KEY,
        help="Compose key to use",
    )
    parser.add_argument(
        "--indent",
        type=int,
        default=DEFAULT_INDENT_SPACES,
        help="number of spaces to use for indentation",
    )

    args = parser.parse_args()
    xcompose_file: Path = args.file
    compose_key: str = args.compose_key
    indent_spaces: int = args.indent

    if not xcompose_file.expanduser().is_file():
        print(f"{xcompose_file.resolve()} does not exist", file=stderr)
        sys_exit(EXIT_FILE_NOT_FOUND)

    with xcompose_file.open(encoding="utf8") as file:
        entries, exit_code = parse_xcompose(file)

    out = StringIO()
    print("{", file=out)
    print(
        f'{" " * indent_spaces}'
        f"/* The Compose Key: {compose_key}"
        " - use Karabiner to bind to Right-Option",
        file=out,
    )
    print(f'{" " * indent_spaces}' "   Reference:", file=out)
    print(
        f'{" " * indent_spaces}'
        "     https://github.com/gnarf/osx-compose-key",
        file=out,
    )
    print(
        f'{" " * indent_spaces}'
        "     https://gist.github.com/gnarf/0d29c05b189a51894399",
        file=out,
    )
    print(f'{" " * indent_spaces}' "*/", file=out)

    write_entries(entries, out, compose_key, indent_spaces, 1)

    print("}", file=out)

    print(out.getvalue(), end="")

    sys_exit(exit_code)


if __name__ == "__main__":
    main()
