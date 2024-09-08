#!/bin/bash

# Configuración predeterminada
GITHUB_USERNAME=${GITHUB_USERNAME:-"your_github_username"}
GITHUB_TOKEN=${GITHUB_TOKEN:-"your_github_token"}
MIN_README_SIZE=${MIN_README_SIZE:-200} # Tamaño mínimo en bytes
CHECK_PRIVATE_REPOS=${CHECK_PRIVATE_REPOS:-false}
API_URL="https://api.github.com"

source ./check-github-readmes.env

# Verifica si el token de GitHub está configurado
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Error: Debes configurar la variable de entorno GITHUB_TOKEN con un token de acceso de GitHub."
    exit 1
fi

# Función para verificar el tamaño del README.md de un repositorio
check_readme_size() {
    local repo_name="$1"
    local readme_url="$2"
    
    # Obtener el tamaño del README.md
    readme_size=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$readme_url" | jq -r '.size')

    if [[ "$readme_size" -lt "$MIN_README_SIZE" ]]; then
        echo "Repository '$repo_name' has a README.md file smaller than $MIN_README_SIZE bytes ($readme_size bytes)."
    fi
}

# Obtener la lista de repositorios
get_repositories() {
    local visibility="public"
    
    if [[ "$CHECK_PRIVATE_REPOS" == "true" ]]; then
        visibility="all"
    fi
    
    repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_URL/user/repos?visibility=$visibility&per_page=100")

    echo "$repos" | jq -r '.[] | "\(.name) \(.owner.login) \(.default_branch)"'
}

# Main
echo "Checking repositories for README.md size..."

# Obtener la lista de repositorios y verificar cada uno
repositories=$(get_repositories)

while IFS= read -r repo; do
    repo_name=$(echo "$repo" | awk '{print $1}')
    repo_owner=$(echo "$repo" | awk '{print $2}')
    default_branch=$(echo "$repo" | awk '{print $3}')
    contents_url="https://api.github.com/repos/$repo_owner/$repo_name/contents/README.md?ref=$default_branch"

    # Verifica que no estén vacíos
    if [[ -n "$repo_name" && -n "$contents_url" ]]; then
        check_readme_size "$repo_name" "$contents_url"
    fi
done <<< "$repositories"

echo "Done."
