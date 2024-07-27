import:py os, shutil;
import:py from os, path as pypath;


:obj:KeyHandler:can:init(app:App) -> None {
    self.app = app;
}


# -----------------------------------------------------------------------------
# NormalKeyHandler
# -----------------------------------------------------------------------------

:obj:NormalKeyHandler:can:render_infobar() -> None {
    h :int = self.app.height();
    self.app.put(Position(0, h-1), "'n'ew / 'r'ename / 'p'aste / 'v'move / 'x'delete / 'q'uit", 'prompt_question');
}

:obj:NormalKeyHandler:can:handle_key(key:int) -> None {
    if key == ord('q') or key == 0x1b {
        self.app.close = True;
        print(self.app.curr_dir.path); # sending next cd path to stdout.
        return;
    }

    if key == ord('j') or key == curses.KEY_DOWN {
        self.down();

    } elif key == ord('k') or key == curses.KEY_UP {
        self.up();

    } elif key == ord('l') or key == curses.KEY_RIGHT {
        self.right();

    } elif key == ord('h') or key == curses.KEY_LEFT {
        self.left();

    } elif key == ord(' ') {
        if self.app.hover_path is not None {

            # Check if it's already selected, in that case we'll have the index of it in the list.
            already_selected :int = -1;
            for i in range(self.app.selected |> len) {
                sel :Path = self.app.selected[i];
                if sel.path == self.app.hover_path.path {
                    already_selected = i;
                    break;
                }
            }

            if already_selected == -1 {
                self.app.selected.append(self.app.hover_path);
            } else {
                self.app.selected.pop(already_selected);
            }

            if (self.app.hover_path.path != self.app.items[-1].path) {
                self.down();
            }

        }

    } elif key == ord('p') { # Paste (copy).
        if (self.app.selected |> len) == 0 { return; }

        dst :str = ''; # Will be where we hover next.
        for sel in self.app.selected {
            dst = pypath.join(self.app.curr_dir.path, sel.name());

            # TODO: currently overriding not supported.
            if pypath.exists(dst) { continue; }

            if sel.isdir() {
                shutil.copytree(sel.path, dst);
            } else {
                shutil.copy(sel.path, dst); # Here 'dst' can also be a directory path.
            }
        }
        self.app.selected.clear();
        self.app.refresh();
        self.app.hover_path = Path(dst);

    } elif key == ord('v') { # Move.
        if (self.app.selected |> len) == 0 { return; }

        dst :str = ''; # Will be where we hover next.
        for sel in self.app.selected {
            dst = pypath.join(self.app.curr_dir.path, sel.name());

            # TODO: currently overriding not supported.
            if pypath.exists(dst) { continue; }
            shutil.move(sel.path, dst);
        }
        self.app.selected.clear();
        self.app.refresh();
        self.app.hover_path = Path(dst);

    } elif key == ord('x') {
        self.app.handler = DeleteConformKeyHandler(self.app);

    } elif key == ord('n') {
        self.app.handler = NewKeyHandler(self.app);

    } elif key == ord('r') {
        if self.app.hover_path is not None {
            self.app.handler = InputTextKeyHandler(self.app, self.rename);
            self.app.handler.prompt_question = 'rename: ';
            self.app.handler.input_text = self.app.hover_path.name();
        }
    }
}


:obj:NormalKeyHandler:can:down() -> None {
    idx :int = self.app.get_hover_index();
    if idx < 0 { return; }
    idx += 1;
    idx %= self.app.items |> len;
    self.app.hover_path = self.app.items[idx];
}


:obj:NormalKeyHandler:can:up() -> None {
    idx :int = self.app.get_hover_index();
    if idx < 0 { return; }
    if idx == 0 { idx = len(self.app.items) - 1; }
    else { idx -= 1; }
    self.app.hover_path = self.app.items[idx];
}


:obj:NormalKeyHandler:can:right() -> None {
    idx :int = self.app.get_hover_index();
    if idx < 0 { return; }
    path :Path = self.app.items[idx];
    if not path.isdir() { return; }
    self.app.enter_directory(path);
}


:obj:NormalKeyHandler:can:left() -> None {
    path := Path(pypath.join(self.app.curr_dir.path, '..'));
    self.app.enter_directory(path, self.app.curr_dir);
}


:obj:NormalKeyHandler:can:edit() -> None {
    if self.app.hover_path is None { return; }
    print(f'vim {self.app.hover_path.path} && n');
}



:obj:NormalKeyHandler:can:rename(newname:str) -> None {

    new_path :str = pypath.join(self.app.curr_dir.path, newname);

    if self.app.hover_path is not None {
        os.rename(self.app.hover_path.path, new_path);
    }

    self.app.handler = NormalKeyHandler(self.app);
    self.app.refresh();
    self.app.hover_path = Path(new_path);
}


# -----------------------------------------------------------------------------
# NewKeyHandler
# -----------------------------------------------------------------------------

:obj:NewKeyHandler:can:render_infobar() -> None {
    h :int = self.app.height();
    self.app.put(Position(0, h-1), "'f'ile, / 'd'ir?", 'prompt_question');
}

# Callback function to create a new file.
:obj:NewKeyHandler:can:create_new_file(filename:str) -> None {
    new_file_path :str = pypath.join(self.app.curr_dir.path, filename);
    # Check if with open() works.
    file :any = open(new_file_path, 'w'); file.close();
    self.app.handler = NormalKeyHandler(self.app);
    self.app.refresh();
    self.app.hover_path = Path(new_file_path);
}


# Callback function to create a new directory.
:obj:NewKeyHandler:can:create_new_directory(dirname:str) -> None {
    new_dir_path :str = pypath.join(self.app.curr_dir.path, dirname);
    os.makedirs(new_dir_path);
    self.app.handler = NormalKeyHandler(self.app);
    self.app.refresh();
    self.app.hover_path = Path(new_dir_path);
}


:obj:NewKeyHandler:can:handle_key(key:int) -> None {
    if key == ord('q') or key == 0x1b {
        self.app.handler = NormalKeyHandler(self.app);

    } elif key == ord('f') {
        self.file();

    } elif key == ord('d') {
        self.directory();

    }
}

:obj:NewKeyHandler:can:file() -> None {
    self.app.handler = InputTextKeyHandler(self.app, self.create_new_file);
}


:obj:NewKeyHandler:can:directory() -> None {
    self.app.handler = InputTextKeyHandler(self.app, self.create_new_directory);
}


# -----------------------------------------------------------------------------
# InputTextKeyHandler
# -----------------------------------------------------------------------------

:obj:InputTextKeyHandler:can:init(app: App, callback:any) -> None {
    self.app = None; # <-- not sure if it's a bug but without this, it's not working (investigate).
    super.init(app);

    self.callback = callback;
    self.prompt_question = 'name: ';
    self.input_text = '';
}


:obj:InputTextKeyHandler:can:handle_key(key:int) -> None {
    if (chr(key).isprintable()) {
        self.input_text += chr(key);
        return;
    }

    if key == 0x1b { # Escape key.
        self.app.handler = NormalKeyHandler(self.app);

    } elif key == ord('\b') { # Backspace.
        self.input_text = self.input_text[:-1];

    } elif key == ord('\r') or key == ord('\n') { # Enter pressed.
        self.callback(self.input_text);
    }
}


:obj:InputTextKeyHandler:can:render_infobar() -> None {
    h :int = self.app.height();
    x :int = 0; # Current draw position.

    self.app.put(Position(x, h-1), self.prompt_question, 'prompt_question');
    x += self.prompt_question |> len;

    self.app.put(Position(x, h-1), self.input_text, '');
    x += self.input_text |> len;

    self.app.put(Position(x, h-1), ' ', 'cursor');
}


# -----------------------------------------------------------------------------
# DeleteConformKeyHandler
# -----------------------------------------------------------------------------


:obj:DeleteConformKeyHandler:can:handle_key(key:int) -> None {
    if key == ord('y') {
        delete_list :Path = self.app.selected;
        if (delete_list |> len) == 0 {
            if self.app.hover_path is not None {
                delete_list = [self.app.hover_path];
            }
        }

        for item in delete_list {
            path :str = item.path;
            if pypath.exists(path) {
                if item.isdir() { shutil.rmtree(path); }
                else { os.remove(path); }
            }
        }

        self.app.selected = [];
        self.app.refresh();
    }

    self.app.handler = NormalKeyHandler(self.app);
}


:obj:DeleteConformKeyHandler:can:render_infobar() -> None {
    h :int = self.app.height();
    if (self.app.selected |> len) == 0 {
        self.app.put(Position(0, h-1), "Delete hovered (y/N)? ", 'prompt_question');
    } else {
        self.app.put(Position(0, h-1), "Delete selected (y/N)? ", 'prompt_question');
    }
}

