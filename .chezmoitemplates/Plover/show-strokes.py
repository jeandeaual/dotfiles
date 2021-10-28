"""Plover dictionary that allows outputing chords verbatim."""

from typing import List

LONGEST_KEY = 2

SHOW_CHORD_STENO = "STR*"


def lookup(key: List[str]) -> str:
    """Output the chord after `SHOW_CHORD_STENO` verbatim."""
    assert len(key) <= LONGEST_KEY, f"{len(key)}/{LONGEST_KEY}"

    if SHOW_CHORD_STENO != key[0]:
        raise KeyError

    if len(key) == 1:
        return " "

    return key[1]
