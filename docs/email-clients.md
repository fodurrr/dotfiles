# Email clients

Use Mailspring on the Ubuntu desktop and Outlook on the Honor 600 Pro.
Dotfiles manages the Linux package only. Install Outlook separately from
[Google Play](https://play.google.com/store/apps/details?id=com.microsoft.office.outlook).

## Linux installation and updates

The `developer` profile selects `mailspring-linux`. The existing `.deb` layer
downloads the newest stable release from
[Foundry376/Mailspring](https://github.com/Foundry376/Mailspring/releases).
It selects the matching Debian architecture (`amd64` or `arm64`).
This package route requires apt; it does not install Mailspring on Fedora.

Normal profile application, including other selected apps:

```bash
cd /home/fodurrr/dev/dotfiles
./install.sh --profile=developer
```

Profile reruns resolve the latest stable package and skip the install when its
version already matches. The downloaded `.deb` uses the existing vendor-package
trust model: HTTPS from the official GitHub release, without a separate signing
key or checksum check. Do not install a second Snap or Flatpak copy.

Verify the package without opening mail or authenticating:

```bash
dpkg-query -W -f='${Status} ${Version}\n' mailspring
mailspring --version
```

## Account setup

Add personal Gmail accounts through Google's OAuth sign-in.
Add the business Microsoft 365 account through Microsoft's OAuth sign-in.
The free Mailspring plan supports unlimited accounts and a unified inbox.
Account authentication and any new application consent remain separate setup.

For each shared mailbox, use
Mailspring -> Preferences -> Accounts -> business Microsoft 365 account ->
Account Settings -> Add Shared Mailbox.
Authenticate as the existing licensed delegate, not as the shared mailbox.
Existing Full Access and Send As permissions are required for reading and sending.
Mailspring uses OAuth with IMAP/SMTP; it does not use Microsoft Graph.
See the [official Microsoft 365 setup guide](https://www.getmailspring.com/docs/connecting-mailspring-to-microsoft-office-365-and-outlook-com).

Keep shared mailbox sign-in blocked. Do not enable protocols, grant permissions,
change Security Defaults or Conditional Access, or approve tenant-wide consent
just to make the client connect. If existing policy blocks access, record the
error and stop account setup for that mailbox.
See [Microsoft's shared mailbox guidance](https://learn.microsoft.com/en-us/microsoft-365/admin/email/about-shared-mailboxes).

Keep tokens, account databases, caches and provider logins outside Git and Stow.
Package installation does not authenticate accounts or change the default mail
app, autostart, tenant settings or mailbox permissions.

## Acceptance checks after sign-in

- Confirm every Gmail account, the business account and each shared mailbox
  appears in the unified inbox on both devices.
- Check sending and replying from each shared address, including the From
  address and where the sent copy appears.
- Check read/unread changes, archive and deletion across devices.
- Find an older message and open, save and send an attachment.
- Test notifications with the phone locked and idle, and after desktop restart.
  Inspect the phone's actual battery and notification settings if delivery fails.

Outlook can synchronize non-Microsoft account data into Microsoft's cloud.
Review the [Microsoft cloud synchronization explanation](https://support.microsoft.com/en-gb/outlook/getstarted/sync-your-account-in-outlook-to-the-microsoft-cloud)
before adding personal Gmail accounts on the phone.
