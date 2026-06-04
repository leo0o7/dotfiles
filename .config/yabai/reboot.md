# yabai reboot recovery

Run `./fix-yabai`.

If you get `protection failure`, run `./patch-yabai-sa`.
The `arm64e` slice should show `capabilities 0x80` after patching.

## why this breaks

Usually because one of these happened:

- yabai was upgraded, so the sudoers hash no longer matches the current binary
- the scripting addition reload failed after reboot/Dock restart
- your system hit the PAC ABI mismatch again and the loader needed the `0x81 -> 0x80` patch
