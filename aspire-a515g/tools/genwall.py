#!/usr/bin/env python3
"""Generate the Catppuccin Mocha mesh-gradient wallpaper.

Renders a small mesh of coloured blobs, upscales it for a smooth gradient,
applies a vignette so panel text stays readable, and adds fine grain to kill
banding. Requires Pillow.

    python3 genwall.py            -> ~/Pictures/wallpapers/catppuccin-mesh.png
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

W, H = 1920, 1080
SW, SH = 192, 108          # low-res mesh, upscaled for a smooth gradient

BASE = (24, 24, 37)        # mantle
BLOBS = [                  # (x%, y%, radius%, colour, strength)
    (0.18, 0.22, 0.55, (137, 180, 250), 0.55),   # blue
    (0.82, 0.18, 0.50, (203, 166, 247), 0.50),   # mauve
    (0.70, 0.80, 0.60, (116, 199, 236), 0.38),   # sapphire
    (0.30, 0.85, 0.50, (180, 190, 254), 0.32),   # lavender
    (0.50, 0.50, 0.70, (49, 50, 68), 0.45),      # surface0 lift
]

OUT = os.path.expanduser("~/Pictures/wallpapers/catppuccin-mesh.png")


def main():
    mesh = Image.new("RGB", (SW, SH), BASE)
    px = mesh.load()
    for y in range(SH):
        for x in range(SW):
            r, g, b = BASE
            for bx, by, br, (cr, cg, cb), st in BLOBS:
                dx = (x / SW - bx) * (W / H)      # aspect-correct distance
                dy = y / SH - by
                d = math.hypot(dx, dy) / br
                if d < 1.0:
                    f = (1.0 - d * d) ** 2 * st   # smooth falloff
                    r += (cr - r) * f
                    g += (cg - g) * f
                    b += (cb - b) * f
            px[x, y] = (int(r), int(g), int(b))

    img = mesh.resize((W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(28))

    # vignette: darken toward the edges so bar text stays readable
    vig = Image.new("L", (SW, SH), 0)
    ImageDraw.Draw(vig).ellipse(
        [-SW * 0.35, -SH * 0.35, SW * 1.35, SH * 1.35], fill=255)
    vig = vig.resize((W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(120))
    img = Image.composite(img, Image.new("RGB", (W, H), (17, 17, 27)), vig)

    # fine grain to kill banding
    random.seed(7)
    grain = img.load()
    for y in range(H):
        for x in range(0, W, 2):
            n = random.randint(-4, 4)
            r, g, b = grain[x, y]
            grain[x, y] = (max(0, min(255, r + n)),
                           max(0, min(255, g + n)),
                           max(0, min(255, b + n)))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print("wrote", OUT, img.size)


if __name__ == "__main__":
    main()
