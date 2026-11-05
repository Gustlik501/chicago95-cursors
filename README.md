# chicago95-cursors

The seven prebuilt Xcursor themes from [grassmunk/Chicago95](https://github.com/grassmunk/Chicago95),
without the GTK theme, icons, build sources or fonts. Pinned to master commit
`5da19b8b1e2a886ebf6628403023d5fac3acc3ee` (2026-10-01), verified as the
branch tip when packaged; fetched using `sparseCheckout = [ "Cursors" ]`.
The upstream root README declares **GPL-3.0+/MIT**; no cursor-specific licence
file overrides it. Both licences are recorded in `meta.license`, with upstream
README and CREDITS installed in `$out/share/doc/chicago95-cursors/`.

```sh
nix build
nix flake check
nix develop --command python verify.py
```

Installs `$out/share/icons/<upstream-directory>/{index.theme,cursors/}` with
symlinks preserved. Variants (all standalone; upstream has no `Inherits=`):

| Directory / theme identifier | `Name=` | Native size |
|---|---|---|
| **Chicago95_Standard_Cursors** (chosen default) | Chicago 95 Standard | 32 |
| Chicago95_Standard_Cursors_Black | Chicago 95 Standard Black | 32 |
| Chicago95_Animated_Hourglass_Cursors | Chicago 95 Animated Hourglass | 32 |
| Chicago95_Animated_Hourglass_Cursors_HiDPI | Chicago 95 Animated Hourglass HiDPI | 64 |
| Chicago95_Cursor_Black | Chicago 95 Black | 32 |
| Chicago95_Cursor_White | Chicago 95 White | 32 |
| Chicago95_Emerald | Chicago 95 Emerald Green | 32 |

## NixOS / Home Manager

Add this flake as `inputs.chicago95-cursors`, following your nixpkgs input.
Use `inputs.chicago95-cursors.packages.x86_64-linux.chicago95-cursors`, or add
`inputs.chicago95-cursors.overlays.default` to `nixpkgs.overlays` for
`pkgs.chicago95-cursors`.

NixOS: `environment.systemPackages = [ pkgs.chicago95-cursors ];`.
Home Manager (default theme selection):

```nix
home.pointerCursor = {
  package = pkgs.chicago95-cursors;
  name = "Chicago95_Standard_Cursors";
  size = 32;
  gtk.enable = true;
  x11.enable = true;
};
home.sessionVariables = {
  HYPRCURSOR_THEME = "Chicago95_Standard_Cursors";
  XCURSOR_THEME = "Chicago95_Standard_Cursors";
  XCURSOR_SIZE = "32";
};
```

Set these variables **before starting the next compositor session** (with
uwsm use its environment files). Size 24 is possible, but **32 is native**;
every Standard cursor chunk has nominal size 32 and 32×32 image dimensions.
The HiDPI variant has only 64×64 chunks, not multiple embedded sizes.

These are **Xcursor**, not native hyprcursor themes. The hyprcursor library
does not read this format directly; **Hyprland falls back to its Xcursor
loader** when the hyprcursor theme cannot load. Both theme variables are set
so fallback and X11 clients agree. See Hyprland's
[CursorManager source](https://github.com/hyprwm/Hyprland/blob/b6633c41/src/managers/CursorManager.cpp)
(`valid()` check and `XCURSOR_THEME` loading). No conversion is necessary.

## Verification

`verify.py` checks every cursor header, all symlink targets, names and native
sizes. All seven `index.theme` names are meaningful; absent inheritance is
valid for these standalone themes. `xcur2png` successfully extracts Standard
`left_ptr`, `hand2`, `xterm`, `watch` (one 32px image each).
`.work/preview.png` is a nearest-neighbor 4× contact image in that order;
`.work/<cursor>/` contains the extracted PNG and xcursorgen configuration.
No settings, cursors or compositor state in the running session were changed;
fallback behavior was source-checked, not live-session tested.
