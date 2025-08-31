## Custom prompt

autoload -Uz vcs_info
zstyle  ':vcs_info:*' enable git svn hg p4
zstyle  ':vcs_info:*' max-exports 5
zstyle  ':vcs_info:*' get-revision true
zstyle  ':vcs_info:*' check-for-changes true
#zstyle ":vcs_info:*" actionformats "%F{red}(%b)%f"
zstyle ':vcs_info:*' formats '%s' '%b'
zstyle ':vcs_info:*' actionformats '%s' '%b' '%a'

precmd() {
	vcs_info
}

function parse_git_status {
	local g_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	local g_upstream=$(git rev-parse --abbrev-ref @{upstream} 2> /dev/null)

	if [[ -n $g_upstream ]]; then
		local g_status=$(git status --porcelain 2> /dev/null)
		local g_short_sha=$(git rev-parse --short HEAD 2> /dev/null)

		local branch_msg="%F{red}${g_branch}*%f"
		if [[ $g_status == "" ]]; then
			branch_msg="%F{green}${g_branch}%f"
		fi
	else
		branch_msg="%F{magenta}${g_branch}%f"
	fi

	status_msg+=" on (git  ${branch_msg}" # @%F{magenta}${g_short_sha}%f"

	# Remote
	if [[ -n $g_upstream ]]; then
		local remotes="$(git remote | tr -s ' ')"
		if [[ -n $remotes ]]; then
			while read -r remote; do
				if git rev-parse --verify --quiet ${remote}/${g_branch} &> /dev/null; then
					rev_parse=$(git rev-list --left-right --count ${remote}/${g_branch}..${g_branch})
					if [[ $? -eq 0 ]]; then
						behind_ahead=($rev_parse)
						behind=${behind_ahead[0]}
						ahead=${behind_ahead[2]}
						if [[ $behind > 0 || $ahead > 0 ]]; then
							status_msg+=" 󰒍 ${remote}%F{red}↓${behind}%f %F{green}↑${ahead}%f "
						else
							status_msg+=" 󰒍 ${remote} %F{green}✔%f "
						fi
					fi
				fi
			done <<< "$remotes"
		fi
	else
		status_msg+=" 󰒎 untracked"
	fi

	status_msg+=") "
}

function make_vcs_message {
	local status_msg=""
	if [[ ! -n $vcs_info_msg_0_ ]]; then
		return 1
	fi

	if [[ $vcs_info_msg_0_ == "git" ]]; then
		parse_git_status $vcs_info_msg_2_
	else
		status_msg=" on (${vcs_info_msg_0_}  %F{red}${vcs_info_msg_1_}%f) "
	fi
	if [[ -n $vcs_info_msg_3_ ]]; then
		status_msg="${status_msg}[%F{red}${vcs_info_msg_3_}%f] "
	fi
	echo $status_msg
}

setopt prompt_subst

NEWLINE=$'\n'
PS1='%F{green}%n%f@%F{yellow}%m%f in %F{cyan}%~%f$(make_vcs_message)  %* ${NEWLINE}λ '
