# Name of the commande you'd like to use on the command line
command_name=activate

__activate_virtualenv () {
    if [ "$#" -ne 1 ]; then
        echo "Error: Illegal number of arguments. The command takes exactly 1 argument."
        echo "Try 'activate -h' for more information."
    else
        case $1 in
            '--help'|'-h')
                echo "Usage: activate DIRECTORY-NAME"
                echo -e "Activate Python virtual environment for the given directory.\n"
            ;;
            -*) # Catching any arguments beginning with a dash (-)
                echo "Error: $1 option doesn't exist."
                echo "Try 'activate -h' for more information."
            ;;
            *)
                activate_script_path="$(readlink -f $1)/bin/activate"
                if [ ! -f $activate_script_path ]; then
                    echo "Error: virtualenv file $activate_script_path doesn't exist."
                    echo "Wrong directory name?"
                else
                    source $activate_script_path
                fi
            ;;
        esac
    fi
}

alias $command_name=__activate_virtualenv
