# Testing Dotfiles in a Virtual Machine

A complete guide for safely testing these dotfiles in a macOS VM before applying them to your real machine.

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

## Step 2: Create a Restore Point (Snapshot Equivalent)

UTM does not provide snapshot management in the UI. Use one of these safe rollback patterns instead:

**Option A: Duplicate the VM (baseline clone)**
1. Shut down the VM
2. In UTM, right-click the VM and choose **Create a copy of the virtual machine with all its data**
3. Rename the copy to something like `macOS-baseline`
4. Use a separate copy for testing and keep the baseline untouched

**Option B: Disposable mode (throwaway runs)**
- From the UTM VM list, choose **Run in disposable mode**
- Changes are discarded when the VM is closed

---

## Step 3: Generate SSH Key on Host Mac

If you already have SSH keys configured for GitHub, skip to [Step 6](#step-6-transfer-keys-to-vm).

### 1. Generate an ED25519 Key

Open Terminal and run:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted:
- Press **Enter** to accept the default file location (`~/.ssh/id_ed25519`)
- Enter a passphrase (recommended) or press **Enter** for no passphrase

### 2. Start the SSH Agent

```bash
eval "$(ssh-agent -s)"
```

You should see output like `Agent pid 12345`.

### 3. Add Your Key to the Agent

```bash
ssh-add ~/.ssh/id_ed25519
```

### 4. Configure SSH for GitHub

Create or edit `~/.ssh/config`:

```bash
nano ~/.ssh/config
```

Add the following:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  UseKeychain yes
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

---

## Step 4: Add Public Key to GitHub

### 1. Copy Your Public Key

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

This copies the public key to your clipboard.

### 2. Add Key to GitHub

1. Go to GitHub.com and open **Settings**
2. Click **SSH and GPG keys**
3. Click **New SSH key**
4. Give it a title (for example, "MacBook Pro")
5. **Key type: Authentication Key**
6. Paste your key in the "Key" field
7. Click **Add SSH key**

> Important: Authentication vs Signing Keys
>
> - Authentication Key: Required for `git clone`, `git push`, `git pull`
> - Signing Key: Used for signing commits (optional)
>
> If you add your key only as a Signing Key, SSH connections will fail with "Permission denied".

---

## Step 5: Test SSH Connection on Host

Run:

```bash
ssh -T git@github.com
```

### Expected Success Message

```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Permission denied (publickey)` | Key not added as Authentication Key | Add key in GitHub Settings as **Authentication Key** |
| `Could not open a connection to your authentication agent` | SSH agent not running | Run `eval "$(ssh-agent -s)"` then `ssh-add ~/.ssh/id_ed25519` |
| `Host key verification failed` | GitHub's host key not in known_hosts | Run `ssh-keyscan github.com >> ~/.ssh/known_hosts` |

---

## Step 6: Transfer Keys to VM

### Option A: Using UTM Shared Folder (Recommended)

1. In UTM, configure a shared folder between host and VM
2. Copy the SSH files to the shared folder:

```bash
# On host Mac
cp ~/.ssh/id_ed25519 /path/to/shared/folder/
cp ~/.ssh/id_ed25519.pub /path/to/shared/folder/
cp ~/.ssh/config /path/to/shared/folder/
```

3. On the VM, move files to the correct location (see Step 7)

### Option B: Manual Copy-Paste via Terminal

1. On the host, display the private key:

```bash
cat ~/.ssh/id_ed25519
```

2. Select and copy the entire output (including `-----BEGIN` and `-----END` lines)

3. On the VM, create the file:

```bash
mkdir -p ~/.ssh
nano ~/.ssh/id_ed25519
```

4. Paste the contents, save and exit

5. Repeat for the public key (`id_ed25519.pub`) and config file

---

## Step 7: Configure and Test on VM

### 1. Create the .ssh Directory (if needed)

```bash
mkdir -p ~/.ssh
```

### 2. Set Correct Permissions

SSH will refuse to use keys with incorrect permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/config
```

### 3. Verify Key Files Exist

```bash
ls -la ~/.ssh/
```

You should see:
- `id_ed25519` (private key)
- `id_ed25519.pub` (public key)
- `config`

### 4. Start SSH Agent and Add Key

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 5. Test SSH Connection to GitHub

```bash
ssh -T git@github.com
```

You should see: `Hi username! You've successfully authenticated...`

### 6. Clone and Test the Dotfiles

```bash
git clone git@github.com:username/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

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
| `ssh-keygen -t ed25519 -C "email"` | Generate new SSH key |
| `eval "$(ssh-agent -s)"` | Start SSH agent |
| `ssh-add ~/.ssh/id_ed25519` | Add key to agent |
| `ssh-add -l` | List keys in agent |
| `ssh -T git@github.com` | Test GitHub connection |
| `pbcopy < ~/.ssh/id_ed25519.pub` | Copy public key to clipboard |
| `chmod 600 ~/.ssh/id_ed25519` | Fix private key permissions |

### Converting HTTPS to SSH Remote

If you have an existing repo using HTTPS:

```bash
git remote set-url origin git@github.com:username/repo.git
```

---

## VM Testing Workflow Summary

1. Create a clean macOS VM in UTM (auto-download IPSW or manual IPSW)
2. Complete macOS setup and install Xcode Command Line Tools
3. Create a restore point (duplicate the VM or use disposable mode)
4. Set up SSH keys and verify GitHub access
5. Clone the dotfiles and run `./install.sh`
6. Verify everything works (shell, tools, configs)
7. If something breaks, restore from your baseline and retry
