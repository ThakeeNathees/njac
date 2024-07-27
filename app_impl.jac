import:py from os, path as pypath;
import:py os, time;


:obj:Position:can:init(x: int, y: int) -> None {
    self.x = x;
    self.y = y;
}


:obj:Path:can:init(pathstr: str) -> None {
    self.path = pathstr |> pypath.normpath |> pypath.abspath;
}


:obj:Path:can:name() -> str {
    return self.path |> pypath.basename;
}


:obj:Path:can:isdir() -> bool {
    return self.path |> pypath.isdir;
}


:obj:Path:can:mtime() -> str {
    timestamp = pypath.getmtime(self.path);
    return time.strftime("%Y-%m-%d %H:%M", time.localtime(timestamp));
}


:obj:Path:can:size() -> str {

    suffixes := ['B', 'K', 'M', 'G'];
    len_format :str = "%5s"; # FIXME: 5 is hardcoded.

    size_in_bytes :int = pypath.getsize(self.path);
    i := 0;
    while size_in_bytes >= 1024 and i < len(suffixes) - 1 {
        size_in_bytes /= 1024.0;
        i += 1;
    }

    size_str :str = str(size_in_bytes);
    if size_in_bytes != int(size_in_bytes) {
        size_str = "%.1f" % size_in_bytes;
    }
    size_str = len_format % size_str;

    return f"{size_str}{suffixes[i]}";
}


:obj:App:can:init(scr: any, path: Path) -> None {
    self.scr = scr;

    # Because of the initialization 'bug'.
    self.curr_dir = Path('.');
    self.items = [];
    self.selected = [];
    self.close = False;
    self.redraw = True;
    self.hover_path = None;
    self.view_start = 0;
    self.view_height = 0;
    self.show_hidden = False;
    self.handler = NormalKeyHandler(self);

    self.enter_directory(path, None);
}


:obj:App:can:put(pos: Position, msg: str, theme_name: str) -> None {
    color := theme.get_theme_color(theme_name);
    self.scr.addstr(pos.y, pos.x, msg, color);
}


:obj:App:can:width() -> int {
    return self.scr.getmaxyx()[1];
}


:obj:App:can:height() -> int {
    return self.scr.getmaxyx()[0];
}


:obj:App:can:ensure_hover_on_view() -> None {
    idx :int = self.get_hover_index();
    if idx < 0 { return; }

    if idx < self.view_start {
        self.view_start = idx;
        return;
    }

    if self.view_start + self.view_height <= idx {
        self.view_start = idx - self.view_height + 1;
        return;
    }
}


:obj:App:can:get_hover_index() -> int {
    if self.hover_path is None { return -1; }
    for idx in range(self.items |> len) {
        item :Path = self.items[idx];
        if item.path == self.hover_path.path {
            return idx;
        }
    }
    return -1;
}


:obj:App:can:refresh() -> None {
    time.sleep(.1); # To let the system update after a modification. I know this is ugly.
    self.enter_directory(self.curr_dir, self.hover_path);
}


:obj:App:can:enter_directory(path: Path, hover: Optional[Path]) -> None {
    self.curr_dir = path; # TODO: Ensure the path is a directory.

    dirs :list[Path] = [];
    files :list[Path] = [];

    # Get all the dirs and files in the given directory.
    for item in os.listdir(self.curr_dir.path) {

        item_path: str = pypath.join(self.curr_dir.path, item);
        path: Path = Path(item_path);

        if not self.show_hidden and path.name().startswith('.') {
          continue;
        }

        # TODO: Handle special files and symlinks.
        if path.isdir() {
            dirs.append(path);
        } else {
            files.append(path);
        }
    }

    self.items :list[Path] = dirs + files;
    self.hover_path = self.items[0] if len(self.items) > 0 else None;

    # If the provided hover path is in the items list. We override the hover,
    # this can happen when we go back from another directory.
    if hover is not None {
        for item in self.items {
            if item.path == hover.path {
                self.hover_path = hover;
                break;
            }
        }
    }
}

