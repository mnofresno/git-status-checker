#!/usr/bin/env bash

check_root() {
    if [ $EUID -ne 0 ]; then
        echo "You must be root: \"sudo $1\""
        exit 1
    fi
}

install_script() {
    local script_name=$1
    local install_path=$2
    local remote_url=$3

    if [ ! -f "$install_path" ]; then
        echo "Installing $script_name to $install_path..."
        curl -s "$remote_url" -o "$install_path"
        chmod +x "$install_path"
        echo "Installation complete."
    else
        echo "$script_name is already installed in $install_path."
    fi
}

upgrade_script() {
    local script_name=$1
    local install_path=$2
    local remote_url=$3

    TEMP_FILE=$(mktemp)
    curl -s "$remote_url" -o "$TEMP_FILE"

    if [ ! -f "$install_path" ]; then
        echo "$script_name is not installed. Run with --install first."
        rm "$TEMP_FILE"
        exit 1
    fi

    LOCAL_HASH=$(md5sum "$install_path" | awk '{print $1}')
    REMOTE_HASH=$(md5sum "$TEMP_FILE" | awk '{print $1}')

    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo "Updating $script_name as the remote version has changed..."
        mv "$TEMP_FILE" "$install_path"
        chmod +x "$install_path"
        echo "Upgrade complete."
    else
        echo "$script_name is up to date."
        rm "$TEMP_FILE"
    fi
}

generate_autocomplete() {
    local script_name=$1
    local available_path=$2

    cat <<EOF >/etc/bash_completion.d/$script_name
_${script_name}_autocomplete() {
    local cur=\${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=(\$(compgen -W "\$(ls $available_path)" -- \${cur}))
    return 0
}
complete -F _${script_name}_autocomplete $script_name
EOF
    echo "Autocomplete script for $script_name has been generated and installed."
    source /etc/bash_completion.d/$script_name
}

reload_nginx() {
    echo "Reloading NGINX config..."
    service nginx reload
    echo "NGINX config reloaded!"
}