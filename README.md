# Slumber

**Arch Linux + Hyprland only.** This is a niche problem to solve, obviously, but it was annoying enough that I wanted a proper button for it.

Linux sleep has been pretty rough in my experience. Coming from Windows, one thing I kept wanting was a way to turn the screen off and leave the work running. Windows sleep has its own problems too, and I've heard good things about Mac sleep, but I haven't tested that comparison myself.

Sometimes Codex or another coding agent is running, sometimes it's an LLM doing its thing, and I'm not actually sitting there monitoring it. I want the display off, the session locked and the background processes still working. Even when I leave the lid open. Turning off the display saves the power the display would otherwise use, though the running jobs still use battery. No battery-life numbers promised here.

So that's Slumber. Screen off, work still running.

## Install

Cloning a widget alone won't wire up locking, the sidebar, lid events and idle handling. From this repository, run:

```bash
bash scripts/install.sh --check
bash scripts/install.sh
```

The installer targets the existing end-4 setup described below, checks dependencies and file compatibility before applying the user integration, and keeps the original installer's backups and rollback checks. It does not install an entire end-4 desktop onto a fresh machine. Save shell drafts first and run while unlocked. It leaves shell restarts to you.

For the complete system layer (charge-limit helper, reboot service and bundled SDDM theme), review [the system installation notes](source/README.md) first, then supply your own wallpaper:

```bash
bash scripts/install.sh --system --wallpaper /absolute/path/to/wallpaper.jpg
```

This uses Polkit authentication and installs both system components together. It never restarts SDDM. Unsupported battery hardware stays unsupported.

## Different Linux setup? Copy the prompt

[**Copy prompt →**](docs/copy-prompt.html)

Download or clone this repo and open that page locally, or run:

```bash
bash scripts/install.sh --prompt-only
```

That installs **Slumber · Copy prompt** in your application menu and, when your desktop directory exists, a desktop launcher. Open it and press **Copy prompt**, then paste into a coding agent with filesystem and terminal access on your own device. GitHub shows HTML as source, so download the repo before opening the page. The full prompt stays out of this README.

The prompt asks the agent to inspect your machine and reproduce the complete Slumber experience, including the GUI and sidebar, using the checked source as its specification. Different desktops need real integration work; it isn't a promise that every Linux setup can run this unchanged.

## Read this first

This is a reviewed rebuild package from Linux commit `6a3738a76feb748416cbde07ff7e17b0cd919be6`. It includes the Dell Custom-mode charge fix, stronger settled lockscreen blur and selected Twin Halo login source.

`SOURCE.json` records the original paths and SHA-256 hashes. The original package is preserved under `source/`, including its matching SDDM assets and combined root installer so reproduction does not silently lose dependencies. SDDM's dedicated repo is the sibling `sddm-login`.

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
python3 test_charge_modes.py
python3 test_battery_status.py
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

Restart hypridle and QuickShell after restoring. Restore refuses intervening edits. The user-layer installer does not install root services or SDDM. `source/install-system.py` is the combined guarded installer, changes both the login theme and battery service; review source/README.md before using it. It preflights SDDM in test mode and never restarts the display manager.

## Verification and updates

[Recorded verification](source/VERIFICATION.md) describes the source machine, not a new verification on every computer. Password unlock, lid behaviour, real notification wakes and reboot persistence still need physical checks on the target machine. `test_native.py` requires the matching running desktop and uses a private test shell; run it deliberately, not as an installation step.

Keep the private GitHub repo and these notes separate from live dotfiles. Future updates should import a completed reviewed source commit, refresh `SOURCE.json`, rerun fixture checks and document remaining hardware checks. A Git pull alone does not install anything.

## Source and attribution

Original package: [wrestle-R/Linux](https://github.com/wrestle-R/Linux/tree/6a3738a76feb748416cbde07ff7e17b0cd919be6/End-4/slumber). Integration snapshots include end-4 QuickShell code from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland). Its GPLv3 license is preserved in `COPYING`; existing notices and the SDDM metadata's license declaration are retained.

No personal wallpaper, environment files, credentials, notification history or machine backups are included.

Charge limits select Dell Custom mode where supported. An above-cap battery stops charging; it is not forcibly drained. Lock notifications remain restricted to T3 Code, Codex/Multi Codex and VS Code. The lockscreen keeps following the current wallpaper.
