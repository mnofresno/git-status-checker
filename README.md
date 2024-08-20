# Git Repository Status Checker

This project provides a simple Bash script to check the status of multiple Git repositories within a specified directory. The script displays the status of each repository in a clean, easy-to-read table format, and provides a summary of the statuses at the end.

## Features

- **Checks Git Status**: The script inspects the status of each Git repository in a target directory and classifies them as `Clean`, `Dirty`, or `Stagging`.
- **Tabular Output**: The script outputs the results in a formatted table for easy readability.
- **Summary**: A summary section at the end shows the total count of repositories in each status.

## Usage

1. Clone or download this repository.
2. Navigate to the directory containing the script.
3. Run the script with the target directory as an argument:

    ```bash
    ./bin/check_git_status /path/to/target/directory
    ```

    If no directory is specified, the script will use the current directory (`.`) as the target.

## Output

The script outputs a table with the following columns:

- **Repository**: The name of the Git repository.
- **Status**: The status of the repository:
  - `Clean`: No changes.
  - `Dirty`: Unstaged changes detected.
  - `Stagging`: Changes staged for commit.
- **Changes #**: The number of changes detected in the repository.

At the end, a summary of the number of repositories in each status is displayed.

## Example

Here's an example of the output:

```
+----------------------------+----------------+-----------+
| Repository                 | Status         | Changes # |
+----------------------------+----------------+-----------+
| repo1                      | Clean          | 0         |
| repo2                      | Dirty          | 3         |
| repo3                      | Stagging       | 2         |
+----------------------------+----------------+-----------+

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
