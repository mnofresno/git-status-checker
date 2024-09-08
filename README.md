# Scripting Tools

This repository contains a collection of useful Bash scripts to automate common tasks for developers, such as managing Nginx sites, checking GitHub repositories, and monitoring the status of local Git repositories. Each tool is organized into its own directory with a detailed README explaining its usage, configuration, and installation.

## Contents

### 1. [GitHub README Improver](./github-readme-improver)

A Bash script to check the size of `README.md` files in all repositories associated with a GitHub account. It helps ensure that all repositories have sufficiently informative `README.md` files by verifying that they meet a minimum size requirement.

- **Scripts**:
  - `check-github-readmes.sh`: Main script to check the size of `README.md` files.
  - `check-github-readmes.env`: Example environment configuration file.
- **Features**:
  - Checks the size of `README.md` files.
  - Configurable minimum size.
  - Supports public and private repositories.
- **See the [README](./github-readme-improver/README.md) for more details.**

### 2. [Nginx Site Manager](./nginx-site-manager)

A set of Bash scripts to manage Nginx sites by enabling or disabling site configurations easily.

- **Scripts**:
  - `ngxensite`: Enables a site by creating a symbolic link in the `sites-enabled` directory.
  - `ngxdissite`: Disables a site by removing the symbolic link from the `sites-enabled` directory.
  - `ngx_common.sh`: Shared functions used by both `ngxensite` and `ngxdissite`.
- **Features**:
  - Simplifies enabling and disabling Nginx sites.
  - Automatically reloads Nginx configuration after changes.
  - Supports installation and autocompletion setup.
- **See the [README](./nginx-site-manager/README.md) for more details.**

### 3. [Repos Status Checker](./repos-status-checker)

A Bash script that checks the status of multiple Git repositories within a specified directory, providing an easy-to-read table format of their current status (Clean, Dirty, Stagging).

- **Scripts**:
  - `check_git_status`: Main script to check the status of local Git repositories.
- **Features**:
  - Displays Git repository statuses in a formatted table.
  - Supports filtering by status.
  - Provides a summary of repository statuses.
  - Automatically installs autocompletion.
- **See the [README](./repos-status-checker/README.md) for more details.**

## Installation

For detailed installation instructions, see the README file in each subdirectory.

## Requirements

- **Bash**: A Unix-like shell.
- **jq**: Required for JSON processing in some scripts.
- **GitHub Personal Access Token**: Needed for the GitHub README Improver tool.

## Contributing

Contributions are welcome! Feel free to open issues for feature requests or bugs, and submit pull requests for improvements.

## License

This repository is licensed under the [MIT License](LICENSE).

## Contact

For any questions or feedback, please open an issue in this repository.
