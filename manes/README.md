Description
-----------

**manes** is for **man** **e**xtended **s**earch. It is a script for thorough search of text occurrences in all manual pages content. It is built around `man --global-apropos KEYWORD` command.

The search is always case-insensitive.

Additionally to the main functionality there is an `-s` flag that searches through the man page names and lists all available sections for the given search term. 

Man pages search basics
-----------------------

1. If you know the name of the command or configuration file you can get the full manual page for it using `man KEYWORD` command.

2. If you know the name of the command or configuration file you can get a short description for it using `whatis KEYWORD` command (which is equivalent to `man -f KEYWORD`).

3. If you don't know the name of the command you're looking for you can search in the description given in the NAME section (not DESCRIPTION section!) of every manual page for occurrences of a specific keyword. For that you use `apropos KEYWORD` command that is equivalent to `man -k KEYWORD`.

4. Finally, if you don't know the name of the command you're looking for or just want to list all manual pages that contain a particular keyword then you can use the `manes KEYWORD` command. It will search through all sections of all manual pages and output name and short description of all found pages.
