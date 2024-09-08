# Nginx Site Management Scripts (`ngxensite` and `ngxdissite`)

These scripts, `ngxensite` and `ngxdissite`, allow you to easily enable or disable Nginx sites by creating or removing symbolic links in the `sites-enabled` directory, along with additional features for installation, upgrading, and autocompletion.

## Installation

You can install the `ngxensite` and `ngxdissite` scripts directly from this repository using `curl` and `bash`. **Ensure you run these commands with `sudo` to allow them to install properly:**

### Install `ngxensite`

To install `ngxensite` directly from the repository, run:

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxensite | sudo bash -s -- --install
```

### Install `ngxdissite`

To install `ngxdissite` directly from the repository, run:

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxdissite | sudo bash -s -- --install
```

## Upgrading the Scripts

To upgrade `ngxensite` or `ngxdissite` to the latest version available in the repository, use the `--upgrade` option with `curl` and `bash`:

### Upgrade `ngxensite`

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxensite | sudo bash -s -- --upgrade
```

### Upgrade `ngxdissite`

```bash
sudo curl -s https://raw.githubusercontent.com/mnofresno/git-status-checker/master/bin/ngx/ngxdissite | sudo bash -s -- --upgrade
```

These commands will download the latest version of the script from the repository if the remote version is different from the installed one, ensuring you always have the most recent updates.

## Usage

### Enabling a Site

To enable a site, run:

```bash
sudo ngxensite <site-name>
```

Replace `<site-name>` with the name of the site configuration file in `/etc/nginx/sites-available`. This will create a symbolic link in `/etc/nginx/sites-enabled/` and reload Nginx to apply the changes.

### Disabling a Site

To disable a site, run:

```bash
sudo ngxdissite <site-name>
```

Replace `<site-name>` with the name of the site configuration file in `/etc/nginx/sites-enabled`. This will remove the symbolic link and reload Nginx to apply the changes.

### Autocompletion

Both scripts support autocompletion, allowing you to quickly autocomplete available or enabled site names using the Tab key. 

#### Set Up Autocompletion for `ngxensite`

```bash
sudo ngxensite --autocomplete
```

This command will generate and install the autocompletion script for `ngxensite`, enabling tab completion for available site names in `/etc/nginx/sites-available`.

#### Set Up Autocompletion for `ngxdissite`

```bash
sudo ngxdissite --autocomplete
```

This command will generate and install the autocompletion script for `ngxdissite`, enabling tab completion for enabled site names in `/etc/nginx/sites-enabled`.

### Installation and Autocompletion Setup

When running the `--install` or `--upgrade` commands, the scripts will automatically handle:

- Downloading and installing the latest version.
- Setting up or refreshing autocompletion.
- Verifying if the common library `ngx_common.sh` is present and downloading it if needed.

### Reloading Nginx

Both `ngxensite` and `ngxdissite` automatically reload Nginx after enabling or disabling a site to apply the changes. This functionality is provided by a common function `reload_nginx` included in the shared library `ngx_common.sh`.

### Notes

- You must run these scripts with `sudo` to have the necessary permissions to create or remove symbolic links in `/etc/nginx/sites-enabled/`.
- After running the autocompletion setup, make sure to open a new terminal session or reload your current one with `source ~/.bashrc` or `source ~/.zshrc` for the changes to take effect.
- Ensure that the library file `ngx_common.sh` is properly installed in `/usr/local/lib` as it contains shared functions required by both scripts.

## License

This project is licensed under the MIT License.

For more information, check out the [repository on GitHub](https://github.com/mnofresno/git-status-checker).