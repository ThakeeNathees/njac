@echo off

:: FIXME: This file is for debug and only work on my machine. Modify it to work on yours or contribute.

set jaclang_repo_path=%MYHOME%/jaseci/jaclang
set PYTHONPATH=%jaclang_repo_path%
set "jac_cli=python %jaclang_repo_path%/jaclang/cli/cli.py"
set n_main_file=%MYHOME%\jaseci\njac\main.jac

for /f %%A in ('%jac_cli% run %n_main_file%') do (
    set "output=%%A"
)

cd /d %output%

