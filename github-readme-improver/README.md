# GitHub README Quality Checker

This script is a Bash tool designed to check and improve the quality of `README.md` files for all repositories associated with a GitHub account. It helps ensure that all repositories have sufficiently informative `README.md` files by verifying that they meet a minimum size requirement and can automatically generate better `README.md` files using OpenAI.

## Features

- **Check README Size**: Automatically checks the size of `README.md` files for all repositories associated with a GitHub user account.
- **Improve README Content**: Uses OpenAI's API to automatically generate a more informative and comprehensive `README.md` file for a repository.
- **Configurable Minimum Size**: Set a minimum size requirement for `README.md` files to help ensure comprehensive documentation.
- **Supports Private Repositories**: Optionally include private repositories in the check.
- **Filter Repositories**: Filter repositories by type, such as "own" (owned by user) or "forks" (forked repositories).
- **Configurable Context for Improvements**: Set the maximum size for files to be included as context when generating an improved `README.md`.
- **Automated Push to GitHub**: Automatically commits and offers to push changes to GitHub after improving a `README.md`.
- **Handles Errors Gracefully**: Provides clear error messages for missing credentials, API issues, or missing `README.md` files.
- **Bash Autocompletion**: Automatically installs bash autocompletion for ease of use.

## Requirements

- **Bash**: A Unix-like shell.
- **GitHub Personal Access Token**: Required to access the GitHub API.
- **OpenAI API Key**: Required to access OpenAI's API for improving `README.md` files.
- **jq**: A lightweight and flexible command-line JSON processor. Install it with:
  ```bash
  sudo apt-get install jq  # On Debian/Ubuntu
  sudo yum install jq      # On CentOS/RHEL
  brew install jq          # On macOS
  ```
- **git**: Required for cloning repositories and making changes.

## Installation

You can download the script directly from this repository using `curl`:

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/scripting-tools/master/github-readme-improver/check-github-readmes.sh -o /usr/local/bin/check-github-readmes && sudo chmod +x /usr/local/bin/check-github-readmes
```

## Configuration

1. **GitHub Access Token**: The script requires a GitHub Personal Access Token to access the GitHub API. Set up the token in an environment variable:

    ```bash
    export GITHUB_TOKEN="your_github_token"
    ```

   - You can create a token by navigating to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens).

2. **GitHub Username**: Set your GitHub username as an environment variable:

    ```bash
    export GITHUB_USERNAME="your_github_username"
    ```

3. **OpenAI API Key**: The script also requires an OpenAI API key to generate improved `README.md` files. Set up the key in an environment variable:

    ```bash
    export OPENAI_API_KEY="your_openai_api_key"
    ```

4. **Optional Configuration**:
   - **Minimum README Size**: Set the minimum size for `README.md` files in bytes (default is 200 bytes):

      ```bash
      export MIN_README_SIZE=200
      ```
   
   - **Check Private Repositories**: Include private repositories in the check by setting the following environment variable:

      ```bash
      export CHECK_PRIVATE_REPOS=true
      ```
   
   - **Context Max Size**: Set the maximum size for files to be included as context when generating an improved `README.md` (default is 1000 bytes):

      ```bash
      export CONTEXT_MAX_BYTES=1000
      ```

## Usage

After setting up your environment variables, you can run the script as follows:

```bash
check-github-readmes
```

### Options

- `--min-bytes <SIZE>`: Set the minimum size for `README.md` files in bytes (default: 200).
- `-f, --filter <TYPE>`: Filter repositories by type: `own` (owned by user) or `forks` (forked repositories).
- `--improve <REPO_NAME>`: Improve the `README.md` for a specific repository using OpenAI.
- `--context-max-bytes <SIZE>`: Set the maximum size for files to be included as context (default: 1000 bytes).
- `-h, --help`: Show the help message and usage instructions.

### Example Output

When you run the script, it will check each repository and display the result:

```bash
Checking repositories for README.md size...
Repository 'my-awesome-repo' has a README.md file smaller than 200 bytes (150 bytes).
Repository 'another-repo' has a sufficient README.md file size (350 bytes).
Repository 'secret-repo' does not have a README.md file.
Done.
```

### Improving All Repositories

To improve all repositories with `README.md` files that do not meet the size requirement, you can use the following combined command:

```bash
./check-github-readmes.sh | grep "Repository '" | awk -F"'" '{print $2}' | while read repo; do ./check-github-readmes.sh --improve "$repo"; done
```

This command will automatically attempt to improve the `README.md` files of all repositories with insufficient documentation, as listed by the `check-github-readmes.sh` script.

### Error Handling

- **Invalid GitHub Token**: If the provided GitHub token is invalid, the script will display an error message and exit.
- **Invalid OpenAI API Key**: If the provided OpenAI API key is invalid, the script will display an error message and exit.
- **No README.md Found**: If a repository does not have a `README.md` file, the script will display a message indicating this.
- **Network or API Issues**: The script checks for potential API issues and provides appropriate feedback.

## Contributing

Contributions are welcome! If you have ideas for improvements or new features, feel free to fork the repository and submit a pull request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

For any questions, issues, or feedback, please open an issue in this repository.
