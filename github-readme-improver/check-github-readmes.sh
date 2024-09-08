#!/bin/bash

# Default configuration
GITHUB_USERNAME=${GITHUB_USERNAME:-"your_github_username"}
GITHUB_TOKEN=${GITHUB_TOKEN:-"your_github_token"}
MIN_README_SIZE=200 # Default minimum size in bytes
CHECK_PRIVATE_REPOS=${CHECK_PRIVATE_REPOS:-false}
API_URL="https://api.github.com"

# Configuration path
CONFIG_DIR="$HOME/.config/scripting-tools"
CONFIG_FILE="$CONFIG_DIR/check-github-readmes.env"

# Function to load configuration from env file
load_config() {
    # Create config directory if it does not exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi

    # If the config file does not exist in the config directory, copy from the local directory if available
    if [[ ! -f "$CONFIG_FILE" ]]; then
        if [[ -f "./check-github-readmes.env" ]]; then
            cp ./check-github-readmes.env "$CONFIG_FILE"
            echo "Config file copied to $CONFIG_FILE."
        else
            # Create a default config file
            cat <<EOF > "$CONFIG_FILE"
GITHUB_USERNAME="your_github_username"
GITHUB_TOKEN="your_github_token"
MIN_README_SIZE=200
CHECK_PRIVATE_REPOS=false
EOF
            echo "Default config file created at $CONFIG_FILE."
        fi
    fi

    # Source the configuration file
    source "$CONFIG_FILE"
}

# Load the configuration
load_config

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --min-bytes <SIZE>       Set the minimum size for README.md files in bytes (default: 200)"
    echo "  -f, --filter <TYPE>      Filter repositories by type: 'own' (owned by user) or 'forks' (forked repositories)"
    echo "  -h, --help               Show this help message and exit"
}

# Check if GitHub token is set
if [[ -z "$GITHUB_TOKEN" || "$GITHUB_TOKEN" == "your_github_token" ]]; then
    echo "Error: You must set the GITHUB_TOKEN environment variable with a valid GitHub access token in $CONFIG_FILE."
    exit 1
fi

# Function to check the size of README.md of a repository
check_readme_size() {
    local repo_name="$1"
    local readme_url="$2"
    
    # Get README.md size
    readme_size=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$readme_url" | jq -r '.size // 0')

    if [[ "$readme_size" -lt "$MIN_README_SIZE" ]]; then
        echo "Repository '$repo_name' has a README.md file smaller than $MIN_README_SIZE bytes ($readme_size bytes)."
    fi
}

# Fetch the list of repositories
get_repositories() {
    local visibility="public"
    local filter_type="$1"
    
    if [[ "$CHECK_PRIVATE_REPOS" == "true" ]]; then
        visibility="all"
    fi

    # Fetch repositories with filters
    repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_URL/user/repos?visibility=$visibility&per_page=100")
    
    # Check for valid JSON response
    if ! echo "$repos" | jq empty >/dev/null 2>&1; then
        echo "Error fetching repositories. Please check your network connection and GitHub token."
        exit 1
    fi
    
    # Filter repositories based on user input
    if [[ "$filter_type" == "own" ]]; then
        echo "$repos" | jq -r '.[] | select(.owner.login == "'"$GITHUB_USERNAME"'") | "\(.name) \(.owner.login) \(.default_branch)"'
    elif [[ "$filter_type" == "forks" ]]; then
        echo "$repos" | jq -r '.[] | select(.fork == true) | "\(.name) \(.owner.login) \(.default_branch)"'
    else
        echo "$repos" | jq -r '.[] | "\(.name) \(.owner.login) \(.default_branch)"'
    fi
}

# Install autocompletion if not already installed
install_autocompletion() {
    local autocomplete_script="/etc/bash_completion.d/check_github_readmes_autocomplete.sh"
    
    if [ ! -f "$autocomplete_script" ]; then
        echo "Installing autocompletion for check-github-readmes..."
        cat <<EOF | sudo tee "$autocomplete_script" > /dev/null
#!/bin/bash

_check_github_readmes_autocomplete() {
    local cur opts
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    opts="--min-bytes -f --filter -h --help own forks"

    if [[ \${cur} == -* ]]; then
        COMPREPLY=( \$(compgen -W "\${opts}" -- \${cur}) )
    elif [[ \${COMP_CWORD} -gt 1 && "\${COMP_WORDS[COMP_CWORD-1]}" == "-f" ]]; then
        COMPREPLY=( \$(compgen -W "own forks" -- \${cur}) )
    fi

    return 0
}

complete -F _check_github_readmes_autocomplete check-github-readmes
EOF
        echo "Autocompletion installed. Reload your shell or run 'source ~/.bashrc' to enable it."
    fi
}

# Main
filter_type=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --min-bytes)
            shift
            MIN_README_SIZE="$1"
            ;;
        -f|--filter)
            shift
            filter_type="$1"
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Ensure the script is copied to /usr/local/bin if not already there
if [ ! -f "/usr/local/bin/check-github-readmes" ]; then
    sudo cp "$0" /usr/local/bin/check-github-readmes
    sudo chmod +x /usr/local/bin/check-github-readmes
    echo "Script copied to /usr/local/bin for global usage."
fi

# Install autocompletion if needed
install_autocompletion

echo "Checking repositories for README.md size..."

# Get the list of repositories and check each one
repositories=$(get_repositories "$filter_type")

while IFS= read -r repo; do
    repo_name=$(echo "$repo" | awk '{print $1}')
    repo_owner=$(echo "$repo" | awk '{print $2}')
    default_branch=$(echo "$repo" | awk '{print $3}')
    contents_url="https://api.github.com/repos/$repo_owner/$repo_name/contents/README.md?ref=$default_branch"

    # Check if not empty
    if [[ -n "$repo_name" && -n "$contents_url" ]]; then
        check_readme_size "$repo_name" "$contents_url"
    fi
done <<< "$repositories"

echo "Done."
