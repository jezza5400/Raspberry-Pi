# Packman pgp corruption process

## Step 1: Confirm you actually have working internet (not stuck behind a captive portal)

```bash
curl -sI https://archlinux.org | head -1
```

Expected: HTTP/2 200

If you see anything else (or HTML/a redirect), STOP - fix your network/portal login first

Running the steps below on a bad connection just re-corrupts the keyring again

## Step 2: Wipe the local GPG trust database

```bash
sudo rm -rf /etc/pacman.d/gnupg
```

Expected: no output (silent success)

## Step 3: Re-initialize it

```bash
sudo pacman-key --init
```

Expected: ends with "gpg: key \<ID\>: secret key imported" and no errors

## Step 4: Populate with Arch Linux's trusted master keys

```bash
sudo pacman-key --populate archlinux
```

Expected: several lines like:

- "Locally signing trusted keys in keyring..."
- "Locally signed N keys."

No "error" or "corrupted" lines

## Step 5: Force-refresh the keyring package itself

```bash
sudo pacman -Sy archlinux-keyring
```

Expected: normal download/install progress, ending "(1/1) installed archlinux-keyring"

## Step 6: Re-populate with the updated keys

```bash
sudo pacman-key --populate archlinux
```

Expected: same as Step 4, possibly a few more keys signed this time
