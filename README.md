# Slumber

Screen off, work still running. A separate home for my Hyprland / end-4 Slumber setup, with password locking, lid behaviour and coding-app notifications.

## Read this first

This is a pinned rebuild package from Linux commit `e9baeebf24fa0917f94c9394ef3f3fcef29e7f31`, not a general-purpose plugin. The main desktop thread is still fixing the Dell charge mode and login visuals. **Those fixes are not in this snapshot. Do not use this version to install the battery helper.** Its saved thresholds may be ignored while Dell remains in Adaptive mode.

`SOURCE.json` records the original paths and SHA-256 hashes. The original package is preserved under `source/`, including its historical SDDM assets and combined root installer so reproduction does not silently lose dependencies. SDDM's dedicated repo is the sibling `sddm-login`.

## What it does

- Super+Ctrl+L locks, shows the lockscreen for two seconds, then turns displays off.
- Background apps keep running; a saved Sleep / Slumber choice controls lid handling.
- Only T3 Code, Codex/Multi Codex and VS Code can show lock notifications or briefly wake Slumber. Individual groups can be disabled.
- Password authentication uses the existing QuickShell lock implementation. Explicit sleep and critical-battery protection remain part of the integration.

## What you need

The supported existing end-4 desktop and the earlier clipboard, sidebar, settings and image-state layers from [my Linux setup](https://github.com/wrestle-R/Linux/tree/main/End-4). The package was built against QuickShell 0.3.2 and Lua Hyprland 0.57.1. It refuses unknown config versions; it is not a fresh-machine installer.

## Check and install the user layer

From this repo:

```bash
cd source
python3 test_guardrails.py
node test_notification_policy.cjs
python3 customizations.py check
```

The first two commands use temporary fixtures and check policy/installer behaviour. `check` reads your actual configuration without writing. A refusal means the desktop needs a reviewed manifest adaptation; do not bypass it by adding hashes.

After reviewing the plan and saving unsent shell drafts, while unlocked:

```bash
python3 customizations.py install
hyprctl reload config-only
hyprctl configerrors
```

Keep the printed backup path. Restart hypridle and the existing QuickShell instance using your desktop's normal procedure after reviewing [the original setup notes](source/README.md). Do not launch a second main shell. A shell restart loses unsaved shell drafts.

## Roll back

While unlocked, use the exact backup printed during installation:

```bash
cd source
python3 customizations.py restore --backup /path/printed/by/install
hyprctl reload config-only
```

Restart hypridle and QuickShell after restoring. Restore refuses intervening edits. The user-layer installer does not install root services or SDDM. `source/install-system.py` is the historical combined installer, not the recommended entry point for these separate repos; it changes both the login theme and battery service.

## Verification and updates

[Historical verification](source/VERIFICATION.md) describes the source machine, not a new verification on every computer. Password unlock, lid behaviour, real notification wakes and reboot persistence still need physical checks on the target machine. `test_native.py` requires the matching running desktop and uses a private test shell; run it deliberately, not as an installation step.

Keep the private GitHub repo and these notes separate from live dotfiles. Future updates should import a completed reviewed source commit, refresh `SOURCE.json`, rerun fixture checks and document remaining hardware checks. A Git pull alone does not install anything.

## Source and attribution

Original package: [wrestle-R/Linux](https://github.com/wrestle-R/Linux/tree/e9baeebf24fa0917f94c9394ef3f3fcef29e7f31/End-4/slumber). Integration snapshots include end-4 QuickShell code from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland). Its GPLv3 license is preserved in `COPYING`; existing notices and the SDDM metadata's license declaration are retained.

No personal wallpaper, environment files, credentials, notification history or machine backups are included.
