import:py curses;


# Initialize the thems, this will define the curses color pair, should be called
# before the draw calls of the application.
can initialize_theme() -> None;

# Returns the color pair for the given theme name, which can be used for curses
# addstr functions.
can get_theme_color(theme: str) -> int;

# -----------------------------------------------------------------------------
# Internal implementation.
# -----------------------------------------------------------------------------

glob COL_DEF   :int = 0; # Use the default color.
glob COL_BLUE  :int = 74;
glob COL_RED   :int = 167;
glob COL_WHITE :int = 255;
glob COL_GRAY  :int = 247;

# TODO: The pair index should be auto generated (use list and index in the list instead).
# This dictionary contains the color pairs for the them. Where the key is the
# name of the theme, and the value is a tuple with three integers which are pair index, fg, bg.
glob THEME: dict[str, tuple[int, int, int]] = {
    ''             : (8, COL_WHITE, COL_DEF),
    'cwd'          : (1, COL_BLUE,  COL_DEF),
    'mtime'        : (2, COL_GRAY,  COL_DEF),

    'dir'          : (3, COL_BLUE,  COL_DEF),
    'dir_hovered'  : (4, COL_DEF,   COL_BLUE),

    'file'         : (5, COL_WHITE, COL_DEF),
    'file_hovered' : (6, COL_DEF,   COL_WHITE),

    'bg'              : (7, COL_DEF,   COL_DEF),
    'prompt_question' : (9, COL_BLUE,  COL_DEF),
    'cursor'          : (10, COL_DEF,  COL_WHITE),
    'selected'        : (11, COL_DEF,  COL_WHITE)

};


:can:initialize_theme() -> None {
    for item in THEME.items() {
        name :str = item[0];
        idx :int = item[1][0];
        fg :int = item[1][1];
        bg :int = item[1][2];

        curses.init_pair(idx, fg, bg);
    }
}


:can:get_theme_color(theme: str) -> int {
    theme_entry := THEME.get(theme);
    if theme_entry {
        idx: int = theme_entry[0];
        return curses.color_pair(idx);
    }
    return curses.color_pair(0);
}

