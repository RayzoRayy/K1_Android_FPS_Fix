KOTOR 1 Android ARM64 - Unified KernelSU Action Switcher

ACTION BUTTON CYCLE:
  Stock 40 FPS -> 60 FPS -> 120 FPS + Combat Movement Fix -> Stock 40 FPS

Install this ZIP in KernelSU Modules. Remove/disable the older separate
60 FPS and 120 FPS modules to avoid conflicting Action buttons. The old
modules do not need to be active for this module to function.

This module does not patch at boot. Each Action tap force-stops KOTOR and
bind-mounts a verified library. Relaunch the game after each switch.

The switcher recognizes the original 40 FPS library, the verified 60 FPS
library, and the verified 120 FPS + combat fix library. It can recognize
and switch away from an already mounted copy of either verified patch.

IMPORTANT: Changes to the bind mount may be lost after reboot; the Action
button detects the actual current library rather than trusting saved state.
KernelSU mount namespaces may differ across processes; confirm the game
actually sees the selected patch. If a mount is not visible to the game,
use the same root/mount namespace setup that worked in your prior tests.

Original SHA256: a226ac4f6c7bdcdd8d584f5423cd1912c746757ee79939fef417b9c9243b7d52
60 FPS SHA256: 175fa822bf28abbe8e853467b04752b3838f7bdebffeafca7c486052fe8e0924
120 FPS + combat SHA256: e0ae12c7f846caf4ace0f7a90df2c9549db07c6c31282969363054fdc7eadbde

Never use this module on a different game build with an unknown checksum.
