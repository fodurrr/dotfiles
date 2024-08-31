> Credit: https://devopstoolkit.live/terminal/master-your-new-laptop-setup-tools-configs-and-secrets/

# My Devops starter toolkit

### Create backup of your old configs

```bash
mv ~/.zshrc ~/.zshrc-orig

mv ~/.config/starship.toml ~/.config/starship.toml-orig

mv ~/.config/fabric ~/.config/fabric-orig
```

### Installation

```bash
cd ~/

git clone https://github.com/fodurrr/dotfiles

cd dotfiles

chmod +x install.sh

./install.sh

# Change default shell
chsh -s $(which zsh)

# start a new shell
```

### Enter into your new devbox shell

```bash
# Make sure you are in the dotfiles folder, tools will be available only when
# you start the `devbox shell` in `~/dotfiles` folder because the `devbox.json` is in there.
# This will install first time NIX and all tools according to the devbox.json
cd ~/dotfiles
devbox shell
```

### Syncronize your configs and `source` your shell

```bash
chmod +x sync.sh

./sync.sh

source ~/.zshrc
```

# Post-install

## Setup `fabric` AI tool

```bash
# Install Fabric directly from the repo
go install github.com/danielmiessler/fabric@latest
go install github.com/danielmiessler/yt@latest

# Run the setup to set up your directories and keys
fabric --setup
```

### Destroy

> Ignore errors in the commands that follow.

```bash
mv ~/.zshrc-orig ~/.zshrc

mv ~/.config/starship.toml-orig ~/.config/starship.toml

mv ~/.config/fabric-orig ~/.config/fabric
```
