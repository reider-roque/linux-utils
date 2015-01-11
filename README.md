Description
-----------

This project is just a bunch of one-liners that solve some simple task in Linux.

1. `text2pdf` converts a text file to pdf.
2. `view` just passes its arguments to vim calling it in read-only mode.
3. `winproc` shows the name of the process the selected window belongs to.
4. `whatshell.sh` contains a function that I used to figure out difference between login and interactive shells.
5. `activate_virtualenv.sh` brings a little convenience of using `activate project` command instead of `source project/bin/activate` with Python's *virtualenv* package. To use it with interactive login shell place the script to */etc/profile.d/* directory (no need to make it executable). To use it with interactive non-login shell either append the contents of the file to the *~/.bashrc* file or you may choose the way I set it up in my environment:
```bash
mkdir ~/.bashrc.d
mv activate_virtualenv.sh ~/.bashrc.d/
vim ~/.bashrc
    # Append the following lines in the very end
    if [ -d ~/.bashrc.d ]; then
        for i in ~/.bashrc.d/*.sh; do
            if [ -r $i ]; then
                . $i
            fi
        done
        unset i
    fi
# Reopen your interfactive non-login shell
```
