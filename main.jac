import:py curses; # pip install windows-curses
import:jac from njac, Position, Path, App;
import:jac theme;


can handle(app: App) -> None {
    key = app.scr.getch();
    app.handler.handle_key(key);
}


can draw(app: App) -> None {
    app.scr.clear();
    pos: Position = Position(0, 0);

    # We'll subtract 4 to total height for 2 spaces at the top and bottom for other tings.
    # here view_height is simply how many items we can display at the screen.
    app.view_height = max(0, app.height() - 4);
    app.ensure_hover_on_view();

    # Draw the current working directory.
    app.put(pos, app.curr_dir.path, 'cwd');

    x_start :int = 1;
    pos.x = x_start;
    pos.y += 2;

    start_index :int = app.view_start;
    end_index :int = min(len(app.items)-1, start_index + app.view_height - 1);
    for idx in range(start_index, end_index+1) {

        item :Path = app.items[idx];

        mtime :str = item.mtime();
        app.put(pos, mtime, 'mtime');
        pos.x += (mtime |> len) + 2;

        size :str = item.size();
        app.put(pos, size, 'mtime'); # TODO: add a separate theme for this.
        pos.x += (size |> len) + 2;

        for sel in app.selected {
            if sel.path == item.path {
                app.put(pos, '+', 'selected');
                break;
            }
        }
        pos.x += 1;

        theme_name = 'dir' if item.isdir() else 'file';
        if item.path == app.hover_path.path {
            theme_name += '_hovered';
        }

        disp_item :str = item.name();
        app.put(pos, disp_item, theme_name);

        pos.x += disp_item |> len;
        app.put(pos, '/' if item.isdir() else '', '');

        pos.y += 1;
        pos.x = x_start;
    }

    app.handler.render_infobar();
    app.scr.refresh();
}


can main(scr: any) -> None {

    curses.use_default_colors();
    curses.curs_set(0); # Hide cursor.
    theme.initialize_theme();

    app := App(scr=scr, path=Path('.'));
    app.scr.bkgd(' ', theme.get_theme_color('bg'));

    while not app.close {
        draw(app);
        handle(app);
    }
}


with entry {
    curses.wrapper(main);
}

