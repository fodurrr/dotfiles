# SSH & GitHub Setup Guide

A complete guide for generating SSH keys and configuring them for GitHub authentication.

---

## Step 1: Generate SSH Key

### Generate an ED25519 Key

Open Terminal and run:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted:
- Press **Enter** to accept the default file location (`~/.ssh/id_ed25519`)
- Enter a passphrase (recommended) or press **Enter** for no passphrase

---

## Step 2: Start the SSH Agent

```bash
eval "$(ssh-agent -s)"
```

You should see output like `Agent pid 12345`.

---

## Step 3: Add Your Key to the Agent

```bash
ssh-add ~/.ssh/id_ed25519
```

---

## Step 4: Configure SSH for GitHub

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

## Step 5: Add Public Key to GitHub

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

## Step 6: Test SSH Connection

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

## Quick Reference

### Key Commands Cheatsheet

| Command | Purpose |
|---------|---------|
| `ssh-keygen -t ed25519 -C "email"` | Generate new SSH key |
| `eval "$(ssh-agent -s)"` | Start SSH agent |
| `ssh-add ~/.ssh/id_ed25519` | Add key to agent |
| `ssh-add -l` | List keys in agent |
| `ssh -T git@github.com` | Test GitHub connection |
| `pbcopy < ~/.ssh/id_ed25519.pub` | Copy public key to clipboard |
| `chmod 600 ~/.ssh/id_ed25519` | Fix private key permissions |
