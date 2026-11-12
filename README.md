# Slumber

**Arch Linux + Hyprland only.** A niche problem, but something I really wanted.

Linux sleep has been rough in my experience, and Windows wasn't great either. I've heard Mac handles it better. Sometimes I just want Codex or an LLM to keep working while I'm away, with the screen off to save battery, even with the lid open.

Slumber locks the session, turns the displays off and keeps background work running. **Super+Ctrl+L** or the sidebar play button activates it. The sidebar also lets you choose **Sleep / Slumber** for closing the lid.

## Install

Requires the existing end-4 desktop. Cloning the widget alone isn't enough.

```bash
bash scripts/install.sh
```

## Copy prompt

Different setup or installer failed? [**Copy prompt →**](docs/copy-prompt.html) covers the GUI, sidebar and full integration for a coding agent with access to your device.

Open the page locally after cloning, or install its desktop launcher:

```bash
bash scripts/install.sh --prompt-only
```

[Setup and rollback](source/README.md) · [Source](SOURCE.json) · [end-4](https://github.com/end-4/dots-hyprland) · [GPLv3](COPYING)
