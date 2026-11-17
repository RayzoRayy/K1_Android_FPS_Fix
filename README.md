# Star Wars: Knights of the Old Republic (KOTOR 1) — Android FPS Switcher

**KernelSU module: 60 FPS / 120 FPS + Combat Movement Fix**  
**Module ID:** `kotor_fps_unified_manual`  
**Package:** `com.aspyr.swkotor`  
**Platform:** Android ARM64 (AArch64)

## What this module does

This module lets you switch between the original KOTOR 1 frame rate, a 60 FPS patch, and a 120 FPS patch using **one Action button in KernelSU**. The 120 FPS version also includes the tested combat movement fix, which addresses the issue where finger-drag character movement can lock up during melee or ranged combat at high frame rates.

The module includes two modified versions of the game's native engine library (`libKOTOR.so`). It **does not permanently overwrite the original installed library**. Instead, each Action press temporarily bind-mounts the selected library over the installed one. The original library remains underneath the mount.

The 60 FPS patch changes frame-delay timing. The 120 FPS patch changes frame-delay timing and adjusts a combat-related timer constant from approximately **0.1 seconds to 0.001 seconds**, the change that restored combat movement in testing. The original animation-blocking instructions are preserved.

**This is not a mod for KOTOR 2.** It targets a specific Android ARM64 build of KOTOR 1.

## Requirements

- KOTOR 1 for Android, package `com.aspyr.swkotor`.
- An ARM64 Android device with a functioning KernelSU installation and root access.
- The **matching game library version**. The module checks the SHA-256 of the installed or mounted `libKOTOR.so` and refuses to switch if it does not recognize the file.
- The unified module ZIP, installed through KernelSU.

**Important:** Remove or disable any older, separate KOTOR 1 60 FPS or 120 FPS KernelSU modules before installing this unified version. Do not use two FPS patch modules on the same game at once.

## Installation

1. Save a backup of your KOTOR 1 saves and game data before experimenting with mods.
2. Open the **KernelSU** app on your Android device.
3. Go to **Modules** and uninstall or disable the older individual KOTOR FPS modules, if installed.
4. Choose **Install from storage** (the wording may vary by KernelSU version).
5. Select `KOTOR_1_Unified_60_120FPS_KernelSU.zip` and complete installation.
6. Reboot if KernelSU requests it. The module **does not automatically patch the game on boot**.
7. Return to **KernelSU → Modules**, find **KOTOR 1 FPS Switcher - 60 / 120 Combat Fix**, and tap its **Action** button.
8. Read the output to confirm the selected FPS mode, then launch KOTOR 1.

Do **not** extract the ZIP or install it as an APK. Install the ZIP directly in KernelSU.

## How to use the Action button

The button cycles through three modes, based on the library currently visible to the module:

| Current mode | Press Action | Result |
| --- | --- | --- |
| Original / stock (approximately 40 FPS) | Once | **60 FPS** |
| 60 FPS | Again | **120 FPS + combat movement fix** |
| 120 FPS + combat movement fix | Again | **Stock / original** |
| Stock | Again | **60 FPS**, repeating the cycle |

The module force-stops KOTOR before switching, so **relaunch the game after every press**. It does not provide an in-game menu. You can leave the module installed and use the same Action button whenever you want to switch.

**Example output:**

```text
SUCCESS: 60 FPS ACTIVE. Next Action: 120 FPS + combat fix.
```

```text
SUCCESS: 120 FPS + COMBAT MOVEMENT FIX ACTIVE. Next Action: stock 40 FPS.
```

```text
SUCCESS: STOCK 40 FPS restored. Next Action: 60 FPS.
```

## What happens behind the scenes

On each Action press, the script:

1. Confirms it is running as root.
2. Verifies both included patch files using SHA-256 checksums.
3. Locates KOTOR 1's installed `base.apk` and native ARM64 `libKOTOR.so`.
4. Reads the currently visible library checksum to determine whether stock, 60 FPS, or 120 FPS is active.
5. Prepares the next patched library under `/data/local/tmp/`, with ownership, permissions, and SELinux context configured.
6. Force-stops KOTOR.
7. Unmounts an active FPS patch, checks that the original library is underneath, and either bind-mounts the next patch or leaves the stock library restored.
8. Verifies the checksum of the resulting mounted library and reports the result.

It does **not** edit your saves, change the APK signature, or permanently write into the installed `libKOTOR.so`.

## Compatibility and checksums

These are the exact library hashes recognized by this version of the module:

| Mode | SHA-256 |
| --- | --- |
| Original KOTOR 1 ARM64 | `a226ac4f6c7bdcdd8d584f5423cd1912c746757ee79939fef417b9c9243b7d52` |
| 60 FPS patch | `175fa822bf28abbe8e853467b04752b3838f7bdebffeafca7c486052fe8e0924` |
| 120 FPS + combat fix | `e0ae12c7f846caf4ace0f7a90df2c9549db07c6c31282969363054fdc7eadbde` |

If KOTOR updates, the game is reinstalled, or the native library differs from the expected version, the Action script may report **"Unrecognized installed/mounted library"** and stop without applying a patch. Do not force these binary patches onto a different library version.

## Reboot, disabling, and removal

- **After a reboot:** Temporary bind mounts may disappear. Check the active mode and press Action as needed. The module deliberately does not reapply a patch automatically at startup.
- **To return to stock while the module is functioning:** Press Action until it reports `STOCK 40 FPS restored`.
- **Before uninstalling the module:** Restore stock with the Action button first, then uninstall it in KernelSU. Disabling or uninstalling a module is **not itself a substitute for unmounting** a currently active manual bind mount.
- **If the game crashes:** Force-stop it and restore stock before testing again. A reboot will normally clear temporary bind mounts, but verify the original library is visible afterward.

### Optional manual rollback (advanced)

From a root ADB shell:

```sh
am force-stop com.aspyr.swkotor
LIB=$(find /data/app -path '*/com.aspyr.swkotor-*/lib/arm64/libKOTOR.so' -print -quit)
echo "$LIB"
umount "$LIB"
sha256sum "$LIB"
```

Only run `umount` if a temporary FPS patch is actually mounted; if it reports that the target is not mounted, no rollback mount was present in that shell's mount namespace. The original SHA-256 is listed above. KernelSU and the game may operate in different mount namespaces, so visibility can differ across processes.

## Known limitations

- The 120 FPS combat movement fix was tested successfully in **melee and ranged combat on the original test device**. This does not guarantee compatibility with every device, game build, or combat scenario.
- Actual frame rates depend on display refresh rate, device performance, and Android/game settings.
- The module is designed for **manual Action-button switching**, not automatic startup patching.
- KernelSU mount namespaces can affect whether the game sees a bind mount; a successful script message alone does not prove that the game process is using the selected library.
- The module only supports the specific KOTOR 1 ARM64 library identified by the checksum above.

## Credits and context

Created from the tested Android KOTOR 1 60 FPS patch and the 120 FPS combat movement timer experiment. D3M0's PC KOTOR high-FPS patch work was used as a reference during investigation; the Android ARM64 changes are separate, architecture-specific modifications and should not be represented as an official D3M0 Android release.
Credit to https://github.com/gnw-d3m0/D3M0s-KPatches. AI helped me take the code, and translate it to ARM64 for Android use.

**Use at your own risk.** This is an unofficial modification and is not affiliated with Aspyr, Lucasfilm, Disney, or KernelSU.
