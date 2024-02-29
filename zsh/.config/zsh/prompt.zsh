## Custom prompt

autoload -Uz vcs_info
zstyle  ':vcs_info:*' enable git svn hg p4
zstyle  ':vcs_info:*' max-exports 5
zstyle  ':vcs_info:*' get-revision true
zstyle  ':vcs_info:*' check-for-changes true
#zstyle ":vcs_info:*" actionformats "%F{red}(%b)%f"
zstyle ':vcs_info:*' formats '%s' '%b'

precmd() {
	vcs_info
}

function make_vcs_message {
	if [[ -n $vcs_info_msg_0_ ]]; then
		echo " on (${vcs_info_msg_0_}  %F{red}${vcs_info_msg_1_}%f) "
	fi
}

setopt prompt_subst

NEWLINE=$'\n'
PS1='%F{green}%n%f@%F{yellow}%m%f in %F{cyan}%~%f$(make_vcs_message)  %* ${NEWLINE}λ '
