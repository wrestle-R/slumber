# Slumber

**Arch Linux + Hyprland only.** A niche problem, but something I really wanted.

Linux sleep has been rough in my experience, and Windows wasn't great either. I've heard Mac handles it better. Sometimes I just want Codex or an LLM to keep working while I'm away, with the screen off to save battery, even with the lid open.

Slumber locks the session, turns the displays off and keeps background work running. **Super+Ctrl+L** or the sidebar play button activates it. The sidebar also lets you choose **Sleep / Slumber** for closing the lid.

## Install

Requires the existing end-4 desktop. Cloning the widget alone isn't enough.

```bash
bash scripts/install.sh
```

If you don't trust the installer or it fails, give this prompt to a coding agent with access to your device. Open it and use the copy button in the top right.

<details>
<summary>Copy prompt</summary>

```text
Reproduce Slumber on this Linux device, including its GUI, sidebar, settings, secure lockscreen and system integration. You have filesystem and terminal access. Do the implementation and verification, not just an explanation. Inspect first; adapt to this machine instead of copying someone else's complete dotfiles.

SOURCE AND SCOPE
Use the local checkout containing this prompt if available. Otherwise obtain https://github.com/wrestle-R/slumber (access may require the user's GitHub authentication; do not ask for a token in chat). If inaccessible, report that limitation and ask for a local checkout, never claim to have read it. Read README.md, SOURCE.json, source/README.md, source/VERIFICATION.md, source/assets.json and source/integration.json. Source snapshots are specifications, not permission to overwrite unrelated configuration. Preserve GPLv3 attribution and COPYING. Supported packaged baseline is Arch Linux + Hyprland with end-4/illogical-impulse, QuickShell 0.3.2 and Lua Hyprland 0.57.1. Other environments require an explicitly identified port. Never install a compositor or replace a desktop merely to make a widget load.

1. DISCOVER AND PLAN
Read the device's AGENTS.md and relevant existing project notes. Identify distro, package manager, compositor/version/config language, session type, QuickShell version and active configuration, end-4 panel family, notification owner, session lock implementation, PAM integration, idle daemon, lid policy, systemd/logind configuration, Polkit agent, batteries/sysfs capabilities and display topology. Respect XDG paths and actual HOME; no hard-coded /home/rdp. Inspect existing shortcuts and sleep inhibitors. Identify running shell processes without exposing command-line secrets. Never start a second primary shell or notification daemon. Explain missing prerequisites and the proposed files before applying changes. Use distro-supported packages; do not silently execute a downloaded setup script or install unrelated clipboard/Spotify/application integrations from the snapshot.

2. CORE SLUMBER BEHAVIOUR
Study source/Slumber.qml, slumber_backend.py, slumber-shortcuts.lua and the relevant integration.json changes. Implement one coherent state owner in the main shell; auxiliary settings windows must not own hardware policy. Entry must acquire the existing secure session lock, display its lock UI for two seconds, then power displays off with the compositor's supported mechanism while apps and coding agents keep working. Never blank first and assume a lock succeeded. Keep Super+Ctrl+L for Slumber where available, Super+L for regular locking, and Super+Shift+L for explicit sleep; report conflicts and adapt deliberately. Add a Slumber action to the Session menu and a play action to the notification sidebar. Entry must work with the lid open too.

Persist a sidebar 'Lid action: Sleep / Slumber' choice. Choosing a preference controls future lid handling; the separate Slumber action enters immediately. During active Slumber keep background work running with either lid position until password unlock, suppress the ordinary 15-minute idle suspend, and retain explicit sleep and critical-battery suspend. The existing coffee control keeps its idle-inhibition role. Prevent competing logind/hypridle/lid handlers from racing. Follow the actual backend state machine, including cleanup, unlock, compositor errors and process lifecycle, rather than globally disabling sleep. Do not weaken authentication, change PAM or invent a fake password dialog.

3. GUI AND SIDEBAR
Use source/LidActionControl.qml, ChargeLimitControl.qml, NotificationsConfig.qml, LockNotifications.qml and integration.json as the visual and behavioural reference. Integrate into the existing end-4 notification sidebar, lock surface, session menu and Super+I settings navigation. Preserve the desktop's theme, spacing, typography, icon system, scaling, focus and keyboard interaction. Include clear current/selected states, disabled and unsupported states, battery capacity, AC and charging status, charge-limit switch/slider/Apply, and three notification-group toggles. Wire every control to real services. Do not render a disconnected mockup. If this desktop cannot host QML/end-4, explain the required equivalent surface and preserve the same behaviour in its native UI; never claim pixel-identical reproduction without checking it.

4. NOTIFICATIONS AND DISPLAY WAKE
Implement source/NotificationPolicy.js exactly in intent: only T3 Code, Codex/Multi Codex and Visual Studio Code are allowed on the lockscreen. Match explicit normalized aliases from the policy. Reject unknown apps, partial/substring matches and generic Electron identities. Add independent settings toggles for the three groups; disabling a group blocks its lock visibility and wake. Store Slumber preferences separately at the appropriate XDG state path (baseline ~/.local/state/quickshell/slumber.json).

Show only the latest three allowed notifications, with app, title/sender and message rendered as plain text. No rich links, notification actions or command execution on the lock surface. The full list remains available after unlock. App identity metadata is not cryptographic authentication; explain that limitation. Approved notifications can wake an open display for six seconds, with coalescing and a 15-second cooldown. Hidden apps and Do Not Disturb cannot wake it. Keyboard/pointer activity allows 30 seconds for unlock then reblanks. Never light the built-in display while the lid is closed. Check external displays and repeated lid transitions.

5. LOCK VISUALS
Keep the configured wallpaper or its video thumbnail; do not require the original user's private wallpaper. Follow the source's settled blur (blurMax 24 at 0.45, entry from 1 over 650ms after image load) while keeping password controls and notifications crisp. Authentication must be independent of image loading or animation. Missing images must retain a usable lockscreen.

6. BATTERY LIMIT AND PRIVILEGED INSTALLATION
Read charge_limit.py, battery_status.py, ChargeLimit.qml, rdp-charge-limit.service and install-system.py before integrating. Default proposal 95%, adjustable 55–95%, resume five percentage points below the stop threshold, disable sets stop to 100%. Read actual hardware thresholds and charging status; distinguish a proposal from an applied policy. Above-cap batteries stop charging where supported; do not promise forced discharge. Unsupported devices must say Unsupported without simulated success.

On Dell hardware advertising charge modes, cap enable selects Custom and disable selects Standard where available. A saved threshold in Adaptive mode is not enforced. Preserve original charge mode and thresholds. Keep the privileged helper root-owned, accepting only fixed battery sysfs paths and bounded integer values, serialized writes, hardware readback, persistent last-successful state and rollback on failure. Apply changes through the existing Polkit agent. Cancellation/failure retains the previous state. Use a system service to restore a successful policy after reboot; initial installation must not change thresholds. Never make sysfs world-writable or grant broad passwordless sudo.

The bundled system installer also installs SDDM. If SDDM is present and the user wants the complete bundled setup, reproduce the selected Twin Halo theme from source/sddm and theme_tools.py: a chosen local landscape, two warm arcs, floating controls, strong prepared resting blur, first-presented-frame entry, staggered fades/scale/blur crossfade finishing within 1.6 seconds. Prepare images once with ImageMagick, no permanent animation worker or blur loop. Authentication begins immediately. Preflight staged QML with the Qt6 greeter in isolated software-rendered test mode before system writes. Preserve a dark usable fallback, original theme and recovery path. Never restart the display manager, log out or reboot an active user session. If SDDM is absent, report this component as not applicable instead of installing a new display manager unasked.

7. SAFE INSTALLATION AND RECOVERY
Prefer scripts/install.sh for the matching baseline. Run source/customizations.py check first. It validates every managed file against reviewed versions, installs assets before consumers and the main shell entry last, preserves modes, creates private backups, detects concurrent edits and rolls back partial writes. Unknown versions require inspecting the target and porting the integration. Never add arbitrary hashes to bypass refusal or copy the entire integration.json 'after' files over unrelated user customizations. Make narrow changes, review diffs, and preserve existing settings, secrets and running work. Record every backup path and exact restore command. System and user restoration are separate; preserve original battery policy as well. Never read passwords or secrets into logs. Do not upload any real environment files unless required and authorized by the user's own instructions.

8. VERIFY AND DELIVER
Run the fixture suites: python3 test_charge_modes.py, python3 test_battery_status.py, python3 test_guardrails.py and node test_notification_policy.cjs from source/. They use temporary fixtures and do not prove live hardware behaviour. Run SDDM/native suites only after inspecting their dependencies and isolation requirements; test_native.py is deliberate desktop testing, never an automatic install step. Validate QML and compositor config using supported tools for the installed versions. Save unsent shell drafts before restarting the existing shell, only while unlocked; do not launch a duplicate. Reload syntax may differ on other Hyprland versions.

Verify entry via shortcut/sidebar/session menu, secure password unlock, display-off timing, background process continuation, lid open/closed handling, external monitors, input timeout, notification allow/deny/toggles/DND/cooldown, ordinary idle versus active Slumber, explicit sleep and critical-battery protection. Use mocks for critical-battery paths rather than deliberately draining a device. Test repeated entry, errors, restart and restore. Verify charge apply/off, cancelled auth, unsupported hardware, Dell Custom readback and above-cap paused charging where available. Real password, physical lid, reboot persistence and real notification checks require actual target evidence; list anything unperformed plainly.

Finish with implemented files, installed components, actual verification results, remaining hardware checks, known platform differences, backup paths and precise rollback steps. Do not claim universal Linux support, guaranteed battery savings, or physical tests you did not perform. Carry the work through to a functioning integration where this device supports it; ask only for missing access or decisions that block the next dependent action.
```

</details>

[Setup and rollback](source/README.md) · [Source](SOURCE.json) · [end-4](https://github.com/end-4/dots-hyprland) · [GPLv3](COPYING)
