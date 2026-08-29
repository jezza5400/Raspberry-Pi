# Pacman

## Operations

| Op   | Meaning                                              |
| ---- | ---------------------------------------------------- |
| `-S` | Sync: install/upgrade from repos (or AUR, with yay)  |
| `-Q` | Query: inspect installed packages (local db)         |
| `-R` | Remove                                               |
| `-U` | Upgrade from a local file (`.pkg.tar.zst`)           |
| `-D` | Database: change install reason, etc.                |
| `-F` | Files: search which package owns a file              |
| `-V` | Version info                                         |
| `-T` | Check dependencies (rarely used directly)            |

## Useful modifiers per operation

**With `-Q` (query installed packages):**

- `-Qi`: info about an installed package
- `-Qs <term>`: search installed packages by name/desc
- `-Ql <pkg>`: list all files owned by a package
- `-Qo <file>`: which package owns this file
- `-Qdt`: list orphans (deps no longer required by anything)
- `-Qe`: list explicitly installed packages (not pulled in as deps)
- `-Qm`: list foreign/AUR packages

**With `-S` (install/sync):**

- `-Ss <term>`: search repos (not installed, just available)
- `-Si`: info about a repo package (not yet installed)
- `-Syu`: sync repo databases + full system upgrade (the standard "update everything")
- `-Sy` alone: just refresh databases (⚠️ doing this without `u` risks partial upgrades, avoid)
- `-Sw`: download only, don't install

**With `-R` (remove):**

- `-Rs`: remove package + dependencies no longer needed by anything else
- `-Rn`: also remove its config files (`.pacnew`/config in `/etc`)
- `-Rns`: both combined (full clean removal)
- `-Rdd`: remove ignoring dependency checks (dangerous, rarely needed)
- `-Rc`: also remove packages that depend on it (cascade, dangerous)

**Useful standalone:**

- `pacman -Fs <term>`: search which package provides a file (needs `pacman -Fy` first to sync file db)

## yay-specific additions

- `yay -Sua`: upgrade only AUR packages
- `yay -Ps`: print system statistics
- `yay -Yc`: clean unneeded AUR deps (yay's version of orphan cleanup)
