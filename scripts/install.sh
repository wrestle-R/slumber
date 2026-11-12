#!/usr/bin/env bash
# Run as your desktop user; only the optional system installer uses Polkit.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode=install
system=false
wallpaper=
while (($#)); do
    case "$1" in
        --check) mode=check ;;
        --prompt-only) mode=prompt ;;
        --system) system=true ;;
        --wallpaper) shift; wallpaper="${1:?--wallpaper requires a path}" ;;
        -h|--help)
            cat <<'HELP'
Usage: bash scripts/install.sh [--check | --prompt-only] [--system --wallpaper /absolute/image]
Default: preflight and install the supported end-4 user layer and Copy prompt launcher.
--check: read-only dependency and configuration checks.
--prompt-only: install just the offline Copy prompt page and application/desktop launcher.
--system: also install the bundled battery helper/service AND SDDM theme via Polkit.
Save shell drafts and unlock first. No shell, idle daemon or display-manager restarts.
HELP
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
    shift
done
if ((EUID == 0)); then echo 'Run as your desktop user, without sudo.' >&2; exit 1; fi
command -v python3 >/dev/null || { echo 'Python 3 is required.' >&2; exit 1; }
install_prompt() {
    python3 - "$ROOT" <<'PY'
import os
from pathlib import Path
import shutil
import subprocess
import sys
root = Path(sys.argv[1])
data = Path(os.environ.get('XDG_DATA_HOME') or Path.home()/'.local/share')
page = data/'slumber/copy-prompt.html'
page.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(root/'docs/copy-prompt.html', page)
# Desktop Exec quoting is distinct from shell quoting; escape reserved characters.
uri = page.as_uri().replace('%', '%%')
quoted = '"' + uri.replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('$', '\\$') + '"'
entry = '[Desktop Entry]\nType=Application\nName=Slumber · Copy prompt\nComment=Copy the complete Slumber setup prompt\nExec=xdg-open ' + quoted + '\nTerminal=false\nIcon=weather-clear-night\n'
app = data/'applications/slumber-copy-prompt.desktop'
app.parent.mkdir(parents=True, exist_ok=True)
app.write_text(entry)
if shutil.which('xdg-user-dir'):
    desktop = Path(subprocess.check_output(['xdg-user-dir', 'DESKTOP'], text=True).strip())
else:
    desktop = Path.home()/'Desktop'
if desktop.is_dir() and desktop != Path.home():
    target = desktop/'slumber-copy-prompt.desktop'
    target.write_text(entry)
    target.chmod(0o755)
    print('Desktop launcher:', target)
print('Copy prompt page:', page)
print('Some desktop environments require trusting the desktop launcher before opening it.')
PY
}
if [[ "$mode" == prompt ]]; then install_prompt; exit 0; fi
[[ -r /etc/os-release ]] || { echo 'Cannot identify Linux distribution.' >&2; exit 1; }
if ! (. /etc/os-release; [[ "$ID" == arch ]]); then
    echo 'Packaged installer supports Arch Linux + Hyprland only. Use --prompt-only for an agent-assisted port.' >&2
    exit 1
fi
for dep in hyprctl qs hypridle node; do
    command -v "$dep" >/dev/null || { printf 'Missing dependency: %s. Install it for your desktop first.\n' "$dep" >&2; exit 1; }
done
python3 -c 'from gi.repository import Gio' || { echo 'PyGObject/Gio is required.' >&2; exit 1; }
if [[ "$system" == true ]]; then
    [[ "$wallpaper" == /* && -f "$wallpaper" ]] || { echo '--system requires --wallpaper with an existing absolute image path.' >&2; exit 2; }
    for dep in pkexec magick sddm-greeter-qt6; do
        command -v "$dep" >/dev/null || { printf 'Missing system dependency: %s\n' "$dep" >&2; exit 1; }
    done
fi
cd "$ROOT/source"
if ! python3 customizations.py check; then
    echo 'This desktop needs a reviewed integration. No user-layer files were written. Run scripts/install.sh --prompt-only from the repository root.' >&2
    exit 1
fi
[[ "$mode" == check ]] && exit 0
python3 customizations.py install
install_prompt
if [[ "$system" == true ]]; then
    pkexec /usr/bin/python3 "$ROOT/source/install-system.py" install --wallpaper "$wallpaper"
fi
printf '%s\n' 'Installation finished. Keep the printed backup paths.' 'While unlocked, follow source/README.md to reload Hyprland and restart the existing hypridle/QuickShell instances.' 'Physical lock, lid, notification and reboot checks still need verification on this device.'
