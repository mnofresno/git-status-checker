# GitHub README Size Checker

This script is a simple Bash tool that checks the size of the `README.md` files for all repositories associated with a GitHub account. It helps ensure that all repositories have sufficiently informative `README.md` files by verifying that they meet a minimum size requirement.

## Features

- **Check README Size**: Automatically checks the size of `README.md` files for all repositories associated with a GitHub user account.
- **Configurable Minimum Size**: Set a minimum size requirement for `README.md` files to help ensure comprehensive documentation.
- **Supports Private Repositories**: Optionally include private repositories in the check.
- **Uses GitHub API**: Leverages the GitHub API to fetch repository information and `README.md` sizes securely.
- **Handles Errors Gracefully**: Provides clear error messages for missing credentials, API issues, or missing `README.md` files.

## Requirements

- **Bash**: A Unix-like shell.
- **GitHub Personal Access Token**: Required to access the GitHub API.
- **jq**: A lightweight and flexible command-line JSON processor. Install it with:
  ```bash
  sudo apt-get install jq  # On Debian/Ubuntu
  sudo yum install jq      # On CentOS/RHEL
  brew install jq          # On macOS
  ```

## Installation

You can download the script directly from this repository using `curl`:

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/check-github-readmes.sh -o /usr/local/bin/check-github-readmes && sudo chmod +x /usr/local/bin/check-github-readmes
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

3. **Optional Configuration**:
   - **Minimum README Size**: Set the minimum size for `README.md` files in bytes (default is 200 bytes):

      ```bash
      export MIN_README_SIZE=200
      ```
   
   - **Check Private Repositories**: Include private repositories in the check by setting the following environment variable:

      ```bash
      export CHECK_PRIVATE_REPOS=true
      ```

## Usage

After setting up your environment variables, you can run the script as follows:

```bash
check-github-readmes
```

### Options

- The script uses environment variables for configuration. Make sure to set the necessary variables as described in the **Configuration** section.

### Example Output

When you run the script, it will check each repository and display the result:

```bash
Checking repositories for README.md size...
Repository 'my-awesome-repo' has a README.md file smaller than 200 bytes (150 bytes).
Repository 'another-repo' has a sufficient README.md file size (350 bytes).
Repository 'secret-repo' does not have a README.md file.
Done.
```

## Error Handling

- **Invalid GitHub Token**: If the provided GitHub token is invalid, the script will display an error message and exit.
- **No README.md Found**: If a repository does not have a `README.md` file, the script will display a message indicating this.
- **Network or API Issues**: The script checks for potential API issues and provides appropriate feedback.

## Contributing

Contributions are welcome! If you have ideas for improvements or new features, feel free to fork the repository and submit a pull request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

For any questions, issues, or feedback, please open an issue in this repository.