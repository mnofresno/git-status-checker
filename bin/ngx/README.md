# Nginx Site Management Scripts (`ngxen` and `ngxdis`)

These scripts, `ngxen` and `ngxdis`, allow you to easily enable or disable Nginx sites by creating or removing symbolic links in the `sites-enabled` directory.

## Installation

You can install the `ngxen` and `ngxdis` scripts directly from this repository using `curl` and `bash`. **Ensure you run these commands with `sudo` to allow them to install properly:**

### Install `ngxen`

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxensite | bash
```

### Install `ngxdis`

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxdissite | bash
```

## Usage

### Enabling a Site

To enable a site, run:

```bash
sudo ngxen <site-name>
```

Replace `<site-name>` with the name of the site configuration file in `/etc/nginx/sites-available`.

### Disabling a Site

To disable a site, run:

```bash
sudo ngxdis <site-name>
```

Replace `<site-name>` with the name of the site configuration file in `/etc/nginx/sites-enabled`.

### Autocompletion

To set up autocompletion for both scripts, use the `--autocomplete` option:

#### Autocomplete for `ngxen`

```bash
sudo ngxen --autocomplete
```

This command will generate and install the autocompletion script for `ngxen` so that you can use the Tab key to autocomplete available site names from `/etc/nginx/sites-available`.

#### Autocomplete for `ngxdis`

```bash
sudo ngxdis --autocomplete
```

This command will generate and install the autocompletion script for `ngxdis` so that you can use the Tab key to autocomplete enabled site names from `/etc/nginx/sites-enabled`.

### Notes

- You must run these scripts with `sudo` to have the necessary permissions to create or remove symbolic links in `/etc/nginx/sites-enabled/`.
- After running the autocompletion setup, make sure to open a new terminal session or reload your current one with `source ~/.bashrc` for the changes to take effect.

## License

This project is licensed under the MIT License.

For more information, check out the [repository on GitHub](https://github.com/mnofresno/git-status-checker).
