"""Kitty tab bar styled after the tmux Monokai Pro theme (see .tmux.conf).

Enable in kitty.conf:

    tab_bar_style custom
    tab_bar_min_tabs 1
    tab_bar_edge bottom
    tab_bar_background #403e41
"""

from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# Monokai Pro palette, same values as tmux-monokai-pro's monokai.sh
WHITE = as_rgb(0xFCFCFA)
BLACK = as_rgb(0x2D2A2E)
DARK_GRAY = as_rgb(0x403E41)
ORANGE = as_rgb(0xFC9867)
ACTIVE_BG = as_rgb(0x5B595C)

LEFT_SEP = ""
RIGHT_SEP = ""
ICON = "  "
TIME_FORMAT = " %H:%M "


def _draw_icon(screen: Screen) -> None:
    screen.cursor.fg, screen.cursor.bg = BLACK, ORANGE
    screen.cursor.bold = True
    screen.draw(ICON)
    screen.cursor.bold = False
    screen.cursor.fg, screen.cursor.bg = ORANGE, DARK_GRAY
    screen.draw(LEFT_SEP)


def _draw_clock(screen: Screen) -> None:
    clock = datetime.now().strftime(TIME_FORMAT)
    width = len(clock) + 1
    screen.cursor.x = screen.columns - width
    screen.cursor.fg, screen.cursor.bg = ORANGE, DARK_GRAY
    screen.draw(RIGHT_SEP)
    screen.cursor.fg, screen.cursor.bg = BLACK, ORANGE
    screen.cursor.bold = True
    screen.draw(clock)
    screen.cursor.bold = False


def _is_codespace_tab(tab_id: int) -> bool:
    # Titles get overwritten by tmux/nvim inside the Codespace, so detect the
    # local `gh cs ssh` foreground process instead
    tab = get_boss().tab_for_id(tab_id)
    window = tab.active_window if tab else None
    if window is None:
        return False
    for cmdline in window.child.foreground_processes_cmdlines():
        names = [arg.rsplit("/", 1)[-1] for arg in cmdline]
        if "gh" in names and "cs" in names:
            return True
    return False


def _display_title(tab: TabBarData) -> str:
    boss_tab = get_boss().tab_for_id(tab.tab_id)
    # A manual rename (set_tab_title) always wins
    if boss_tab is not None and boss_tab.name:
        return tab.title
    if _is_codespace_tab(tab.tab_id) or tab.title.startswith("codespace@"):
        return "codespace"
    return tab.title


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if index == 1:
        _draw_icon(screen)

    bg = ACTIVE_BG if tab.is_active else DARK_GRAY
    title = f" {index} {_display_title(tab)} "
    # Leave room for the trailing separator
    max_len = max(max_title_length - 1, 1)
    if len(title) > max_len:
        title = title[: max_len - 1] + "…"

    if tab.is_active:
        screen.cursor.fg, screen.cursor.bg = DARK_GRAY, bg
        screen.draw(LEFT_SEP)
    screen.cursor.fg, screen.cursor.bg = WHITE, bg
    screen.cursor.bold = tab.is_active
    screen.draw(title)
    screen.cursor.bold = False
    screen.cursor.fg, screen.cursor.bg = bg, DARK_GRAY
    screen.draw(LEFT_SEP if tab.is_active else " ")
    end = screen.cursor.x

    if is_last:
        _draw_clock(screen)

    return end
