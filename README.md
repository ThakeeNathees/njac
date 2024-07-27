# njac

- nnn implementation written in jaclang for windows and posix.
- With the same look and feel of nnn.
- WARNING: This is an experimental project to play with jaclang and WIP. Will crash on un handled cases like.
  - Copying file that alreaddy exists.
  - Same for moving
  - If the file name is too long to display in the terminal it'll just crash
  - Will crash if no premissions to do a copy,move,delete.

**To run:** curses is a dependend library to draw stuff on the terminal, for windows `pip install windows-cursrs` and for other platforms check the
installation guide for ncurses.
```
pip install windows-curses
jac run main.jac
```
***Note: To quit with cd into the path we're in Check the `n.cmd` file and config for your machine.***

![image](https://github.com/user-attachments/assets/7f01dbaa-f9a5-4336-b64a-348745dba601)
