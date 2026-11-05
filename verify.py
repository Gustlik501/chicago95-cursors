"""Run with `nix develop --command python verify.py` after `nix build`."""
import configparser
from pathlib import Path
import struct
import subprocess

root = Path(__file__).resolve().parent
work = root / ".work"
work.mkdir(exist_ok=True)
report = []
for theme in sorted((root / "result/share/icons").iterdir()):
    index = configparser.ConfigParser()
    index.read(theme / "index.theme")
    name = index["Icon Theme"]["Name"]
    inherits = index["Icon Theme"].get("Inherits", "(none: standalone cursor theme)")
    assert name.strip()
    sizes, dimensions, seen = set(), set(), set()
    for cursor in (theme / "cursors").iterdir():
        assert cursor.exists(), f"broken symlink: {cursor}"
        target = cursor.resolve()
        if target in seen:
            continue
        seen.add(target)
        data = cursor.read_bytes()
        magic, header, version, count = struct.unpack_from("<4I", data)
        assert magic == 0x72756358, cursor
        for i in range(count):
            kind, size, offset = struct.unpack_from("<3I", data, header + 12 * i)
            if kind == 0xFFFD0002:
                sizes.add(size)
                dimensions.add(struct.unpack_from("<2I", data, offset + 16))
    report.append(f"{theme.name}: Name={name}; Inherits={inherits}; nominal sizes={sorted(sizes)}; image dimensions={sorted(dimensions)}; unique cursors={len(seen)}")
standard = root / "result/share/icons/Chicago95_Standard_Cursors/cursors"
images = []
for name in ("left_ptr", "hand2", "xterm", "watch"):
    destination = work / name
    destination.mkdir(exist_ok=True)
    subprocess.run(["xcur2png", "-d", str(destination), "-c", str(destination / "cursor.conf"), str(standard / name)], check=True)
    images.append(sorted(destination.glob("*.png"))[0])
# Keep the native 32px images, then add an enlarged, nearest-neighbor view.
subprocess.run(["magick", "montage", *map(str, images), "-background", "#c0c0c0", "-tile", "4x1", "-geometry", "32x32+8+8", str(work / "preview-native.png")], check=True)
subprocess.run(["magick", str(work / "preview-native.png"), "-filter", "point", "-resize", "400%", str(work / "preview.png")], check=True)
text = "\n".join(report) + "\n"
(work / "verification.txt").write_text(text)
print(text)
