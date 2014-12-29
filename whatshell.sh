# # # # # # # # # # # # # # # # # # # # # # # # # #
# 1. An example of interactive login shell:
#	su - username
#	source whatshell.sh
#	whatshell
#
# 2. An example of interactive non-login shell:
#	su username
#	source whatshell.sh
#	whatshell
#
# 3. An example of non-interactive non-login shell:
#	bash -c "source whatshell.sh; whatshell"
# # # # # # # # # # # # # # # # # # # # # # # # # #


function whatshell() {
	[[ $- == *i* ]] && intershell='Interactive' || intershell='Non-interactivel'
	shopt -q login_shell && loginshell='login shell' || loginshell='non-login shell'
	echo "$intershell $loginshell"
}
