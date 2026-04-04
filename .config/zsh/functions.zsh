# Load a plugin. If the plugin is not locally found, try and find it from github
# Usage: load_plugin org_name plugin_name [zsh_file_name]
function load_plugin {
	if [[ -z $1 || -z $2 ]]; then
		echo "Usage: load_plugin org_name plugin_name [zsh_file_name]"
		return 1
	fi
	local org_name=$1
	local plugin_name=$2
	local file_to_load=${3:-$plugin_name}
	if [[ ! -d $XDG_DATA_HOME/zsh/plugins/$plugin_name ]]; then
		git clone https://github.com/$org_name/$plugin_name $XDG_DATA_HOME/zsh/plugins/$plugin_name
		if [[ ! $? -eq 0 ]]; then
			echo "Failed to clone plugin $org_name/$plugin_name"
			return 1
		fi
	fi

	if [[ -d $XDG_DATA_HOME/zsh/plugins/$plugin_name ]]; then
		if [[ -f $XDG_DATA_HOME/zsh/plugins/$plugin_name/$file_to_load.zsh ]]; then
			source $XDG_DATA_HOME/zsh/plugins/$plugin_name/$file_to_load.zsh
		else
			echo "Plugin $org_name/$plugin_name does not have a file $file_to_load.zsh"
			return 1
		fi
	else
		echo "Plugin $org_name/$plugin_name does not exist"
		return 1
	fi
}

function load_file {
	if [[ -z $1 ]]; then
		echo "Usage: load_file file_name"
		return 1
	fi
	local file_name=$XDG_CONFIG_HOME/zsh/$1
	if [[ -f $file_name ]]; then
		source $file_name
	else
		echo "File $file_name does not exist"
		return 1
	fi
}
