#!/usr/bin/env python3
"""Minimal TTF cmap reader -> set of codepoints a font covers (formats 4 & 12)."""
import glob
import struct
import sys


def font_coverage(path):
    with open(path, "rb") as fh:
        data = fh.read()
    table_dir = 0
    num_tables = struct.unpack(">H", data[table_dir + 4:table_dir + 6])[0]
    cmap_off = None
    for i in range(num_tables):
        rec = table_dir + 12 + 16 * i
        if data[rec:rec + 4] == b"cmap":
            cmap_off = struct.unpack(">I", data[rec + 8:rec + 12])[0]
            break
    if cmap_off is None:
        return set()

    n_sub = struct.unpack(">H", data[cmap_off + 2:cmap_off + 4])[0]
    cps = set()
    for i in range(n_sub):
        rec = cmap_off + 4 + 8 * i
        sub = cmap_off + struct.unpack(">I", data[rec + 4:rec + 8])[0]
        fmt = struct.unpack(">H", data[sub:sub + 2])[0]
        if fmt == 4:
            segx2 = struct.unpack(">H", data[sub + 6:sub + 8])[0]
            seg = segx2 // 2
            ends = struct.unpack(f">{seg}H", data[sub + 14:sub + 14 + segx2])
            sp = sub + 16 + segx2
            starts = struct.unpack(f">{seg}H", data[sp:sp + segx2])
            for s, e in zip(starts, ends):
                if s != 0xFFFF:
                    cps.update(range(s, min(e, 0xFFFE) + 1))
        elif fmt == 12:
            ngroups = struct.unpack(">I", data[sub + 12:sub + 16])[0]
            base = sub + 16
            for g in range(ngroups):
                s, e, _ = struct.unpack(">III", data[base + 12 * g:base + 12 * g + 12])
                cps.update(range(s, min(e, s + 0x20000) + 1))
    return cps


def coverage():
    cov = set()
    for f in glob.glob("/home/anzar/.local/share/fonts/*.ttf"):
        try:
            cov |= font_coverage(f)
        except Exception as exc:
            print(f"  ! {f}: {exc}", file=sys.stderr)
    return cov


CANDIDATES = {
    "firefox": 0xF0239, "android": 0xF0032, "code": 0xF0A1E, "chrome": 0xF02AF,
    "terminal": 0xF018D, "folder": 0xF024B, "chat": 0xF0B79, "music": 0xF075A,
    "power": 0xF0425, "apps": 0xF0614, "volume_high": 0xF057E,
    "volume_med": 0xF0580, "volume_off": 0xF0581, "wifi": 0xF05A9,
    "wifi_off": 0xF05AA, "battery": 0xF0079, "battery_chg": 0xF0084,
    "cpu": 0xF0EE0, "memory": 0xF035B, "clock": 0xF0954, "bright_low": 0xF00DE,
    "bright_med": 0xF00DF, "bright_high": 0xF00E0, "window": 0xF05AF,
    "sparkle": 0xF09E8, "web": 0xF059F, "cog": 0xF0493, "play": 0xF040A,
    "book": 0xF00BA, "image": 0xF02E9, "video": 0xF0567, "grid": 0xF0A70,
    "circle": 0xF0765, "dot": 0xF09DE, "numeric1": 0xF0B3A,
}

if __name__ == "__main__":
    cov = coverage()
    print(f"total codepoints covered: {len(cov)}\n")
    ok, miss = [], []
    for name, cp in sorted(CANDIDATES.items(), key=lambda kv: kv[1]):
        (ok if cp in cov else miss).append(f"U+{cp:05X} {name}")
    print("PRESENT:"); [print("  ", x) for x in ok]
    print("MISSING:"); [print("  ", x) for x in miss] or print("   none")
