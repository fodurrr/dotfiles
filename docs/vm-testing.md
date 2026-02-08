# Testing Dotfiles in a Virtual Machine

A complete guide for safely testing these dotfiles in a macOS VM before applying them to your real machine.
For current profile/app membership, rely on `apps.toml` and installer listing commands.

## Start Here: Prepare a Clean macOS VM (UTM + IPSW)

### Requirements

- Apple Silicon host running macOS 12 or newer
- [UTM](https://mac.getutm.app/) installed
- GitHub account with access to your dotfiles repo

### 1. Create a macOS VM in UTM

1. Open UTM and click **Create a New Virtual Machine**
2. Choose **Virtualization**
3. Select **macOS 12+** as the guest OS

If you do not see **Virtualization** or **macOS 12+**, your host is not compatible with macOS guests.

### 2. Choose an IPSW (Two Options)

Apple distributes macOS as IPSW files for Apple Silicon virtual machines.

**Option A: Auto-download (recommended)**
- Leave the IPSW selection empty
- UTM will download the latest compatible macOS IPSW automatically

**Option B: Manual download (alternative)**
- Download a macOS IPSW from a trusted source (for example, ipsw.me)
- Select the IPSW file in UTM when creating the VM

UTM does not attest to the safety or compatibility of third-party IPSWs and recommends the automatic download for best compatibility.

### 3. Complete macOS Setup

Boot the VM and walk through the standard macOS setup steps. Once you reach the desktop, you are ready to prepare the VM for testing.

---

## First-Time Setup Notes (Common Gotchas)

- macOS guests are only supported on Apple Silicon hosts running macOS 12+.
- Make sure you chose **Virtualization** (not emulation) when creating the VM. QEMU emulation does not support macOS guests on Apple Silicon.
- Shared folders:
  - macOS 13+ guests can use VirtioFS for fast sharing.
  - macOS 12 guests should use network sharing from the host.
  - **UTM needs Full Disk Access** on the host to share protected directories like `~/.ssh`.
- Keep a clean baseline VM. You can duplicate the VM or use disposable mode (details below).

---

## Step 1: Install Xcode Command Line Tools (Git)

You need Git inside the VM before cloning the repo.

```bash
xcode-select --install
```

After installation, confirm Git is available:

```bash
git --version
```

---

## Step 2: Share Host SSH Keys with VM

Instead of copying SSH keys into the VM, share them from your host via UTM's shared folder feature. This keeps keys in one place and makes them automatically available to disposable VMs.

> **Don't have SSH keys configured?** See [SSH & GitHub Setup Guide](ssh-github-setup.md) first.

### 1. Configure UTM Shared Folder (on Host Mac)

UTM runs on your host Mac. You'll configure it to share your SSH keys with the VM.

1. **Grant UTM Full Disk Access** (required to share `.ssh`):
   - System Settings → Privacy & Security → Full Disk Access
   - Enable **UTM**
2. Shut down the VM
3. **On your host Mac**, open UTM
4. Select the VM and click **Edit**
5. Go to **Sharing**
6. Click **Add** and select your **host's** `.ssh` directory (e.g., `/Users/yourname/.ssh`)
7. Enable **Read Only** to prevent the VM from modifying your keys
8. Click **Save** and start the VM

The VM will now have read-only access to your SSH keys at `/Volumes/My Shared Files/.ssh/`.

### 2. Verify the Share in VM

UTM mounts the shared `.ssh` folder at `/Volumes/My Shared Files/.ssh/` for macOS guests. Verify access:

```bash
ls -la "/Volumes/My Shared Files/.ssh"
```

You should see your host's SSH keys (`id_ed25519`, `id_ed25519.pub`, `config`). Use `-la` to show hidden files (dotfiles).

> **Note:** If `/Volumes/My Shared Files/` is empty or doesn't appear:
> - Verify UTM has **Full Disk Access** on your host Mac (System Settings → Privacy & Security)
> - Check that the share is enabled in UTM settings and click **Save**
> - Restart the VM after making changes

---

## Step 3: Link VM to Host Keys

Configure the VM to use SSH keys from the shared folder. Choose one of these approaches:

### Option A: Symlink the Entire .ssh Directory (Recommended)

This is the simplest approach for a clean VM:

```bash
# Remove any existing .ssh directory
rm -rf ~/.ssh

# Create symlink to host's .ssh (the shared folder IS your .ssh contents)
ln -s "/Volumes/My Shared Files/.ssh" ~/.ssh
```

Verify the symlink:

```bash
ls -la ~/.ssh/
```

### Option B: SSH Config with Shared Path

If you need VM-specific SSH settings, create a local config that points to shared keys:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat > ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile "/Volumes/My Shared Files/.ssh/id_ed25519"
  AddKeysToAgent yes
EOF

chmod 600 ~/.ssh/config
```

### Permissions Note

When using symlinks (Option A), SSH reads permissions from the host's files. If your host's `~/.ssh/` has correct permissions (700 for directory, 600 for private key), no additional chmod is needed in the VM.

### Test SSH Connection

```bash
ssh -T git@github.com
```

You should see: `Hi username! You've successfully authenticated...`

---

## Step 4: Create a Restore Point (Snapshot Equivalent)

UTM does not provide snapshot management in the UI. Use one of these safe rollback patterns instead:

**Option A: Clone the VM (baseline clone)**
1. Shut down the baseline VM (e.g., `macOS-baseline`)
2. In UTM, right-click the VM and choose **Clone**
3. Name the clone for its purpose (e.g., `macOS-dotfiles-testing`)
4. Test on the clone and keep the baseline untouched

**Option B: Disposable mode (throwaway runs)**
- From the UTM VM list, choose **Run in disposable mode**
- Changes are discarded when the VM is closed

---

## Step 5: Clone and Test the Dotfiles

```bash
git clone git@github.com:username/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Verify everything works:
- Shell loads correctly
- Tools and aliases are available
- Configs are applied

If something breaks, restore from your baseline VM and retry.

---

## Quick Reference

### SSH URL Format

```
git@github.com:username/repo.git
```

### Key Commands Cheatsheet

| Command | Purpose |
|---------|---------|
| `xcode-select --install` | Install Xcode Command Line Tools |
| `ssh -T git@github.com` | Test GitHub connection |
| `ls -la "/Volumes/My Shared Files/.ssh"` | Verify shared folder in VM |

### Converting HTTPS to SSH Remote

If you have an existing repo using HTTPS:

```bash
git remote set-url origin git@github.com:username/repo.git
```

---

## VM Testing Workflow Summary

1. Create a clean macOS VM in UTM (auto-download IPSW or manual IPSW)
2. Complete macOS setup and install Xcode Command Line Tools
3. Configure SSH sharing from host (see [SSH & GitHub Setup Guide](ssh-github-setup.md) if needed)
4. Link VM to host keys and verify SSH connection
5. Create restore point (duplicate VM or use disposable mode)
6. Clone the dotfiles and run `./install.sh`
7. Verify everything works (shell, tools, configs)
8. If something breaks, restore from your baseline and retry
