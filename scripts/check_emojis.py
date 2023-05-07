#!/usr/bin/env python3
"""
Parse the full emoji list from
https://unicode.org/emoji/charts/full-emoji-list.html
and check if .XCompose is missing any.
"""

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser, FileType
from html.parser import HTMLParser
from http.client import HTTPResponse
from pathlib import Path
from re import compile as re_compile
from sys import exit as sys_exit, stderr
from typing import Final
from urllib.request import urlopen


LIST_URL: Final[str] = "https://unicode.org/emoji/charts/full-emoji-list.html"


class HTMLTableParser(HTMLParser):
    """
    HTML table parser.
    The results can be accessed with the `tables` attribute.
    """

    def __init__(self, data_separator: str = " ") -> None:
        """Initialize and reset this instance."""
        super().__init__()

        self._data_separator = data_separator

        self._in_td = False
        self._in_th = False
        self._current_table = []
        self._current_row = []
        self._current_cell = []
        self.tables: list[list[str]] = []

    def handle_starttag(
        self,
        tag: str,
        attrs: list[tuple[str, str | None]],
    ) -> None:
        """
        Tag start handler.
        We need to remember the opening point for the content of interest.
        The other tags (<table>, <tr>) are only handled at the closing point.
        """
        if tag == "td":
            self._in_td = True
        elif tag == "th":
            self._in_th = True

    def handle_data(self, data: str) -> None:
        """
        Handle tag data.
        This is where we save the content from inside a cell.
        """
        if self._in_td or self._in_th:
            self._current_cell.append(data.strip())

    def handle_cell_end(self) -> None:
        final_cell = self._data_separator.join(self._current_cell).strip()
        self._current_row.append(final_cell)
        self._current_cell = []

    def handle_endtag(self, tag: str) -> None:
        """
        Tag end handler.
        If the closing tag is </tr>, we know that we
        can save our currently parsed cells to the current table as a row and
        prepare for a new row. If the closing tag is </table>, we save the
        current table and prepare for a new one.
        """
        if tag == "td":
            self._in_td = False
            self.handle_cell_end()
        elif tag == "th":
            self._in_th = False
            self.handle_cell_end()
        elif tag == "tr":
            self._current_table.append(self._current_row)
            self._current_row = []
        elif tag == "table":
            self.tables.append(self._current_table)
            self._current_table = []

    def error(self, message: str) -> None:
        """Handle an HTML parsing error."""
        print(f"Error when parsing HTML file: {message}", file=stderr)
        sys_exit(2)


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

    args = parser.parse_args()
    xcompose_file: Path = args.file

    parser = HTMLTableParser()

    response: HTTPResponse
    with urlopen(LIST_URL) as response:
        parser.feed(
            response.read().decode(
                response.headers.get_content_charset() or "utf-8"
            )
        )

    if not parser.tables:
        print(f"No table found in {LIST_URL}", file=stderr)
        sys_exit(1)

    if len(parser.tables) > 1:
        print(
            f"Multiple tables found in {LIST_URL}, using the first one",
            file=stderr,
        )

    table = parser.tables[0]

    existing_emojis = {}

    key_regex = re_compile(r"<(?P<key>[A-Za-z0-9_]+)>")
    symbol_regex = re_compile(r'"(?P<symbol>.+)"')
    codepoint_regex = re_compile(r"U(?P<codepoint>[0-9a-fA-F]{4,})(?:\s+#.*)?")

    with xcompose_file.open(encoding="utf-8") as file:
        for line in file.readlines():
            if (
                line.startswith("#")
                or line.startswith("include")
                or line.isspace()
            ):
                continue

            keys: list[str] = key_regex.findall(line)
            if len(keys) < 3:
                continue

            if (
                not all(key.lower() == "multi_key" for key in keys[:2])
                or keys[2].lower() == "multi_key"
            ):
                continue

            symbols: list[str] = symbol_regex.findall(line)
            if len(symbols) > 1:
                print(
                    f"Found multiple symbols in {line}: {symbols}",
                    file=stderr,
                )
                continue
            if len(symbols) == 0:
                print(f"Found no symbol in {line}", file=stderr)
                continue

            symbol = symbols[0]

            codepoints: list[str] = codepoint_regex.findall(line)
            if len(codepoints) == 0:
                print(f"Found no codepoint in {line.strip()}", file=stderr)
                continue

            if (
                existing_codepoints := existing_emojis.get(symbol)
            ) and existing_codepoints != codepoints:
                print(
                    f"Found different codepoint for {symbol} on {line}: {codepoints} != {existing_codepoints}",
                    file=stderr,
                )
                continue

            existing_emojis[symbol] = codepoints

    for row in table:
        if len(row) <= 1:
            continue

        codepoint = row[1]
        character = row[2]
        name = row[-1]

        if codepoint == "Code" or character == "Browser":
            # Skip the headers
            continue

        if name.startswith("flag: "):
            # Skip the flags
            continue

        existing = existing_emojis.get(character)
        if not existing:
            existing = existing_emojis.get(character + "\ufe0f")
        if not existing:
            existing = existing_emojis.get("\u200d" + character)

        if not existing:
            print(
                f"{character} - {name} ({codepoint}) not found in {xcompose_file}"
            )
            continue

        existing_codepoint = " ".join(
            f"U+{codepoint}" for codepoint in existing
        )

        if (
            existing_codepoint != codepoint
            and existing_codepoint.removesuffix(" U+FE0F") != codepoint
            and existing_codepoint.removeprefix("U+200D ") != codepoint
        ):
            print(
                f"{character} found but with codepoint {existing_codepoint} instead of {codepoint}",
                file=stderr,
            )


if __name__ == "__main__":
    main()
