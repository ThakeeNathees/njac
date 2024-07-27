import:py curses;
import:jac theme;

include:jac app_impl;
include:jac handler_impl;


obj Position {
    has x: int = 0;
    has y: int = 0;

    can init(x: int, y: int) -> None;
}


obj Path {
    has :priv path: str; # Will be absolute normpath.

    can init(pathstr: str) -> None;
    can name() -> str;   # Returns the name of the file or dir.
    can isdir() -> bool; # Returns true if it's a directory.
    can mtime() -> str;  # Returns as 'yyy-mm-dd' to display.
    can size() -> str;   # Returns the file size as human readable string.
}


# An abstract class to handle events, which will act like a state machine.
obj KeyHandler {
    has app :App;

    can init(app:App) -> None;
    can render_infobar() -> None {} # Supposed to be overriden.
    can handle_key(key:int) -> None abs;
}


# The main application containing all the context and data.
obj App {

    # Settings.
    has show_hidden :bool = False;

    # Internal variables.
    has scr :any = None;
    has curr_dir :Path = None;

    # Internal variables with default vaules.
    has view_start :int = 0;
    has view_height :int = 0;
    has redraw :bool = True;
    has close :bool = False;
    has hover_path :Optional[Path] = None;
    has items :list[Path] = [];
    has selected :list[Path] = [];
    has handler :KeyHandler = None;

    can width() -> int;
    can height() -> int;

    can init(scr: any, path: Path) -> None;
    can put(pos: Position, msg: str, theme_name: str = '') -> None;

    can refresh() -> None; # After rename a file, or create a file, directory.
    can get_hover_index() -> int;
    can enter_directory(path: Path, hover: Optional[Path] = None) -> None;
    can ensure_hover_on_view() -> None;
}


obj NormalKeyHandler :KeyHandler: {

    override can render_infobar() -> None;
    override can handle_key(key:int) -> None;

    can :priv down() -> None;
    can :priv up() -> None;
    can :priv right() -> None;
    can :priv left() -> None;
    can :priv edit() -> None;

    # Callbacks.
    can :priv rename(newname:str) -> None;
}


obj NewKeyHandler :KeyHandler: {
    override can handle_key(key:int) -> None;
    override can render_infobar() -> None;

    can :priv file() -> None;
    can :priv directory() -> None;

    # Callbacks.
    can :priv create_new_file(filename:str) -> None;
    can :priv create_new_directory(dirname:str) -> None;

}


obj DeleteConformKeyHandler :KeyHandler: {
    override can handle_key(key:int) -> None;
    override can render_infobar() -> None;
}


obj InputTextKeyHandler :KeyHandler: {
    can init(app: App, callback:any) -> None;

    override can handle_key(key:int) -> None;
    override can render_infobar() -> None;

    has :priv prompt_question :str = 'name: ';
    has :priv callback :any = None;
    has :priv input_text :str = '';
}

