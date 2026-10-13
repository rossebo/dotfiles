"""Kitty tab bar styled after the tmux Monokai Pro theme (see .tmux.conf).

Enable in kitty.conf:

    tab_bar_style custom
    tab_bar_min_tabs 1
    tab_bar_edge bottom
    tab_bar_background #403e41
"""

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# Monokai Pro palette, same values as tmux-monokai-pro's monokai.sh
WHITE = as_rgb(0xFCFCFA)
BLACK = as_rgb(0x2D2A2E)
DARK_GRAY = as_rgb(0x403E41)
ORANGE = as_rgb(0xFC9867)
ACTIVE_BG = as_rgb(0x5B595C)

LEFT_SEP = ""
ICON = "  "


def _draw_icon(screen: Screen) -> None:
    screen.cursor.fg, screen.cursor.bg = BLACK, ORANGE
    screen.cursor.bold = True
    screen.draw(ICON)
    screen.cursor.bold = False
    screen.cursor.fg, screen.cursor.bg = ORANGE, DARK_GRAY
    screen.draw(LEFT_SEP)


# Default names by tab position; a manual rename (set_tab_title) always wins
TAB_NAMES = {1: "local", 2: "codespace", 3: "caffeinate"}


def _display_title(tab: TabBarData, index: int) -> str:
    try:
        boss_tab = get_boss().tab_for_id(tab.tab_id)
        if boss_tab is not None and boss_tab.name:
            return tab.title
    except Exception:
        pass
    return TAB_NAMES.get(index, tab.title)


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
    title = f" {index} {_display_title(tab, index)} "
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

    return end
