#!/bin/bash

# Default configuration
GITHUB_USERNAME=${GITHUB_USERNAME:-"your_github_username"}
GITHUB_TOKEN=${GITHUB_TOKEN:-"your_github_token"}
OPENAI_API_KEY=${OPENAI_API_KEY:-"your_openai_api_key"}
MIN_README_SIZE=200 # Default minimum size in bytes
CHECK_PRIVATE_REPOS=${CHECK_PRIVATE_REPOS:-false}
API_URL="https://api.github.com"
CONTEXT_MAX_BYTES=1000 # Default max size for file context in bytes

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
OPENAI_API_KEY="your_openai_api_key"
MIN_README_SIZE=200
CHECK_PRIVATE_REPOS=false
CONTEXT_MAX_BYTES=1000
EOF
            echo "Default config file created at $CONFIG_FILE."
        fi
    fi

    # Source the configuration file
    source "$CONFIG_FILE"
}

# Load the configuration
load_config

# Check if required commands are available
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git is required but not installed. Aborting."; exit 1; }

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --min-bytes <SIZE>         Set the minimum size for README.md files in bytes (default: 200)"
    echo "  -f, --filter <TYPE>        Filter repositories by type: 'own' (owned by user) or 'forks' (forked repositories)"
    echo "  --improve <REPO_NAME>      Improve the README.md for a specific repository"
    echo "  --context-max-bytes <SIZE> Set the maximum size for files to be included as context (default: 1000 bytes)"
    echo "  --double-check             Enable double-check mode for context file prioritization"
    echo "  -h, --help                 Show this help message and exit"
}

# Check if GitHub token and OpenAI API key are set
if [[ -z "$GITHUB_TOKEN" || "$GITHUB_TOKEN" == "your_github_token" ]]; then
    echo "Error: You must set the GITHUB_TOKEN environment variable with a valid GitHub access token in $CONFIG_FILE."
    exit 1
fi

if [[ -z "$OPENAI_API_KEY" || "$OPENAI_API_KEY" == "your_openai_api_key" ]]; then
    echo "Error: You must set the OPENAI_API_KEY environment variable with a valid OpenAI API key in $CONFIG_FILE."
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

prioritize_files() {
    local temp_dir="$1"

    # Always include README.md if it exists and is within size limit
    if [[ -f "$temp_dir/README.md" ]]; then
        readme_size=$(stat -c%s "$temp_dir/README.md")
        if [[ "$readme_size" -le "$CONTEXT_MAX_BYTES" ]]; then
            context+="\nFile: README.md\nContents:\n$(cat "$temp_dir/README.md")\n"
        else
            echo -e "\e[31mWARNING: README.md exceeds the context size limit and will be excluded. Aborting to avoid reducing the quality of the improvement.\e[0m"
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        echo -e "\e[33mINFO: README.md not found in the repository. A new README.md will be created.\e[0m"
        # Crear un nuevo README.md con contenido básico
        echo "# $repo_name" > "$temp_dir/README.md"
        echo "This is a newly generated README file for the repository." >> "$temp_dir/README.md"
        context+="\nFile: README.md\nContents:\n$(cat "$temp_dir/README.md")\n"
    fi

    # Include other relevant files
    while IFS= read -r file; do
        file_size=$(stat -c%s "$temp_dir/$file")
        if [[ "$file_size" -le "$CONTEXT_MAX_BYTES" && "$file" != "README.md" ]]; then
            context+="\nFile: $file\nContents:\n$(cat "$temp_dir/$file")\n"
        else
            context+="\nFile: $file (Size: $file_size bytes, skipped due to size limit)\n"
        fi
    done < <(cd "$temp_dir" && git ls-files)
}

# Function to improve the README.md using OpenAI Chat API
improve_readme() {
    local repo_name="$1"
    local double_check="${2:-false}"

    echo "Improving README for repository: $repo_name"

    # Clone the repository to a temporary directory
    temp_dir=$(mktemp -d)
    git clone "git@github.com:$GITHUB_USERNAME/$repo_name.git" "$temp_dir" || { echo "Error: Failed to clone repository. Aborting."; rm -rf "$temp_dir"; exit 1; }

    # Fetch repository description from GitHub
    repo_description=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_URL/repos/$GITHUB_USERNAME/$repo_name" | jq -r '.description // "No description available."')

    # Initialize context with repository description
    context="Repository Description: $repo_description\n\nFile List and Contents:\n"

    # Prioritize files for context inclusion
    prioritize_files "$temp_dir"

    # Build the JSON payload using jq to ensure it is correctly formatted
    json_payload=$(jq -n --arg model "gpt-4o-mini" \
                         --arg content "Improve the README.md for the following repository based on the context provided:\n\n$context. Please provide only the full content of the README.md file without any additional comments or explanations." \
                         '{
                           model: $model,
                           messages: [{"role": "user", "content": $content}],
                           max_tokens: 3000,
                           temperature: 0.5
                         }')

    # Use OpenAI API to generate improved README
    response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$json_payload")

    if [[ $? -ne 0 ]] || [[ -z "$response" ]]; then
        echo "Error: Failed to fetch improved README from OpenAI API. Aborting."
        rm -rf "$temp_dir"
        exit 1
    fi

    # Check for errors in the OpenAI API response
    error_message=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error_message" ]]; then
        echo "OpenAI API Error: $error_message"
        rm -rf "$temp_dir"
        exit 1
    fi

    improved_readme=$(echo "$response" | jq -r '.choices[0].message.content // empty')
    if [[ -z "$improved_readme" ]]; then
        echo "Error: No valid response from OpenAI API. Aborting."
        rm -rf "$temp_dir"
        exit 1
    fi

    # Clean up unwanted formatting markers like ```markdown or ```
    improved_readme=$(echo "$improved_readme" | sed '/^```/d')

    # Get the author from the last commit or from global Git configuration
    cd "$temp_dir"
    commit_author_name=$(git log -1 --pretty=format:'%an' 2>/dev/null || git config --global user.name)
    commit_author_email=$(git log -1 --pretty=format:'%ae' 2>/dev/null || git config --global user.email)

    # Prompt user for confirmation and allow overriding
    read -p "Enter the commit author name ($commit_author_name): " input_author_name < /dev/tty
    commit_author_name=${input_author_name:-$commit_author_name}

    read -p "Enter the commit author email ($commit_author_email): " input_author_email < /dev/tty
    commit_author_email=${input_author_email:-$commit_author_email}

    if [[ -z "$commit_author_name" || -z "$commit_author_email" ]]; then
        echo "Error: Author name and email must be provided. Aborting."
        rm -rf "$temp_dir"
        exit 1
    fi

    # Prompt user for confirmation
    echo "Generated README.md content:"
    echo "$improved_readme"
    # Prompt user for confirmation with 'Y' as the default
    read -p "Do you want to upgrade the README.md? (Y/n) " confirm < /dev/tty
    confirm=${confirm:-Y}  # Set default to 'Y' if empty

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Proceed with upgrading the README.md
        echo "$improved_readme" > "$temp_dir/README.md"
        git config user.name "$commit_author_name"
        git config user.email "$commit_author_email"
        git add README.md
        git commit -m "fix(doc): Auto improve README.md"
        echo "README.md improved and committed."

        # Ask user if they want to push the changes
        read -p "Do you want to push the changes to the remote repository? (Y/n) " push_confirm < /dev/tty
        push_confirm=${push_confirm:-Y}  # Set default to 'Y' if empty

        if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
            git push
            echo "Changes have been pushed to the remote repository."
        else
            echo "Changes have not been pushed. You can push manually by running 'git push' in the repository folder."
        fi
    else
        echo "README.md not upgraded."
    fi

    # Clean up
    rm -rf "$temp_dir"
}

# Fetch the list of repositories
get_repositories() {
    local visibility="public"
    local filter_type="${1:-own}"  # Default to 'own' if no filter is provided
    
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
    opts="--min-bytes -f --filter -h --help own forks --improve --context-max-bytes --double-check"

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
improve_repo=""
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
        --improve)
            shift
            improve_repo="$1"
            ;;
        --context-max-bytes)
            shift
            CONTEXT_MAX_BYTES="$1"
            ;;
        --double-check)
            double_check=true
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

# Improve README if requested
if [[ -n "$improve_repo" ]]; then
    improve_readme "$improve_repo" "$double_check"
    exit 0
fi

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
