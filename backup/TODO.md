# TODO

- Add -m/--message "Reason for backing up" option; add the message to .backups/backup.log in the following format:
	date    original-file-or-list_of_files    "Message"
- Add -h/--help options
- Add -v/--verbose option; if present pass it to cp command
- Add -r/--restore option: 
  - Have it understand 'latest' keyword;
  - Restore a particular file/directory;
  - Restore a file or list of files by the associated message or by the backup number
- Add -l/--list-log option to print the contents of the .backups/backup.log file
  - By default print, e.g. last 10 entries;
  - Take an extra option to specify number of last backups to be printed;
  - Understand the `all` keyword
- Add -f/--fix-log option to clear the log of backup files/dirs that aren't present anymore (were removed manually?)
- Add -c/--clear option to remove backups
  - Understand `old` keyword that will remove old backups of the same file/dir
- Handle 'backup dir1/subdir' and 'backup dir3/subdir' (currently both will be named as subidr.backup.date). Use full path in the backup file name? Change 'dir1/subdir' to 'dir1.subdir'? => backup_name=".backups/$(echo "$arg" | remove_leading_and_trailing_slash | tr "/" ".").backup.$now_time"
