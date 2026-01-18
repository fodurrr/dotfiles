# 🛠️ My Mac Dotfiles

A modern, declarative, and reproducible development environment configuration for macOS (Apple Silicon).

This setup uses **Homebrew** for system packages, **Mise** for dev tools (Node, Python, Go, Rust), and **GNU Stow** to manage configuration files modularly.

## 🚀 Features

* **Package Management:** `Brewfile` tracks all system apps (GUI & CLI), ensuring a one-command setup.
* **Runtime Versioning:** `mise` (formerly rtx) manages language runtimes (Node, Python, Erlang/Elixir, Rust) and CLI tools without shims, keeping the `PATH` clean.
* **Modular Configs:** Uses `stow` to manage dotfiles. Each tool (`zsh`, `git`, `starship`) is its own package, preventing a cluttered home directory.
* **Safe Deployment:** The installer acts as an **Enforcer**—it automatically detects existing local config files and backs them up before linking, ensuring no data is lost.
* **Fast Shell:** Optimized `.zshrc` using **Sheldon** for plugins and **Starship** for a blazing fast prompt.
* **Modern CLI Tools:** Replaces legacy tools with modern Rust-based alternatives (installed via Mise):
    * `ls` → `eza` (Icons, Git status)
    * `cat` → `bat` (Syntax highlighting)
    * `grep` → `ripgrep` (Faster search)

## 📂 Structure

The project is organized into "packages" for `stow`. The install script loops through these folders and symlinks them to your home directory (`~`).

```text
~/dotfiles
├── Brewfile             # List of all Homebrew apps (GUI & CLI)
├── install.sh           # Main setup script (Idempotent & Safe)
├── git/
│   ├── .gitconfig       # User info, aliases, and safest defaults
│   └── .gitignore_global # Global ignores (.DS_Store, .env, etc.)
├── mise/
│   └── .config/
│       └── mise/
│           └── config.toml # Runtime versions (Node lts, Python 3.14, etc.)
├── sheldon/
│   └── .config/
│       └── sheldon/
│           └── plugins.toml # Zsh plugin manager config
├── starship/
│   └── .config/
│       └── starship.toml # High-performance shell prompt config
└── zsh/
    └── .zshrc           # Optimized shell config (Plugins, Aliases)
```

## 📦 Installation

### 1. Fresh Install

Clone this repo to your home directory:

```bash
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

**What the script does:**

1. Installs **Homebrew** (if missing).
2. Installs **Apps & Tools** (includes `mise` CLI, Ghostty, Zed).
3. Installs **Sheldon** plugin manager.
4. **Stows** config files (links configs; **auto-backs up** any conflicting real files).
5. **Downloads Runtimes & Tools** (runs `mise install` to get languages and CLI tools based on the config).
6. Reloads the shell.

### 🛠️ 2. Maintenance (Installing Tools)

Since this setup is declarative, you don't install tools manually. You add them to the config files and run the install script.

#### System Apps & CLI Tools (Homebrew)

**File:** `~/dotfiles/Brewfile`

* **Search:** `brew search <name>`
* **Add:**

```ruby
brew "ripgrep"        # For CLI tools
cask "google-chrome"  # For GUI Applications
```
#### Language Runtimes (Mise)

**File:** `~/dotfiles/mise/.config/mise/config.toml`

* **Search:** `mise ls-remote <tool>`
* **Add:**

```toml
[tools]
node = "lts"
python = "3.14"
```

**Apply Changes:**

```bash
~/dotfiles/install.sh
```

### ⚙️ 3. Managing Configurations (Source of Truth)

We follow a **"Source of Truth"** philosophy. The `~/dotfiles` repo is the master controller. If a tool creates a local config file, we must "capture" it into the repo.

#### How to "Capture" a New Config

When you install a new tool (e.g., `ghostty`) and configure it locally, follow this workflow:

1. **Create the folder structure** inside dotfiles:

```bash
mkdir -p ~/dotfiles/ghostty/.config/ghostty
```

2. **Move the real config** into the repo (this removes the local file):

```bash
mv ~/.config/ghostty/config.toml ~/dotfiles/ghostty/.config/ghostty/
```

3. **Link it back** (test immediately):

```bash
cd ~/dotfiles
stow ghostty
```

4. **Commit changes:**
```bash
git add ghostty
git commit -m "Add ghostty config"
```

#### How the Installer Works ("The Enforcer")

The `install.sh` script enforces the repo's state without destroying data.

* **Scenario A: Fresh Install**
* It sees the target path is empty.
* It creates the symlink.
* ✅ Result: Tool uses repo config.


* **Scenario B: Conflict (Existing Local File)**
* It sees a real file exists (e.g., `~/.zshrc`).
* It **moves** the real file to a backup: `.zshrc.bak`.
* It creates the symlink to the repo version.
* ✅ Result: Repo config wins, local data is preserved.

### 4. Strict Cleanup Mode

To remove any Homebrew apps *not* listed in your `Brewfile` (keeping your machine strictly defined):

```bash
./install.sh --clean
```

## 🛠️ Key Configurations

### Git

* **Auto Remote:** `git push` automatically sets upstream.
* **Rebase:** Pulls default to rebase (linear history).
* **Global Ignore:** Ignores `.DS_Store`, `.vscode`, `.idea`, and `.env` files globally.

### Zsh (Shell)

* **Plugin Manager:** Sheldon (loads plugins like autosuggestions and syntax highlighting).
* **Prompt:** Starship (shows Git branch, package version, execution time).

### Mise (Tool Manager)

Defined in `config.toml`. It installs tools into `~/.local/share/mise`.

**Languages:**
* **Node:** LTS + bun, pnpm package managers
* **Python:** 3.14 (Pinned)
* **Rust:** Stable
* **Erlang/Elixir:** 28.3 / 1.19.5-otp-28

**CLI Tools (via Mise, not Homebrew):**
* eza, bat, ripgrep, fzf, jq, yq, direnv, gh

## 📝 Notes

* **Why Stow?** Allows deep symlinking (like `~/.config/mise/config.toml`) while keeping the repo root clean.
* **Why Mise?** Replaces `nvm`, `pyenv`, `rustup`, and per-tool Homebrew installs with a single, faster tool. CLI tools like `eza`, `bat`, and `ripgrep` are also managed by Mise for consistent versioning.

## 📄 License

MIT
