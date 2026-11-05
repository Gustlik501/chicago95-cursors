{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "chicago95-cursors";
  version = "0-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "grassmunk";
    repo = "Chicago95";
    rev = "5da19b8b1e2a886ebf6628403023d5fac3acc3ee";
    sparseCheckout = [ "Cursors" ];
    hash = "sha256-JCfMVmXtZ7WKl8UQLxoLnzIQELYoZlrEClm19mz76ao=";
  };

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons"
    count=0
    for theme in Cursors/*; do
      if test -d "$theme/cursors" && test -f "$theme/index.theme"; then
        destination="$out/share/icons/$(basename "$theme")"
        mkdir -p "$destination"
        cp -a "$theme/cursors" "$theme/index.theme" "$destination/"
        count=$((count + 1))
      fi
    done
    test "$count" -gt 0
    test -f "$out/share/icons/Chicago95_Standard_Cursors/cursors/left_ptr"
    install -Dm644 README.md "$out/share/doc/chicago95-cursors/upstream-README.md"
    install -Dm644 CREDITS "$out/share/doc/chicago95-cursors/CREDITS"
    runHook postInstall
  '';

  meta = {
    description = "Prebuilt Chicago95 Xcursor themes, including Standard and HiDPI variants";
    homepage = "https://github.com/grassmunk/Chicago95";
    license = [ lib.licenses.gpl3Plus lib.licenses.mit ];
    platforms = lib.platforms.linux;
  };
}
