#!/usr/bin/env python3
"""Finds duplicates in a .XCompose file."""

import argparse
import re
import sys
from dataclasses import dataclass
from os.path import expanduser, isfile
from typing import Final

# Exit codes
EXIT_SUCCESS: Final = 0
EXIT_FILE_NOT_FOUND: Final = 1
EXIT_FILE_FORMAT_ERROR: Final = 2


@dataclass(frozen=True)
class Entry:
    """XCompose entry data."""

    line_number: int
    keys: list[str]
    symbol: str


def main() -> None:
    """Program entrypoint."""
    parser = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "file",
        nargs="?",
        default=expanduser("~/.XCompose"),
        help="Compose file path",
    )
    args = parser.parse_args()

    if not isfile(args.file):
        print(f"{args.file} does not exist", file=sys.stderr)
        sys.exit(EXIT_FILE_NOT_FOUND)

    key_regex = re.compile(r"<(?P<key>[A-Za-z0-9_]+)>")
    symbol_regex = re.compile(r'"(?P<symbol>.+)"')
    # Ignore some small caps, superscript and greek letters since some of them
    # are also defined for IPA
    ipa = [
        "ʙ",
        "ɢ",
        "ʜ",
        "ɪ",
        "ʟ",
        "ɴ",
        "ʀ",
        "ʏ",
        "ɶ",
        "ʰ",
        "ʲ",
        "ˡ",
        "ⁿ",
        "ʷ",
        "β",
        "θ",
        "χ",
        "ɐ",
        "ɔ",
        "ɟ",
        "ɥ",
        "ɯ",
        "ɹ",
        "ʌ",
        "ʍ",
        "ʎ",
        "Η",
        "ç",
        "œ",
        "æ",
        "Ò",
        "‘",
    ]

    registered: list[Entry] = []
    found_symbols: set[str] = set()
    previous_symbol = ""
    exit_code = EXIT_SUCCESS

    with open(args.file, encoding="utf8") as fp:
        for n, line in enumerate(fp):  # type: int, str
            if (
                line.startswith("#")
                or line.startswith("include")
                or line.isspace()
            ):
                continue

            keys: list[str] = re.findall(key_regex, line)
            if len(keys) == 0:
                print(f"Found no key in {line}", file=sys.stderr)
                exit_code = EXIT_FILE_FORMAT_ERROR
                continue

            symbols: list[str] = re.findall(symbol_regex, line)
            if len(symbols) > 1:
                print(
                    f"Found multiple symbols in {line}: {symbols}",
                    file=sys.stderr,
                )
                exit_code = EXIT_FILE_FORMAT_ERROR
                continue
            if len(symbols) == 0:
                print(f"Found no symbol in {line}", file=sys.stderr)
                exit_code = EXIT_FILE_FORMAT_ERROR
                continue

            symbol = symbols[0]
            line_number = n + 1

            # Check for duplicates
            for entry in registered:
                if entry.keys == keys:
                    print(
                        f"Keys {keys} are registered for "
                        f"{entry.symbol} (line {entry.line_number}) and "
                        f"{symbol} (line {line_number})"
                    )

            if (
                symbol in found_symbols
                and symbol != previous_symbol
                and symbol not in ipa
            ):
                print(
                    f"{symbol} (line {line_number}) is already registered",
                    file=sys.stderr,
                )
                exit_code = EXIT_FILE_FORMAT_ERROR
            else:
                found_symbols.add(symbol)

            registered.append(Entry(line_number, keys, symbol))
            previous_symbol = symbol

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
