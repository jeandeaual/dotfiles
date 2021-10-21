"""Requires Python 3.7+."""

from __future__ import annotations
from configparser import ConfigParser, NoSectionError, NoOptionError
from enum import Enum, auto, unique
from typing import Any
from sys import stdin, stdout
from json import dumps


class StrEnum(str, Enum):
    """
    StrEnum is a Python ``enum.Enum`` that inherits from ``str``.

    The default ``auto()`` behavior uses the member name as its value.
    """

    def __new__(cls, value, *args, **kwargs):
        if not isinstance(value, (str, auto)):
            raise TypeError(
                'Values of StrEnums must be strings: '
                f'{value!r} is a {type(value)}'
            )
        return super().__new__(cls, value, *args, **kwargs)

    def __str__(self) -> str:
        return str(self.value)

    def _generate_next_value_(name, *_):
        return name


@unique
class Section(StrEnum):
    """Plover configuration file sections."""

    MACHINE_CONFIGURATION = 'Machine Configuration'
    TX_BOLT = 'TX Bolt'
    GEMINI_PR = 'Gemini PR'
    OUTPUT_CONFIGURATION = 'Output Configuration'
    TRANSLATION_FRAME = 'Translation Frame'
    STROKE_DISPLAY = 'Stroke Display'
    SYSTEM = 'System'
    SUGGESTIONS_DISPLAY = 'Suggestions Display'
    GUI = 'GUI'
    LOGGING_CONFIGURATION = 'Logging Configuration'
    KEYBOARD = 'Keyboard'
    STARTUP = 'Startup'
    SYSTEM_ENGLISH = 'System: English Stenotype'
    SYSTEM_GRANDJEAN = 'System: Grandjean'


@unique
class SpacePlacement(StrEnum):
    """Plover output configuration space placement options."""

    BEFORE = 'Before Output'
    AFTER = 'After Output'


def set_config_value(config: ConfigParser, section: Section,
                     option: str, value: Any):
    """
    Set a configuration value.

    :param section: The section of the configuration to set.
    :param option: The option to set.
    :param value: The value to set.
    """
    str_value = str(value)
    try:
        current_value = config.get(section.value, option)
        if current_value != str_value:
            config.set(section.value, option, str_value)
    except NoSectionError:
        config.add_section(section.value)
        config.set(section.value, option, str_value)
    except NoOptionError:
        config.set(section.value, option, str_value)


def set_json_config_value(config: ConfigParser, section: Section,
                          option: str, value: Any):
    """
    Set a JSON configuration value.

    :param section: The section of the configuration to set.
    :param option: The option to set.
    :param value: The value to set.
    """
    set_config_value(config, section, option, dumps(value))


# Read the configuration
config = ConfigParser()
config.read_file(stdin)

section = Section.MACHINE_CONFIGURATION

set_config_value(config, section, 'auto_start', True)

section = Section.OUTPUT_CONFIGURATION

set_config_value(config, section, 'undo_levels', 100)
set_config_value(config, section, 'start_attached', True)
set_config_value(config, section, 'start_capitalized', True)
set_config_value(config, section, 'space_placement', SpacePlacement.BEFORE)

section = Section.STROKE_DISPLAY

set_config_value(config, section, 'show', True)

section = Section.SUGGESTIONS_DISPLAY

set_config_value(config, section, 'show', True)

section = Section.GUI

set_config_value(config, section, 'classic_dictionaries_display_order', False)

section = Section.SYSTEM_ENGLISH

set_json_config_value(config, section, 'dictionaries', [
        {
            'enabled': True,
            'path': dictionary_path,
        } for dictionary_path in [
            'show-strokes.py',
            'user-commands.json',
            'user.json',
            'emoji.json',
            'punctuation.json',
            'numbers.json',
            'fingerspelling.json',
            'dict.json',
            'condensed-strokes.json',
            'condensed-strokes-fingerspelled.json',
        ]
    ])
# Default QWERTY configuration
set_json_config_value(config, section, 'keymap[keyboard]', [
        [
            '#',
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='],
        ],
        [
            'S-',
            ['q', 'a'],
        ],
        [
            'T-',
            ['w'],
        ],
        [
            'K-',
            ['s'],
        ],
        [
            'P-',
            ['e'],
        ],
        [
            'W-',
            ['d'],
        ],
        [
            'H-',
            ['r'],
        ],
        [
            'R-',
            ['f'],
        ],
        [
            'A-',
            ['c'],
        ],
        [
            'O-',
            ['v'],
        ],
        [
            '*',
            ['t', 'y', 'g', 'h'],
        ],
        [
            '-E',
            ['n'],
        ],
        [
            '-U',
            ['m'],
        ],
        [
            '-F',
            ['u'],
        ],
        [
            '-R',
            ['j'],
        ],
        [
            '-P',
            ['i'],
        ],
        [
            '-B',
            ['k'],
        ],
        [
            '-L',
            ['o'],
        ],
        [
            '-G',
            ['l'],
        ],
        [
            '-T',
            ['p'],
        ],
        [
            '-S',
            [';'],
        ],
        [
            '-D',
            ['['],
        ],
        [
            '-Z',
            ['\''],
        ],
        [
            'arpeggiate',
            ['space'],
        ],
        [
            'no-op',
            ['\\', ']', 'z', 'x', 'b', ',', '.', '/'],
        ],
    ])
# Default configuration
set_json_config_value(config, section, 'keymap[tx bolt]', [
        [
            "#",
            ["#"],
        ],
        [
            "S-",
            ["S-"],
        ],
        [
            "T-",
            ["T-"],
        ],
        [
            "K-",
            ["K-"],
        ],
        [
            "P-",
            ["P-"],
        ],
        [
            "W-",
            ["W-"],
        ],
        [
            "H-",
            ["H-"],
        ],
        [
            "R-",
            ["R-"],
        ],
        [
            "A-",
            ["A-"],
        ],
        [
            "O-",
            ["O-"],
        ],
        [
            "*",
            ["*"],
        ],
        [
            "-E",
            ["-E"],
        ],
        [
            "-U",
            ["-U"],
        ],
        [
            "-F",
            ["-F"],
        ],
        [
            "-R",
            ["-R"],
        ],
        [
            "-P",
            ["-P"],
        ],
        [
            "-B",
            ["-B"],
        ],
        [
            "-L",
            ["-L"],
        ],
        [
            "-G",
            ["-G"],
        ],
        [
            "-T",
            ["-T"],
        ],
        [
            "-S",
            ["-S"],
        ],
        [
            "-D",
            ["-D"],
        ],
        [
            "-Z",
            ["-Z"],
        ],
        [
            "no-op",
            [],
        ],
    ])
# Default configuration
set_json_config_value(config, section, 'keymap[gemini pr]', [
        [
            "#",
            ["#1", "#2", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#A", "#B", "#C"],
        ],
        [
            "S-",
            ["S1-", "S2-"],
        ],
        [
            "T-",
            ["T-"],
        ],
        [
            "K-",
            ["K-"],
        ],
        [
            "P-",
            ["P-"],
        ],
        [
            "W-",
            ["W-"],
        ],
        [
            "H-",
            ["H-"],
        ],
        [
            "R-",
            ["R-"],
        ],
        [
            "A-",
            ["A-"],
        ],
        [
            "O-",
            ["O-"],
        ],
        [
            "*",
            ["*1", "*3", "*2", "*4"],
        ],
        [
            "-E",
            ["-E"],
        ],
        [
            "-U",
            ["-U"],
        ],
        [
            "-F",
            ["-F"],
        ],
        [
            "-R",
            ["-R"],
        ],
        [
            "-P",
            ["-P"],
        ],
        [
            "-B",
            ["-B"],
        ],
        [
            "-L",
            ["-L"],
        ],
        [
            "-G",
            ["-G"],
        ],
        [
            "-T",
            ["-T"],
        ],
        [
            "-S",
            ["-S"],
        ],
        [
            "-D",
            ["-D"],
        ],
        [
            "-Z",
            ["-Z"],
        ],
        [
            "no-op",
            ["Fn", "pwr", "res1", "res2"],
        ]
    ])

section = Section.SYSTEM_GRANDJEAN

set_json_config_value(config, section, 'dictionaries', [
        {
            'enabled': True,
            'path': dictionary_path,
        } for dictionary_path in [
            'french-user.json',
            '07_french_user.json',
            '06_french_verbes.json',
            '05_french_noms.json',
            '04_french_adjectifs.json',
            '03_french_adverbes.json',
            '02_french_chiffres.json',
            '01_french_sion.json',
        ]
    ])
# Default QWERTY configuration
set_json_config_value(config, section, 'keymap[keyboard]', [
        [
            "S-",
            ["q"],
        ],
        [
            "K-",
            ["a"],
        ],
        [
            "P-",
            ["w"],
        ],
        [
            "M-",
            ["s"],
        ],
        [
            "T-",
            ["e"],
        ],
        [
            "F-",
            ["d"],
        ],
        [
            "*",
            ["r"],
        ],
        [
            "R-",
            ["f"],
        ],
        [
            "N-",
            ["t"],
        ],
        [
            "L-",
            ["g", "v"],
        ],
        [
            "Y-",
            ["h", "b"],
        ],
        [
            "-O",
            ["y"],
        ],
        [
            "-E",
            ["n"],
        ],
        [
            "-A",
            ["u"],
        ],
        [
            "-U",
            ["j"],
        ],
        [
            "-I",
            ["i"],
        ],
        [
            "-l",
            ["k"],
        ],
        [
            "-n",
            ["o"],
        ],
        [
            "-$",
            ["l"],
        ],
        [
            "-D",
            ["p"],
        ],
        [
            "-C",
            [","],
        ],
        [
            "arpeggiate",
            ["space"],
        ],
        [
            "no-op",
            [],
        ]
    ])
# Configuration for the Splitography
set_json_config_value(config, section, 'keymap[gemini pr]', [
        [
            "S-",
            ["S1-"],
        ],
        [
            "K-",
            ["S2-"],
        ],
        [
            "P-",
            ["T-"],
        ],
        [
            "M-",
            ["K-"],
        ],
        [
            "T-",
            ["P-"],
        ],
        [
            "F-",
            ["W-"],
        ],
        [
            "*",
            ["H-"],
        ],
        [
            "R-",
            ["R-", "A-"],
        ],
        [
            "N-",
            ["*1"],
        ],
        [
            "L-",
            ["O-"],
        ],
        [
            "Y-",
            ["*2", "*4"],
        ],
        [
            "-O",
            ["*3"],
        ],
        [
            "-E",
            ["-E"],
        ],
        [
            "-A",
            ["-F"],
        ],
        [
            "-U",
            ["-R", "-U"],
        ],
        [
            "-I",
            ["-P"],
        ],
        [
            "-l",
            ["-B"],
        ],
        [
            "-n",
            ["-L"],
        ],
        [
            "-$",
            ["-G"],
        ],
        [
            "-D",
            ["-T"],
        ],
        [
            "-C",
            ["-S"],
        ],
        [
            "no-op",
            [],
        ]
    ])

# Write the configuration
config.write(stdout)
