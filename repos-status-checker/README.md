# Git Repository Status Checker

This project provides a simple Bash script to check the status of multiple Git repositories within a specified directory. The script displays the status of each repository in a clean, easy-to-read table format and provides a summary of the statuses at the end. It also includes features for filtering, help options, and autocompletion.

## Features

- **Checks Git Status**: The script inspects the status of each Git repository in a target directory and classifies them as `Clean`, `Dirty`, or `Stagging`.
- **Filtering**: You can filter the output to show only repositories in a specific status (`Clean`, `Dirty`, or `Stagging`) using the `-f` option.
- **Help Option**: Provides a `-h` or `--help` option to display usage instructions.
- **Tabular Output**: The script outputs the results in a formatted table for easy readability.
- **Summary**: A summary section at the end shows the total count of repositories in each status.
- **Autocompletion**: Bash autocompletion is supported for the script's options, making it easier to use. The autocompletion is installed automatically the first time the script is run.

## Installation

You can install the `check_git_status` script directly from this repository using `curl`. **Ensure you run these commands with `sudo` to allow them to install properly:**

### Install `check_git_status`

To install `check_git_status` directly from the repository, run:

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/check_git_status.sh -o /usr/local/bin/check_git_status && sudo chmod +x /usr/local/bin/check_git_status
```

This command will download the script and install it in `/usr/local/bin/check_git_status`, making it available system-wide. The first time you run the script, it will automatically install the autocompletion if it is not already installed.

## Usage

1. After installation, you can use the script by specifying the target directory:

    ```bash
    check_git_status /path/to/target/directory
    ```

    If no directory is specified, the script will use the current directory (`.`) as the target.

### Options

- `-f [Dirty|Stagging|Clean]`: Filter the repositories by their status. For example, `-f Dirty` will display only repositories with unstaged changes.
- `-h`, `--help`: Show the help message and usage instructions.

### Examples

1. **Check all repositories in a directory:**

    ```bash
    check_git_status /path/to/target/directory
    ```

2. **Filter to show only Dirty repositories:**

    ```bash
    check_git_status /path/to/target/directory -f Dirty
    ```

3. **Show help message:**

    ```bash
    check_git_status -h
    ```

## Autocompletion

The script automatically installs autocompletion the first time it is run. This enables autocompletion for options such as `-f Dirty`, `-f Stagging`, `-f Clean`, `-h`, and `--help`.

If you need to manually reload the autocompletion scripts after the installation, you can do so with:

```bash
source /etc/bash_completion.d/check_git_status_autocomplete.sh
```

## Output

The script outputs a table with the following columns:

- **Repository**: The name of the Git repository.
- **Status**: The status of the repository:
  - `Clean`: No changes.
  - `Dirty`: Unstaged changes detected.
  - `Stagging`: Changes staged for commit.
- **Changes #**: The number of changes detected in the repository.
- **Last Commit Author Email**: The email of the author of the last commit (if available).

At the end, a summary of the number of repositories in each status is displayed.

## Example

Here's an example of the output:

```
+----------------------------+----------------+-----------+----------------------------+
| Repository                 | Status         | Changes # | Last Commit Author Email   |
+----------------------------+----------------+-----------+----------------------------+
| repo1                      | Clean          | 0         |                            |
| repo2                      | Dirty          | 3         | user@example.com           |
| repo3                      | Stagging       | 2         | anotheruser@example.com    |
+----------------------------+----------------+-----------+----------------------------+

Summary:
+-----------+-------+
| Status    | Count |
+-----------+-------+
| Clean     |     1 |
| Dirty     |     1 |
| Stagging  |     1 |
+-----------+-------+
```

## Requirements

- Bash shell
- Git installed on your system

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! If you have ideas for improvements or new features, feel free to fork the repository and submit a pull request.

## Contact

For any questions or feedback, feel free to open an issue in this repository.